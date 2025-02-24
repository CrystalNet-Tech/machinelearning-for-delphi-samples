unit MNISTConsoleApp;

interface
uses MLContextMgr;

type
  TMNISTConsoleApp = class
  private
    class procedure Train(const mlContext: IMLContextManager);
    class procedure TestSomePredictions(const mlContext: IMLContextManager);
  public
    class procedure Run;
  end;

implementation

uses CrystalNet.Console, MNIST_Models, MLData, ConsoleHelper, System.Generics.Collections, CNCoreClrLib.ExceptionMgr, MLTransforms;

const
  BaseDatasetsRelativePath = '..\..\Data';
  TrianDataRealtivePath = BaseDatasetsRelativePath + '\optdigits-train.csv';
  TestDataRealtivePath = BaseDatasetsRelativePath + '\optdigits-val.csv';
  BaseModelsRelativePath = '..\..\MLModels';
  ModelRelativePath = BaseModelsRelativePath+ '\Model.zip';


{ TMNISTConsoleApp }

class procedure TMNISTConsoleApp.Run;
begin
  var mlContext: IMLContextManager := TMLContextManager.Create;
  Train(mlContext);
  TestSomePredictions(mlContext);

  TConsole.NClass.WriteLine('Hit any key to finish the app');
  TConsole.NClass.ReadKey();
end;

class procedure TMNISTConsoleApp.TestSomePredictions(
  const mlContext: IMLContextManager);
var
  modelInputSchema: IMLDataViewSchema;
  ModelPath: string;
begin
  ModelPath := GetAbsolutePath(ModelRelativePath);
  var trainedModel := mlContext.Model.Load(ModelPath, modelInputSchema);

  // Create prediction engine related to the loaded trained model
  var predEngine := mlContext.Model.CreatePredictionEngine<TInputData, TTOutPutData>(trainedModel);

  var resultprediction1 := predEngine.Predict(SampleMNISTData.MNIST1);

  TConsole.NClass.WriteLine('Actual: 7    Predicted probability:        zero:  {0:0.####}', resultprediction1.Score[0]);
  TConsole.NClass.WriteLine('                                           One :  {0:0.####}', resultprediction1.Score[1]);
  TConsole.NClass.WriteLine('                                           two:   {0:0.####}', resultprediction1.Score[2]);
  TConsole.NClass.WriteLine('                                           three: {0:0.####}', resultprediction1.Score[3]);
  TConsole.NClass.WriteLine('                                           four:  {0:0.####}', resultprediction1.Score[4]);
  TConsole.NClass.WriteLine('                                           five:  {0:0.####}', resultprediction1.Score[5]);
  TConsole.NClass.WriteLine('                                           six:   {0:0.####}', resultprediction1.Score[6]);
  TConsole.NClass.WriteLine('                                           seven: {0:0.####}', resultprediction1.Score[7]);
  TConsole.NClass.WriteLine('                                           eight: {0:0.####}', resultprediction1.Score[8]);
  TConsole.NClass.WriteLine('                                           nine:  {0:0.####}', resultprediction1.Score[9]);
  TConsole.NClass.WriteLine();

  var resultprediction2 := predEngine.Predict(SampleMNISTData.MNIST2);

  TConsole.NClass.WriteLine('Actual: 7     Predicted probability:       zero:  {0:0.####}', resultprediction2.Score[0]);
  TConsole.NClass.WriteLine('                                           One :  {0:0.####}', resultprediction2.Score[1]);
  TConsole.NClass.WriteLine('                                           two:   {0:0.####}', resultprediction2.Score[2]);
  TConsole.NClass.WriteLine('                                           three: {0:0.####}', resultprediction2.Score[3]);
  TConsole.NClass.WriteLine('                                           four:  {0:0.####}', resultprediction2.Score[4]);
  TConsole.NClass.WriteLine('                                           five:  {0:0.####}', resultprediction2.Score[5]);
  TConsole.NClass.WriteLine('                                           six:   {0:0.####}', resultprediction2.Score[6]);
  TConsole.NClass.WriteLine('                                           seven: {0:0.####}', resultprediction2.Score[7]);
  TConsole.NClass.WriteLine('                                           eight: {0:0.####}', resultprediction2.Score[8]);
  TConsole.NClass.WriteLine('                                           nine:  {0:0.####}', resultprediction2.Score[9]);
  TConsole.NClass.WriteLine();

  var resultprediction3 := predEngine.Predict(SampleMNISTData.MNIST3);

  TConsole.NClass.WriteLine('Actual: 9     Predicted probability:       zero:  {0:0.####}', resultprediction3.Score[0]);
  TConsole.NClass.WriteLine('                                           One :  {0:0.####}', resultprediction3.Score[1]);
  TConsole.NClass.WriteLine('                                           two:   {0:0.####}', resultprediction3.Score[2]);
  TConsole.NClass.WriteLine('                                           three: {0:0.####}', resultprediction3.Score[3]);
  TConsole.NClass.WriteLine('                                           four:  {0:0.####}', resultprediction3.Score[4]);
  TConsole.NClass.WriteLine('                                           five:  {0:0.####}', resultprediction3.Score[5]);
  TConsole.NClass.WriteLine('                                           six:   {0:0.####}', resultprediction3.Score[6]);
  TConsole.NClass.WriteLine('                                           seven: {0:0.####}', resultprediction3.Score[7]);
  TConsole.NClass.WriteLine('                                           eight: {0:0.####}', resultprediction3.Score[8]);
  TConsole.NClass.WriteLine('                                           nine:  {0:0.####}', resultprediction3.Score[9]);
  TConsole.NClass.WriteLine();
end;

class procedure TMNISTConsoleApp.Train(const mlContext: IMLContextManager);
var
  TrainDataPath, TestDataPath, ModelPath : string;
begin
  try
    TrainDataPath := GetAbsolutePath(TrianDataRealtivePath);
    TestDataPath := GetAbsolutePath(TestDataRealtivePath);
    ModelPath := GetAbsolutePath(ModelRelativePath);

    // STEP 1: Common data loading configuration
    var trainData := mlContext.Data.LoadFromTextFile(TrainDataPath,
        [TMLTextLoaderColumn.Create('PixelValues', TMLDataKind.dkSingle, 0, 63),
         TMLTextLoaderColumn.Create('Number', TMLDataKind.dkSingle, 64)], ',', False);

    var testData := mlContext.Data.LoadFromTextFile(TestDataPath,
        [TMLTextLoaderColumn.Create('PixelValues', TMLDataKind.dkSingle, 0, 63),
         TMLTextLoaderColumn.Create('Number', TMLDataKind.dkSingle, 64)], ',', False);

    // STEP 2: Common data process configuration with pipeline data transformations
    // Use in-memory cache for small/medium datasets to lower training time. Do NOT use it (remove .AppendCacheCheckpoint()) when handling very large datasets.
    var dataProcessPipeline := mlContext.Transforms.Conversion.MapValueToKey('Label', 'Number', 1000000, TMLKeyOrdinality.koByValue)
                                  .Append(mlContext.Transforms.Concatenate('Features', ['PixelValues'])
                                  .AppendCacheCheckpoint(mlContext));

    // STEP 3: Set the training algorithm, then create and config the modelBuilder
    var trainer := mlContext.MulticlassClassification.Trainers.SdcaMaximumEntropy('Label', 'Features');
    var trainingPipeline := dataProcessPipeline.Append(trainer).Append(mlContext.Transforms.Conversion.MapKeyToValue('Number','Label'));

    // STEP 4: Train the model fitting to the DataSet

    TConsole.NClass.WriteLine('=============== Training the model ===============');
    var trainedModel := trainingPipeline.Fit(trainData);

    TConsole.NClass.WriteLine('===== Evaluating Model''s accuracy with Test data =====');
    var predictions := trainedModel.Transform(testData);
    var metrics := mlContext.MulticlassClassification.Evaluate(predictions, 'Number', 'Score');

    PrintMultiClassClassificationMetrics(trainer.ToString(), metrics);

    mlContext.Model.Save(trainedModel, trainData.Schema, ModelPath);

    TConsole.NClass.WriteLine('The model is saved to {0}', ModelPath);
  except
    on ex: ECoreClrException do
      TConsole.NClass.WriteLine(ex.ToString());
  end;
end;

end.
