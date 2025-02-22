unit RegressionProductModelHelper;

interface
uses MLContextMgr;


/// <summary>
/// Train and save model for predicting the next month's product unit sales
/// </summary>
/// <param name='dataPath'>Input training file path</param>
/// <param name='outputModelPath'>Trained model path</param>
procedure TrainAndSaveModel(const mlContext: IMLContextManager; dataPath: string; outputModelPath: string = 'product_month_fastTreeTweedie.zip');

/// <summary>
/// Build model for predicting next month's product unit sales using Learning Pipelines API
/// </summary>
/// <param name='dataPath'>Input training file path</param>
procedure CreateProductModelUsingPipeline(const mlContext: IMLContextManager; dataPath: string; outputModelPath: string);

/// <summary>
/// Predict samples using saved model
/// </summary>
/// <param name='outputModelPath'>Model file path</param>
procedure TestPrediction(const mlContext: IMLContextManager; outputModelPath: string = 'product_month_fastTreeTweedie.zip');

implementation

uses CrystalNet.IO.FileSystem, ForecastingSales_Models, ConsoleHelperExt, CrystalNet.Console, ConsoleHelper,
  MLData, MLTransforms, SampleProductData;

procedure TrainAndSaveModel(const mlContext: IMLContextManager; dataPath: string; outputModelPath: string);
begin
  if (TFile.NClass.Exists(outputModelPath)) then
  begin
    TFile.NClass.Delete(outputModelPath);
  end;

  CreateProductModelUsingPipeline(mlContext, dataPath, outputModelPath);
end;

procedure CreateProductModelUsingPipeline(const mlContext: IMLContextManager; dataPath: string; outputModelPath: string);
begin
  ConsoleWriteHeader(['Training product forecasting Regression model']);

  var trainingDataView := mlContext.Data.LoadFromTextFile<TProductData>(dataPath, ',', True);

  var trainer := mlContext.Regression.Trainers.FastTreeTweedie('Label', 'Features');

  var trainingPipeline := mlContext.Transforms.Concatenate('NumFeatures', ['year', 'month', 'units', 'avg', 'count', 'max', 'min', 'prev'])
      .Append(mlContext.Transforms.Categorical.OneHotEncoding('CatFeatures', 'productId'))
      .Append(mlContext.Transforms.Concatenate('Features', ['NumFeatures', 'CatFeatures']))
      .Append(mlContext.Transforms.CopyColumns('Label', 'next'))
      .Append(trainer);

  // Cross-Validate with single dataset (since we don't have two datasets, one for training and for evaluate)
  // in order to evaluate and get the model's accuracy metrics
  TConsole.NClass.WriteLine('=============== Cross-validating to get Regression model''s accuracy metrics ===============');
  var crossValidationResults := mlContext.Regression.CrossValidate(trainingDataView, trainingPipeline, 6, 'Label');

  PrintRegressionFoldsAverageMetrics(trainer.ToString(), crossValidationResults);

  // Train the model.
  var model := trainingPipeline.Fit(trainingDataView);

  // Save the model for later comsumption from end-user apps.
  mlContext.Model.Save(model, trainingDataView.Schema, outputModelPath);
end;

procedure TestPrediction(const mlContext: IMLContextManager; outputModelPath: string);
var
  trainedModel: IMLTransformer;
  modelInputSchema: IMLDataViewSchema;
begin
  ConsoleWriteHeader(['Testing Product Unit Sales Forecast Regression model']);

  // Read the model that has been previously saved by the method SaveModel.

  var stream := TFile.NClass.OpenRead(outputModelPath);
  try
    trainedModel := mlContext.Model.Load(stream, modelInputSchema);

  finally
    stream.Dispose;
    stream := nil;
  end;

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
end;

end.
