# Sales forecasting

In this sample, you'll see how to use [ML.Net for Delphi](https://crystalnet-tech.com/Products/mldotNet4Delphi/Default) to predict whether a text message is spam. In the world of machine learning, this type of prediction is known as **forecasting**.

### Problem

This problem is centered around product forecasting based on previous sales.

### DataSet

To solve this problem, two independent ML models are built that take the following datasets as input:  

| Data Set            | Columns                                                            |
|---------------------|--------------------------------------------------------------------|
| **products stats**  | next, productId, year, month, units, avg, count, max, min, prev    |

[Explanation of Dataset](docs/Details-of-Dataset.md) - Goto this link for detailed information on dataset.

### ML Task - Forecasting with Regression and Forecasting with Time Series

The sample shows two different ML tasks and algorithms that can be used for forecasting:

- **Regression** using FastTreeTweedie Regression
- **Time Series** using Single Spectrum Analysis (SSA)

**Regression** is a supervised machine learning task that is used to predict the value of the **next** period (in this case, the sales prediction) from a set of related features/variables. **Regression** works best with linear data.

**Time Series** is an estimation technique that can be used to forecast **multiple** periods in the future. **Time Series** works well in scenarios that involve non-linear data where trends are difficult to distinguish.  This is because the SSA algorithm, which is used by **Time Series**, performs calculations to automatically identify seasonal/periodic patterns while filtering out meaningless noise in the data.  With a **Time Series** model, it's important to regularly update the state of the model with new observed data points to ensure the accuracy as new predictions are performed.  For this reason, a **Time Series** model is stateful.

### Solution

To solve this problem, first we will build the ML models by training each model on existing data. Next, we will evaluate how good it is. Finally, we will consume the model to predict sales.

Note that the **Regression** sample implements a model to forecast linear data.  Specifically, the model predicts the product's demand forecast for the next period (month).

The **Time Series** sample currently implements the product's demand forecast for the next **two** periods (months). The **Time Series** sample uses the same products as in the **Regression** sample so that you can compare the forecasts from the two algorithms.

When learning/researching the samples, you can focus choose to focus specifically on regression or time series.

![Build -> Train -> Evaluate -> Consume](docs/images/modelpipeline.png)

#### Load the Dataset

Both the **Regression** and **Time Series** samples start by loading data using **TextLoader**. To use **TextLoader**, we must specify the type of the class that represents the data schema. Our class type is **ProductData**.

```Delphi
  TProductData = class(TMLEntity)
  public
    // The index of column in LoadColumn(int index) should be matched with the position of columns in the underlying data file.
    // The next column is used by the Regression algorithm as the Label (e.g. the value that is being predicted by the Regression model).
    [LoadColumn(0)]
    next: Single;

    [LoadColumn(1)]
    productId: Single;

    [LoadColumn(2)]
    year: Single;

    [LoadColumn(3)]
    month: Single;

    [LoadColumn(4)]
    units: Single;

    [LoadColumn(5)]
    avg: Single;

    [LoadColumn(6)]
    count: Single;

    [LoadColumn(7)]
    max: Single;

    [LoadColumn(8)]
    min: Single;

    [LoadColumn(9)]
    prev: Single;
 end;
```

Load the dataset into the **DataView**.

```Delphi
var trainingDataView := mlContext.Data.LoadFromTextFile<TProductData>(dataPath, ',', True);
```

In the following steps, we will build the pipeline transformations, specify which trainer/algorithm to use, evaluate the models, and test their predictions. This is where the steps start to differ between the [**Regression**](#regression) and [**Time Series**](#time-series) samples - the remainder of this walkthrough looks at each of these algorithms separately.

### Regression

#### 1. Regression: Create the Pipeline

This step shows how to create the pipeline that will later be used for building and training the **Regression** model.

Specifically, we do the following transformations:

- Concatenate current features to a new column named **NumFeatures**.
- Transform **productId** using [one-hot encoding](https://en.wikipedia.org/wiki/One-hot).
- Concatenate all generated features in one column named **Features**.
- Copy **next** column to rename it to **Label**.
- Specify the **Fast Tree Tweedie** trainer as the algorithm to apply to the model.

You can load the dataset either before or after designing the pipeline. Although this step is just configuration, it is lazy and won't be loaded until training the model in the next step.

[Model build and train](./RegressionProductModelHelper.pas)

```Delphi
var trainer := mlContext.Regression.Trainers.FastTreeTweedie('Label', 'Features');

var trainingPipeline := mlContext.Transforms.Concatenate('NumFeatures', ['year', 'month', 'units', 'avg', 'count', 'max', 'min', 'prev'])
       .Append(mlContext.Transforms.Categorical.OneHotEncoding('CatFeatures', 'productId'))
       .Append(mlContext.Transforms.Concatenate('Features', ['NumFeatures', 'CatFeatures']))
       .Append(mlContext.Transforms.CopyColumns('Label', 'next'))
       .Append(trainer);
```

#### 2. Regression: Evaluate the Model

In this case, the **Regression** model is evaluated before training the model with a cross-validation approach. This is to obtain metrics that indicate the accuracy of the model.

```Delphi
var crossValidationResults := mlContext.Regression.CrossValidate(trainingDataView, trainingPipeline, 6, 'Label');

ConsoleHelper.PrintRegressionFoldsAverageMetrics(trainer.ToString(), crossValidationResults);
```

#### 3. Regression: Train the Model

After building the pipeline, we train the **Regression** forecast model by fitting or using the training data with the selected algorithm. In this step, the model is built, trained and returned as an object:

```Delphi
var model := trainingPipeline.Fit(trainingDataView);
```

#### 4. Regression: Save the Model

Once the **Regression** model is created and evaluated, you can save it into a **.zip** file which can be consumed by any end-user application with the following code:

```Delphi
mlContext.Model.Save(model, trainingDataView.Schema, outputModelPath);
```

#### 5. Regression: Test the Prediction

To create a prediction, load the **Regression** model from the **.zip** file.

This sample uses the last month of a product's sample data to predict the unit sales in the next month.

```Delphi
var modelInputSchema: IMLDataViewSchema := nil;
var trainedModel: IMLTransformer := mlContext.Model.Load(stream, modelInputSchema);

var predictionEngine := mlContext.Model.CreatePredictionEngine<TProductData, TProductUnitRegressionPrediction>(trainedModel);

TConsole.NClass.WriteLine('** Testing Product **');

// Predict the nextperiod/month forecast to the one provided
var prediction := predictionEngine.Predict(TSampleProductData.MonthlyData[0]);
TConsole.NClass.WriteLine('Product: {0}, month: {1}, year: {2} - Real value (units): {3}, Forecast Prediction (units): {4}',
  [TSampleProductData.MonthlyData[0].productId, TSampleProductData.MonthlyData[0].month + 1, TSampleProductData.MonthlyData[0].year,
  TSampleProductData.MonthlyData[0].next, prediction.Score]);

// Predicts the nextperiod/month forecast to the one provided
prediction := predictionEngine.Predict(TSampleProductData.MonthlyData[1]);
TConsole.NClass.WriteLine('Product: {0}, month: {1}, year: {2} - Forecast Prediction (units): {3}',
  [TSampleProductData.MonthlyData[1].productId, TSampleProductData.MonthlyData[1].month + 1, TSampleProductData.MonthlyData[1].year,
  prediction.Score]);
```

### Time Series

#### 1. Time Series: Create the Pipeline

This step shows how to create the pipeline that will later be used for training the **Time Series** model.

Specifically, the **Single Spectrum Analysis (SSA)** trainer is the algorithm that is used. Read further to understand the parameters required for this algorithm.  It's important to note that ML.NET enforces constraints for the values of **windowSize**, **seriesLength**, and **trainsize**:
- **windowSize** must be at least 2.
- **trainSize** must be greater than twice the window size.
- **seriesLength** must be greater than the window size.

Here are descriptions of the parameters:

- **outputColumnName**: This is the name of the column that will be used to store predictions. The column must be a vector of type **Single**. In a later step, we define a class named **ProductUnitTimeSeriesPrediction** that contains this output column.
- **inputColumnName**: This is the name of the column that is being predicted/forecasted. The column contains a value of a datapoint in the time series and must be of type **Single**. In our sample, we are predicting/forecasting product **units** which is our input column.
- **windowSize**:  This is the most important parameter that you can use to tune the accuracy of the model for your scenario.  Specifically, this parameter is used to define a window of time that is used by the algorithm to decompose the time series data into seasonal/periodic and noise components. Typically, you should start with the largest window size that is representative of the seasonal/periodic business cycle for your scenario.  For example, if the business cycle is known to have both weekly and monthly (e.g. 30-day) seasonalities/periods and the data is collected daily, the window size in this case should be 30 to represent the largest window of time that exists in the business cycle.  If the same data also exhibits annual seasonality/periods (e.g. 365-day), but the scenario in which the model will be used is **not** interested in **annual** seasonality/periods, then the window size does **not** need to be 365.  In this sample, the product data is based on a 12 month cycle where data is collected monthly -- as a result, the window size used is 12.
- **seriesLength**: This parameter specifies the number of data points that are used when performing a forecast.
- **trainSize**: This parameter specifies the total number of data points in the input time series, starting from the beginning.  Note that, after a model is created, it can be saved and updated with new data points that are collected.
- **horizon**: This parameter indicates the number of time periods to predict/forecast. In this sample, we specify 2 to indicate that the next 2 months of product units will be predicated/forecasted.
- **confidenceLevel**: This parameter indicates the likelihood the real observed value will fall within the specified interval bounds. Typically, .95 is an acceptable starting point - this value should be between [0, 1).  Usually, the higher the confidence level, the wider the range that the interval bounds will be.  And conversely, the lower the confidence level, the narrower the interval bounds.
- **confidenceLowerBoundColumn**: This is the name of the column that will be used to store the **lower** confidence interval bound for each forecasted value. The **ProductUnitTimeSeriesPrediction** class also contains this output column.
- **confidenceUpperBoundColumn**: This is the name of the column that will be used to store the **upper** confidence interval bound for each forecasted value. The **ProductUnitTimeSeriesPrediction** class also contains this output column.

Specifically, we add the following trainer to the pipeline:

```Delphi
// Create and add the forecast estimator to the pipeline.
var forecastEstimator := mlContext.Forecasting.ForecastBySsa(
      'ForecastedProductUnits',
      'units', // This is the column being forecasted.
      12, // Window size is set to the time period represented in the product data cycle; our product cycle is based on 12 months, so this is set to a factor of 12, e.g. 3.
      numSeriesDataPoints, // This parameter specifies the number of data points that are used when performing a forecast.
      numSeriesDataPoints, // This parameter specifies the total number of data points in the input time series, starting from the beginning.
      2, // Indicates the number of values to forecast; 2 indicates that the next 2 months of product units will be forecasted.
      False, 1, TMLRankSelectionMethod.rsmExact, True, False, nil,
      'ConfidenceLowerBound', //This is the name of the column that will be used to store the lower interval bound for each forecasted value.
      'ConfidenceUpperBound', //This is the name of the column that will be used to store the upper interval bound for each forecasted value.
      0.95);
```

#### 2. Time Series: Fit the Model

Before fitting the **Time Series** model, we first must filter the loaded dataset to select the data series for the specific product that will be used for forecasting sales.

```Delphi
var productId: Integer = 988;
var productDataView: IMLDataView := mlContext.Data.FilterRowsByColumn(allProductsDataView, 'productId', productId, productId + 1);
```

Next, we fit the model to the data series for the specified product.

```Delphi
// Fit the forecasting model to the specified product's data series.
var forecastTransformer: MLTransformer := forecastEstimator.Fit(productDataSeries);
```

#### 3. Time Series: Create a CheckPoint of the Model

To save the model, we first must create the **TimeSeriesPredictionEngine** which is used for both getting predictions and saving the model.  The **Time Series** model is saved using the **CheckPoint** method which saves the model to a **.zip** file that can be consumed by any end-user application.  You may notice that this is different from the above **Regression** sample which instead used the **Save** method for saving the model. **Time Series** is different because it requires that the model's state to be continuously updated with new observed values as predictions are made. As a result, the **CheckPoint** method exists to update and save the model state on a reoccurring basis. This will be shown in further detail in a later step of this sample. For now, just remember that **Checkpoint** is used for saving and updating the **Time Series** model.

```Delphi
// Create the forecast engine used for creating predictions.
var forecastEngine: IMLTimeSeriesPredictionEngine<TProductData, TProductUnitTimeSeriesPrediction> := forecaster.CreateTimeSeriesEngine<TProductData, TProductUnitTimeSeriesPrediction>(mlContext);

// Save the forecasting model so that it can be loaded within an end-user app.
forecastEngine.CheckPoint(mlContext, outputModelPath);
```

#### 4. Time Series: Test the Prediction

To get a prediction, load the **Time Series** model from the **.zip** file and create a new **TimeSeriesPredictionEngine**. After this, we can get a prediction.

```Delphi
// Load the forecast engine that has been previously saved.
var schema: IMLDataViewSchema := nil;
var forecaster: MLTransformer := mlContext.Model.Load(outputModelPath,  schema);;

// We must create a new prediction engine from the persisted model.
var forecastEngine: IMLTimeSeriesPredictionEngine<ProductData, ProductUnitTimeSeriesPrediction> := forecaster.CreateTimeSeriesEngine<TProductData, TProductUnitTimeSeriesPrediction>(mlContext);

var originalSalesPrediction: TProductUnitTimeSeriesPrediction = forecastEngine.Predict();
```

The **ProductUnitTimeSeriesPrediction** type that we specified when we created the **TimeSeriesPredictionEngine** is used to store the prediction results:

```Delphi
  TProductUnitTimeSeriesPrediction = class(TMLEntity)
  private
    FForecastedProductUnits: TArray<Single>;
    FConfidenceLowerBound: TArray<Single>;
    FConfidenceUpperBound: TArray<Single>;
  public
    property ForecastedProductUnits: TArray<Single> read FForecastedProductUnits write FForecastedProductUnits;
    property ConfidenceLowerBound: TArray<Single> read FConfidenceLowerBound write FConfidenceLowerBound;
    property ConfidenceUpperBound: TArray<Single> read FConfidenceUpperBound write FConfidenceUpperBound;
  end
```

Remember that when we created the SSA forecasting trainer using the **ForecastBySsa** method, we provided the following parameter values:

- **horizon**: 2
- **confidenceLevel**: .95f

As a result of this, when we call the **Predict** method using the loaded model, the **ForecastedProductUnits** vector will contain **two** forecasted values. Similarly, the **ConfidenceLowerBound** and **ConfidenceUpperBound** vectors will each contain **two** values based on the specified **confidenceLevel**.

You may notice that the **Predict** method has several overloads that accept the following parameters:

- **horizon**: Allows you to specify new value for **horizon** each time that you do a prediction.
- **confidenceLevel**: Allows you to specify new value for **confidenceLevel** each time that you do a prediction.
- **ProductData example**: Used to pass in a new observed **ProductData** data point for the time series via the **example** parameter.  Remember, that when calling **Predict** with new observed **ProductData** values, this updates the model state with these data points in the time series. You then need to save the updated model to disk by calling the **CheckPoint** method.

This is also seen in our sample:

```Delphi
var updatedSalesPrediction: TProductUnitTimeSeriesPrediction := forecastEngine.Predict(TSampleProductData.MonthlyData[1], 1);

 // Save the updated forecasting model.
 forecastEngine.CheckPoint(mlContext, outputModelPath);
```
