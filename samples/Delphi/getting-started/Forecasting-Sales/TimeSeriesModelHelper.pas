unit TimeSeriesModelHelper;

interface
uses MLContextMgr, ForecastingSales_Models;


/// <summary>
/// Predicts future product sales using time series forecasting with SSA (single spectrum analysis).
/// </summary>
/// <param name='mlContext'>ML.NET context.</param>
/// <param name='dataPath'>Input data file path.</param>
procedure PerformTimeSeriesProductForecasting(const mlContext: IMLContextManager; dataPath: string);

implementation

uses CrystalNet.Runtime, CrystalNet.IO.FileSystem, System.Generics.Collections, MLCore, System.Generics.Defaults,
  MLData, ConsoleHelper, MLCatalogs, CrystalNet.Console, SampleProductData;

/// <summary>
/// Loads the monthly product data series for a product with the specified id.
/// </summary>
/// <param name='mlContext'>ML.NET context.</param>
/// <param name='productId'>Product id.</param>
/// <param name='dataPath'>Input data file path.</param>
function LoadData(const mlContext: IMLContextManager; productId: Single; dataPath: string): IMLDataView;
begin
  // Load the data series for the specific product that will be used for forecasting sales.
  var allProductsDataView := mlContext.Data.LoadFromTextFile<TProductData>(dataPath, ',', true);
  var productDataView := mlContext.Data.FilterRowsByColumn(allProductsDataView, 'productId', productId, productId + 1);

  Result := productDataView;
end;

/// <summary>
/// Build model for predicting next month's product unit sales using time series forecasting.
/// </summary>
/// <param name='mlContext'>ML.NET context.</param>
/// <param name='productDataSeries'>ML.NET IDataView representing the loaded product data series.</param>
/// <param name='outputModelPath'>Model path.</param>
procedure FitAndSaveModel(const mlContext: IMLContextManager; productDataSeries: IMLDataView; outputModelPath: string);
const
  numSeriesDataPoints = 34; //The underlying data has a total of 34 months worth of data for each product
begin
  ConsoleWriteHeader(['Fitting product forecasting Time Series model']);

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
      0.95); // Indicates the likelihood the real observed value will fall within the specified interval bounds.

  // Fit the forecasting model to the specified product's data series.
  var forecastTransformer: MLTransformer := forecastEstimator.Fit(productDataSeries);

  // Create the forecast engine used for creating predictions.
  var forecastEngine := forecastTransformer.CreateTimeSeriesEngine<TProductData, TProductUnitTimeSeriesPrediction>(mlContext);

  // Save the forecasting model so that it can be loaded within an end-user app.
  forecastEngine.CheckPoint(mlContext, outputModelPath);
end;

/// <summary>
/// Predict samples using saved model.
/// </summary>
/// <param name='mlContext'>ML.NET context.</param>
/// <param name='lastMonthProductData'>The last month of product data in the monthly data series.</param>
/// <param name='outputModelPath'>Model file path</param>
procedure TestPrediction(const mlContext: IMLContextManager; lastMonthProductData: TProductData; outputModelPath: string);
var
  forecaster: MLTransformer;
  schema: IMLDataViewSchema;
begin
  ConsoleWriteHeader(['Testing product unit sales forecast Time Series model']);

  // Load the forecast engine that has been previously saved.
  var _file := TFile.NClass.OpenRead(outputModelPath);
  try
    forecaster := mlContext.Model.Load(_file,  schema);
  finally
    _file.Close;
    _file.Dispose;
  end;

  // We must create a new prediction engine from the persisted model.
  var forecastEngine := forecaster.CreateTimeSeriesEngine<TProductData, TProductUnitTimeSeriesPrediction>(mlContext);

  // Get the prediction; this will include the forecasted product units sold for the next 2 months since this the time period specified in the `horizon` parameter when the forecast estimator was originally created.
  TConsole.NClass.WriteLine();
  TConsole.NClass.WriteLine('** Original prediction **');
  var originalSalesPrediction := forecastEngine.Predict();

  // Compare the units of the first forecasted month to the actual units sold for the next month.
  var predictionMonth: Single := 1;
  if lastMonthProductData.month <> 12 then
    predictionMonth := lastMonthProductData.month + 1;

  var predictionYear: Single := lastMonthProductData.year;
  if predictionMonth >= lastMonthProductData.month then
    predictionMonth := lastMonthProductData.year + 1;

  TConsole.NClass.WriteLine('Product: {0}, Month: {1}, Year: {2} - Real Value (units): {3}, Forecast Prediction (units): {4}',
      [lastMonthProductData.productId, predictionMonth, predictionYear, lastMonthProductData.next, originalSalesPrediction.ForecastedProductUnits[0]]);

  // Get the first forecasted month's confidence interval bounds.
  TConsole.NClass.WriteLine('Confidence interval: [{0} - {1}]', originalSalesPrediction.ConfidenceLowerBound[0], originalSalesPrediction.ConfidenceUpperBound[0]);
  TConsole.NClass.WriteLine();

  // Get the units of the second forecasted month.
  TConsole.NClass.WriteLine('Product: {0}, Month: {1}, Year: {2}, Forecast (units): {3}',
      [lastMonthProductData.productId, lastMonthProductData.month + 2, lastMonthProductData.year, originalSalesPrediction.ForecastedProductUnits[1]]);

  // Get the second forecasted month's confidence interval bounds.
  TConsole.NClass.WriteLine('Confidence interval: [{0} - {1}]', originalSalesPrediction.ConfidenceLowerBound[1], originalSalesPrediction.ConfidenceUpperBound[1]);
  TConsole.NClass.WriteLine();

  // Update the forecasting model with the next month's actual product data to get an updated prediction; this time, only forecast product sales for 1 month ahead.
  TConsole.NClass.WriteLine('** Updated prediction **');
  var updatedSalesPrediction := forecastEngine.Predict(TSampleProductData.MonthlyData[1], 1);

  // Save a checkpoint of the forecasting model.
  forecastEngine.CheckPoint(mlContext, outputModelPath);

  // Get the units of the updated forecast.
  predictionMonth := lastMonthProductData.month + 2;
  if lastMonthProductData.month >= 11 then
    predictionMonth := Trunc(lastMonthProductData.month + 2) mod 12;

  predictionYear := lastMonthProductData.year;
  if predictionMonth < lastMonthProductData.month then
    predictionYear := lastMonthProductData.year + 1;

  TConsole.NClass.WriteLine('Product: {0}, Month: {1}, Year: {2}, Forecast (units): {3}',
      [lastMonthProductData.productId, predictionMonth, predictionYear, updatedSalesPrediction.ForecastedProductUnits[0]]);

  // Get the updated forecast's confidence interval bounds.
  TConsole.NClass.WriteLine('Confidence interval: [{0} - {1}]', updatedSalesPrediction.ConfidenceLowerBound[0], updatedSalesPrediction.ConfidenceUpperBound[0]);
  TConsole.NClass.WriteLine();
end;

/// <summary>
/// Fit and save checkpoint of the model for predicting future product sales.
/// </summary>
/// <param name='mlContext'>ML.NET context.</param>
/// <param name='productId'>Id of the product series to forecast.</param>
/// <param name='dataPath'>Input data file path.</param>
procedure ForecastProductUnits(const mlContext: IMLContextManager; productId: Integer; dataPath: string);
begin
  var productModelPath := TString.NClass.Format('product{0}_month_timeSeriesSSA.zip', productId);

  if (TFile.NClass.Exists(productModelPath)) then
  begin
    TFile.NClass.Delete(productModelPath);
  end;

  var productDataView := LoadData(mlContext, productId, dataPath);
  var singleProductDataSeries := mlContext.Data.CreateEnumerable<TProductData>(productDataView, false);//.OrderBy(p => p.).ThenBy(p => p.month);
//  TArray.Sort<TMLEntity>(singleProductDataSeries, TDelegatedComparer<TMLEntity>.Construct(
//  function(const Left, Right: TMLEntity): Integer
//  begin
//    Result := TComparer<Integer>.Default.Compare(Left.AsType<TProductData>.year, Right.AsType<TProductData>.year);
//  end));

  var lastMonthProductData := singleProductDataSeries.Last;// TMLEnumerableHelper.Last<TMLEntity>(singleProductDataSeries).AsType<TProductData>;

  FitAndSaveModel(mlContext, productDataView, productModelPath);
  TestPrediction(mlContext, lastMonthProductData, productModelPath);
end;

procedure PerformTimeSeriesProductForecasting(const mlContext: IMLContextManager; dataPath: string);
begin
  TConsole.NClass.WriteLine('=============== Forecasting Product Units ===============');

  // Forecast units sold for product with Id == 988.
  var productId := 988;
  ForecastProductUnits(mlContext, productId, dataPath);
end;

end.
