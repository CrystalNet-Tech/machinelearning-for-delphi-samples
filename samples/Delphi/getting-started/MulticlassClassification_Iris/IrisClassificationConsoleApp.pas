unit IrisClassificationConsoleApp;

interface
uses MLContextMgr;

type
  TIrisClassificationConsoleApp = class
  private
    class procedure BuildTrainEvaluateAndSaveModel(const mlContext: IMLContextManager);
    class procedure TestSomePredictions(const mlContext: IMLContextManager);
  public
    class procedure Run;
  end;


implementation

uses CrystalNet.Console, IrisClassification_Models, MLData, ConsoleHelper, System.Generics.Collections;

const
  BaseDatasetsRelativePath = '..\..\Data';
  TrainDataRelativePath = BaseDatasetsRelativePath + '\iris-train.txt';
  TestDataRelativePath = BaseDatasetsRelativePath + '\iris-test.txt';
  BaseModelsRelativePath = '..\..\MLModels';
  ModelRelativePath = BaseModelsRelativePath+ '\IrisClassificationModel.zip';

{ TIrisClassificationConsoleApp }

class procedure TIrisClassificationConsoleApp.Run;
begin
  // Create MLContext to be shared across the model creation workflow objects
  // Set a random seed for repeatable/deterministic results across multiple trainings.
  var mlContext: IMLContextManager := TMLContextManager.Create();

  //1.
  BuildTrainEvaluateAndSaveModel(mlContext);

  //2.
  TestSomePredictions(mlContext);

  TConsole.NClass.WriteLine('=============== End of process, hit any key to finish ===============');
  TConsole.NClass.ReadKey();
end;

class procedure TIrisClassificationConsoleApp.BuildTrainEvaluateAndSaveModel(
  const mlContext: IMLContextManager);
var
  TrainDataPath, TestDataPath, ModelPath : string;
begin
  TrainDataPath := GetAbsolutePath(TrainDataRelativePath);
  TestDataPath := GetAbsolutePath(TestDataRelativePath);
  ModelPath := GetAbsolutePath(ModelRelativePath);

  // STEP 1: Common data loading configuration
  var trainingDataView := mlContext.Data.LoadFromTextFile<TIrisData>(TrainDataPath, #9, true);
  var testDataView := mlContext.Data.LoadFromTextFile<TIrisData>(TestDataPath, #9, true);


  // STEP 2: Common data process configuration with pipeline data transformations
  var dataProcessPipeline := mlContext.Transforms.Conversion.MapValueToKey('KeyColumn', 'Label')
                                                .Append(mlContext.Transforms.Concatenate('Features', ['SepalLength', 'SepalWidth', 'PetalLength',  'PetalWidth'])
                                                .AppendCacheCheckpoint(mlContext));
                                               // Use in-memory cache for small/medium datasets to lower training time.
                                               // Do NOT use it (remove .AppendCacheCheckpoint()) when handling very large datasets.

  // STEP 3: Set the training algorithm, then append the trainer to the pipeline
  var trainer := mlContext.MulticlassClassification.Trainers.SdcaMaximumEntropy('KeyColumn', 'Features')
                                    .Append(mlContext.Transforms.Conversion.MapKeyToValue('Label' , 'KeyColumn'));

  var trainingPipeline := dataProcessPipeline.Append(trainer);

  // STEP 4: Train the model fitting to the DataSet
  TConsole.NClass.WriteLine('=============== Training the model ===============');
  var trainedModel := trainingPipeline.Fit(trainingDataView);

  // STEP 5: Evaluate the model and show accuracy stats
  TConsole.NClass.WriteLine('===== Evaluating Model''s accuracy with Test data =====');
  var predictions := trainedModel.Transform(testDataView);
  var metrics := mlContext.MulticlassClassification.Evaluate(predictions, 'Label', 'Score');

  PrintMultiClassClassificationMetrics(trainer.ToString(), metrics);

  // STEP 6: Save/persist the trained model to a .ZIP file
  mlContext.Model.Save(trainedModel, trainingDataView.Schema, ModelPath);
  TConsole.NClass.WriteLine('The model is saved to {0}', ModelPath);
end;

class procedure TIrisClassificationConsoleApp.TestSomePredictions(
  const mlContext: IMLContextManager);
var
  modelInputSchema: IMLDataViewSchema;
  keys: MLVBuffer<Variant{Single}>;
  IrisFlowers: TDictionary<Single, string>;
  ModelPath : string;
begin
  ModelPath := GetAbsolutePath(ModelRelativePath);

  //Test Classification Predictions with some hard-coded samples
  var trainedModel := mlContext.Model.Load(ModelPath, modelInputSchema);

  // Create prediction engine related to the loaded trained model
  var predEngine := mlContext.Model.CreatePredictionEngine<TIrisData, TIrisPrediction>(trainedModel);

  // During prediction we will get Score column with 3 float values.
  // We need to find way to map each score to original label.
  // In order to do that we need to get TrainingLabelValues from Score column.
  // TrainingLabelValues on top of Score column represent original labels for i-th value in Score array.
  // Let's look how we can convert key value for PredictedLabel to original labels.
  // We need to read KeyValues for 'PredictedLabel' column.
  keys := nil;
  predEngine.OutputSchema['PredictedLabel'].GetKeyValues(TypeInfo(Single), keys);

  var labelsArray: TArray<Single> := keys.DenseValues().Cast<Single>.ToArray;

  // Since we apply MapValueToKey estimator with default parameters, key values
  // depends on order of occurence in data file. Which is 'Iris-setosa', 'Iris-versicolor', 'Iris-virginica'
  // So if we have Score column equal to [0.2, 0.3, 0.5] that's mean what score for
  // Iris-setosa is 0.2
  // Iris-versicolor is 0.3
  // Iris-virginica is 0.5.
  //Add a dictionary to map the above float values to strings.
  IrisFlowers := TDictionary<Single, string>.Create();
  IrisFlowers.Add(0, 'Setosa');
  IrisFlowers.Add(1, 'versicolor');
  IrisFlowers.Add(2, 'virginica');

  TConsole.NClass.WriteLine('=====Predicting using model====');
  //Score sample 1
  var resultprediction1 := predEngine.Predict(SampleIrisData.Iris1);

  TConsole.NClass.WriteLine('Actual: setosa.     Predicted label and score:  {0}: {1:0.####}', IrisFlowers[labelsArray[0]], resultprediction1.Score[0]);
  TConsole.NClass.WriteLine('                                                {0}: {1:0.####}', IrisFlowers[labelsArray[1]], resultprediction1.Score[1]);
  TConsole.NClass.WriteLine('                                                {0}: {1:0.####}', IrisFlowers[labelsArray[2]], resultprediction1.Score[2]);
  TConsole.NClass.WriteLine();

  //Score sample 2
  var resultprediction2 := predEngine.Predict(SampleIrisData.Iris2);

  TConsole.NClass.WriteLine('Actual: Virginica.   Predicted label and score:  {0}: {1:0.####}', IrisFlowers[labelsArray[0]], resultprediction2.Score[0]);
  TConsole.NClass.WriteLine('                                                 {0}: {1:0.####}', IrisFlowers[labelsArray[1]], resultprediction2.Score[1]);
  TConsole.NClass.WriteLine('                                                 {0}: {1:0.####}', IrisFlowers[labelsArray[2]], resultprediction2.Score[2]);
  TConsole.NClass.WriteLine();

  //Score sample 3
  var resultprediction3 := predEngine.Predict(SampleIrisData.Iris3);

  TConsole.NClass.WriteLine('Actual: Versicolor.   Predicted label and score: {0}: {1:0.####}', IrisFlowers[labelsArray[0]], resultprediction3.Score[0]);
  TConsole.NClass.WriteLine('                                                 {0}: {1:0.####}', IrisFlowers[labelsArray[1]], resultprediction3.Score[1]);
  TConsole.NClass.WriteLine('                                                 {0}: {1:0.####}', IrisFlowers[labelsArray[2]], resultprediction3.Score[2]);
  TConsole.NClass.WriteLine();
end;

end.
