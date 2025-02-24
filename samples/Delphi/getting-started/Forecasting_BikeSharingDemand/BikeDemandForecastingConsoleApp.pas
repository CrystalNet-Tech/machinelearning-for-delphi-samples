unit BikeDemandForecastingConsoleApp;


interface

uses BikeDemandForecasting_Models, MLContextMgr, MLTransforms, MLData, MLCore;

type
  TBikeDemandForecastingConsoleApp = class
  private
  public
    class procedure Run;
    class procedure Evaluate(testData: IMLDataView; model: IMLTransformer; mlContext: IMLContextManager);
    class procedure Forecast(testData: IMLDataView; horizon: Integer; forecaster: MLTimeSeriesPredictionEngine<TMLEntity, TMLEntity>; mlContext: IMLContextManager);
  end;

implementation

uses System.Data.SqlClient, System.Data.SqlClient.Intf, CrystalNet.Console, System.Math, MLCatalogs,
  Crystalnet.Runtime, ConsoleHelper, CrystalNet.Drawing.Primitives, CrystalNet.Data.Common.Enums,
  MLCollections, System.SysUtils;

const
  DataRelativePath = '..\..\Data';
  DbFileRelativePath = DataRelativePath + '\DailyDemand.mdf';
  ModelRelativePath = DataRelativePath + '\MLModel.zip';


{ TBikeDemandForecastingConsoleApp }

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

class procedure TBikeDemandForecastingConsoleApp.Forecast(testData: IMLDataView;
  horizon: Integer;
  forecaster: MLTimeSeriesPredictionEngine<TMLEntity, TMLEntity>;
  mlContext: IMLContextManager);
begin
  var forecast: TModelOutput := forecaster.Predict() as TModelOutput;

  var forecastOutput: Enumerable<string> :=
      mlContext.Data.CreateEnumerable<TModelInput>(testData, false)
          .Take(horizon)
          .Select<string>(function(rental: TModelInput; index: Integer): string
                  begin
                      var rentalDate: string := DateToStr(rental.RentalDate);
                      var actualRentals: Single := rental.TotalRentals;
                      var lowerEstimate: Single := TMath.NClass.Max(0, forecast.LowerBoundRentals[index]);
                      var estimate: Single := forecast.ForecastedRentals[index];
                      var upperEstimate: Single := forecast.UpperBoundRentals[index];
                      Result := Tstring.NClass.Format('Date: {0}' + #13#10 +
                                                      'Actual Rentals: {1}' + #13#10 +
                                                      'Lower Estimate: {2}' + #13#10 +
                                                      'Forecast: {3}' + #13#10 +
                                                      'Upper Estimate: {4}' + #13#10,
                                                      [rentalDate, actualRentals, lowerEstimate, estimate, upperEstimate]);
                  end);

  // Output predictions
  TConsole.NClass.WriteLine('Rental Forecast');
  TConsole.NClass.WriteLine('---------------------');
  for var prediction in forecastOutput do
  begin
    TConsole.NClass.WriteLine(prediction);
  end;
end;

class procedure TBikeDemandForecastingConsoleApp.Run;
begin
  var dbFilePath: string := GetAbsolutePath(DbFileRelativePath);
  var modelPath: string := GetAbsolutePath(ModelRelativePath);

  var mlContext := TMLContextManager.Create();

  var connectionString := 'Data Source = (LocalDB)\MSSQLLocalDB;AttachDbFilename='+ dbFilePath +';Integrated Security=True;Connect Timeout=30;';

  var loader: IMLDatabaseLoader := mlContext.Data.CreateDatabaseLoader<TModelInput>();

  var query: string := 'SELECT RentalDate, CAST(Year as REAL) as Year, CAST(TotalRentals as REAL) as TotalRentals FROM Rentals';

  var dbSource := TMLDatabaseSource.Create(TSqlClientFactory.NClass.Instance, connectionString, query);

  var dataView: IMLDataView := loader.Load(dbSource);

  var firstYearData: IMLDataView := mlContext.Data.FilterRowsByColumn(dataView, 'Year', NegInfinity, 1);
  var secondYearData: IMLDataView := mlContext.Data.FilterRowsByColumn(dataView, 'Year', 1, Infinity);

  var forecastingPipeline := mlContext.Forecasting.ForecastBySsa('ForecastedRentals', 'TotalRentals', 7, 30, 365, 7,
                                                                 False, 1, TMLRankSelectionMethod.rsmExact, True, False,
                                                                 nil, 'LowerBoundRentals', 'UpperBoundRentals');

  var forecaster: IMLSsaForecastingTransformer := forecastingPipeline.Fit(firstYearData);

  Evaluate(secondYearData, forecaster, mlContext);

  var forecastEngine := forecaster.CreateTimeSeriesEngine(TypeInfo(TModelInput), TypeInfo(TModelOutput), mlContext);
  forecastEngine.CheckPoint(mlContext, modelPath);

  Forecast(secondYearData, 7, forecastEngine, mlContext);
end;

end.
