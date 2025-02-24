# Bike Sharing Demand - Forecasting

In this sample, you can see how to load data from a relational database using the Database Loader to train a forecasting model that predicts bike rental demand.

## Problem

For a more detailed descritpion of the problem, read the details from the original [
Bike Sharing Demand competition from Kaggle](https://www.kaggle.com/c/bike-sharing-demand).

## DataSet

The data used in this sample comes from the [UCI Bike Sharing Dataset](https://archive.ics.uci.edu/ml/datasets/bike+sharing+dataset). Fanaee-T, Hadi, and Gama, Joao, 'Event labeling combining ensemble detectors and background knowledge', Progress in Artificial Intelligence (2013): pp. 1-15, Springer Berlin Heidelberg, [Web Link](https://link.springer.com/article/10.1007%2Fs13748-013-0040-3).

The original dataset contains several columns corresponding to seasonality and weather. For brevity and because the technique used in this sample only requires the values from a single numerical column, the original dataset has been enhanced to include only the following columns:

- **dteday**: The date of the observation.
- **year**: The encoded year of the observation (0=2011, 1=2012).
- **cnt**: The total number of bike rentals for that day.

The original dataset is mapped to a database table with the following schema in a SQL Server database.

```sql
CREATE TABLE [Rentals] (
	[RentalDate] DATE NOT NULL,
	[Year] INT NOT NULL,
	[TotalRentals] INT NOT NULL
);
```

The following is a sample of the data:

| RentalDate | Year | TotalRentals |
| --- | --- | --- |
|1/1/2011|0|985|
|1/2/2011|0|801|
|1/3/2011|0|1349|

## Database Loader

Database Loader provides a simple API to read data from relational databases directly into an `IMLDataView`. This loader supports any relational database provider supported by System.Data in .NET Core or .NET Framework, meaning that you can use any RDBMS such as SQL Server, Azure SQL Database, Oracle, SQLite, PostgreSQL, MySQL, Progress, IBM DB2, etc.

To load data, you need to provide a connection string and a SQL command to get data from the database.

```csharp
const
  DataRelativePath = '..\..\Data';
  DbFileRelativePath = DataRelativePath + '\DailyDemand.mdf';
  ModelRelativePath = DataRelativePath + '\MLModel.zip';
[...]

var dbFilePath: string := GetAbsolutePath(DbFileRelativePath);

var connectionString := 'Data Source = (LocalDB)\MSSQLLocalDB;AttachDbFilename='+ dbFilePath +';Integrated Security=True;Connect Timeout=30;';

var mlContext: IMLContextManager := TMLContextManager.Create();
var loader: IMLDatabaseLoader := mlContext.Data.CreateDatabaseLoader<TModelInput>();

var query: string := 'SELECT RentalDate, CAST(Year as REAL) as Year, CAST(TotalRentals as REAL) as TotalRentals FROM Rentals';

var dbSource := TMLDatabaseSource.Create(TSqlClientFactory.NClass.Instance, connectionString, query);

var dataView: IMLDataView := loader.Load(dbSource);
```

## ML task - [Regression](https://docs.microsoft.com/en-us/dotnet/machine-learning/resources/tasks#regression)

The ML Task for this sample is forecasting, which is a supervised machine learning task that is used to predict the value of the label (in this case the demand units prediction) from previous data.

## Solution

To solve this problem, you build and train an ML model on existing training data, evaluate how good it is (analyzing the obtained metrics), and lastly you can consume/test the model to predict the demand given input data variables.

![Build -> Train -> Evaluate -> Consume](../shared_content/modelpipeline.png)

## Training pipeline

A time series training pipeline can be defined by using `ForecastBySsa` transform.

```csharp
var forecastingPipeline := mlContext.Forecasting.ForecastBySsa('ForecastedRentals', 'TotalRentals', 7, 30, 365, 7,
                                                                False, 1, TMLRankSelectionMethod.rsmExact, True, False,
                                                                nil, 'LowerBoundRentals', 'UpperBoundRentals');
```

The `forecastingPipeline` takes 365 data points for the first year and samples or splits the time series dataset into 30-day (monthly) intervals as specified by the `seriesLength` parameter. Each of these samples is analyzed through weekly or 7-day window. When determining what the forecasted value for the next period(s) is, the values from previous seven days are used to make a prediction. The model is set to forecast seven periods into the future as defined by the `horizon` parameter. Because a forecast is an informed guess, it's not always 100% accurate. Therefore, it's good to know the range of values in the best and worst-case scenarios as defined by the upper and lower bounds. In this case, the level of confidence for the lower and upper bounds is set to 95%. The confidence level can be increased or decreased accordingly. The higher the value, the wider the range is between the upper and lower bounds to achieve the desired level of confidence.

Then, to train the model, use the `Fit` method.

```csharp
var forecaster: IMLSsaForecastingTransformer := forecastingPipeline.Fit(firstYearData);
```

## Evaluate the model

To evaluate the model, compare use the `Transform` method to forecast future values. Then, compare them against the actual values and calculate metrics like *Mean Absolute Error* and *Root Mean Squared Error*.

```csharp
class procedure TBikeDemandForecastingConsoleApp.Evaluate(testData: IMLDataView;
  model: IMLTransformer; mlContext: IMLContextManager);
begin
  // Make predictions
  var predictions: IMLDataView := model.Transform(testData);

  // Actual values
  var actual: Enumerable<Single> := mlContext.Data.CreateEnumerable<TModelInput>(testData, true)
                                            .Select<Single>(function (observed: TModelInput): Single
                                                            begin
                                                              Result := observed.TotalRentals;
                                                            end);

  // Predicted values
  var forecast: Enumerable<Single> := mlContext.Data.CreateEnumerable<TModelOutput>(predictions, true)
                                            .Select<Single>(function (prediction: TModelOutput): Single
                                                            begin
                                                              Result := prediction.ForecastedRentals[0];
                                                            end);


  // Calculate error (actual - forecast)
  var metrics := actual.Zip<Single, Single>(forecast, function (actualValue: Single; forecastValue: Single): Single
                                                              begin
                                                                Result := actualValue - forecastValue;
                                                              end);

  // Get metric averages
  var MAE := metrics.Average<Single>(function(error: Single): Single
                             begin
                               Result := TMath.NClass.Abs(error);
                             end); // Mean Absolute Error

  var RMSE := TMath.NClass.Sqrt(metrics.Average<Single>(function(error: Single): Single
                                                        begin
                                                          Result := TMath.NClass.Pow(error, 2);   // Root Mean Squared Error
                                                        end));

  // Output metrics
  TConsole.NClass.WriteLine('Evaluation Metrics');
  TConsole.NClass.WriteLine('---------------------');
  TConsole.NClass.WriteLine('Mean Absolute Error: {0:F3}', MAE);
  TConsole.NClass.WriteLine('Root Mean Squared Error: {0:F3}\n', RMSE);
end;
```

**Mean Absolute Error**: Measures how close predictions are to the actual value. This value ranges between 0 and infinity. The closer to 0, the better the quality of the model.

**Root Mean Squared Error**: Summarizes the error in the model. This value ranges between 0 and infinity. The closer to 0, the better the quality of the model.

## Forecasting values

To forecast values, create a `TimeSeriesPredictionEngine`, a convenience API to make single predictions.

```csharp
var forecastEngine := forecaster.CreateTimeSeriesEngine(TypeInfo(TModelInput), TypeInfo(TModelOutput), mlContext);
```

Then, use the `Predict` method to generate a single forecast for the number of periods specified by the `horizon`.

```csharp
class procedure TBikeDemandForecastingConsoleApp.Forecast(testData: IMLDataView; horizon: Integer; forecaster: MLTimeSeriesPredictionEngine<TMLEntity, TMLEntity>; mlContext: IMLContextManager);
begin
  var forecast: TModelOutput := forecaster.Predict() as TModelOutput;

  //... additional code
end;
```

## Sample Output

When you run the application, you should see output similar to the following:

```text
Evaluation Metrics
---------------------
Mean Absolute Error: 726.416
Root Mean Squared Error: 987.658

Rental Forecast
---------------------
Date: 1/1/2012
Actual Rentals: 2294
Lower Estimate: 1197.842
Forecast: 2334.443
Upper Estimate: 3471.044

Date: 1/2/2012
Actual Rentals: 1951
Lower Estimate: 1148.412
Forecast: 2360.861
Upper Estimate: 3573.309

Date: 1/3/2012
Actual Rentals: 2236
Lower Estimate: 1068.507
Forecast: 2373.277
Upper Estimate: 3678.046
```
