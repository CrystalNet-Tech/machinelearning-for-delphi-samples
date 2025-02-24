unit IrisClusteringConsoleApp;

interface

uses MLContextMgr;

type
  TIrisClassificationConsoleApp = class
  public
    class procedure Run;
  end;


implementation

uses CrystalNet.Console, IrisClustering_Models, MLData, ConsoleHelper, System.Generics.Collections;

const
  BaseDatasetsRelativePath = '..\..\Data';
  DataSetRealtivePath = BaseDatasetsRelativePath + '\iris-full.txt';
  BaseModelsRelativePath = '..\..\MLModels';
  ModelRelativePath = BaseModelsRelativePath+ '\IrisModel.zip';

{ TIrisClassificationConsoleApp }

class procedure TIrisClassificationConsoleApp.Run;
var
  DataPath, ModelPath : string;
  modelInputSchema: IMLDataViewSchema;
begin
  DataPath := GetAbsolutePath(DataSetRealtivePath);
  ModelPath := GetAbsolutePath(ModelRelativePath);

  //Create the MLContext to share across components for deterministic results
  var mlContext: IMLContextManager := TMLContextManager.Create(0); ////Seed set to any number so you have a deterministic environment


  // STEP 1: Common data loading configuration
  var TextLoaderColumns: TArray<IMLTextLoaderColumn> :=  [
                                                          TMLTextLoaderColumn.Create('Label', TMLDataKind.dkSingle, 0),
                                                          TMLTextLoaderColumn.Create('SepalLength', TMLDataKind.dkSingle, 1),
                                                          TMLTextLoaderColumn.Create('SepalWidth', TMLDataKind.dkSingle, 2),
                                                          TMLTextLoaderColumn.Create('PetalLength', TMLDataKind.dkSingle, 3),
                                                          TMLTextLoaderColumn.Create('PetalWidth', TMLDataKind.dkSingle, 4)
                                                         ];

  var fullData: IMLDataView := mlContext.Data.LoadFromTextFile(DataPath, TextLoaderColumns, True, #9{'\t'});

  //Split dataset in two parts: TrainingDataset (80%) and TestDataset (20%)
  var trainTestData := mlContext.Data.TrainTestSplit(fullData, 0.2);
  var trainingDataView := trainTestData.TrainSet;
  var testingDataView := trainTestData.TestSet;

  //STEP 2: Process data transformations in pipeline
  var dataProcessPipeline := mlContext.Transforms.Concatenate('Features', ['SepalLength', 'SepalWidth', 'PetalLength', 'PetalWidth']);

  // (Optional) Peek data in training DataView after applying the ProcessPipeline's transformations
  ConsoleHelper.PeekDataViewInConsole(mlContext, trainingDataView, dataProcessPipeline, 10);
  ConsoleHelper.PeekVectorColumnDataInConsole(mlContext, 'Features', trainingDataView, dataProcessPipeline, 10);

  // STEP 3: Create and train the model
  var trainer := mlContext.Clustering.Trainers.KMeans('Features', '', 3);
  var trainingPipeline := dataProcessPipeline.Append(trainer);
  var trainedModel := trainingPipeline.Fit(trainingDataView);

  // STEP4: Evaluate accuracy of the model
  var predictions: IMLDataView := trainedModel.Transform(testingDataView);
  var metrics := mlContext.Clustering.Evaluate(predictions, '', 'Score', 'Features');

  ConsoleHelper.PrintClusteringMetrics(trainer.ToString(), metrics);

  // STEP5: Save/persist the model as a .ZIP file
  mlContext.Model.Save(trainedModel, trainingDataView.Schema, ModelPath);

  TConsole.NClass.WriteLine('=============== End of training process ===============');

  TConsole.NClass.WriteLine('=============== Predict a cluster for a single case (Single Iris data sample) ===============');

  // Test with one sample text
  var sampleIrisData := TIrisData.Create;
  with sampleIrisData do
  begin
    SepalLength := 3.3;
    SepalWidth := 1.6;
    PetalLength := 0.2;
    PetalWidth := 5.1;
  end;

  var model: IMLTransformer := mlContext.Model.Load(ModelPath, modelInputSchema);
  // Create prediction engine related to the loaded trained model
  var predEngine := mlContext.Model.CreatePredictionEngine<TIrisData, TIrisPrediction>(model);

  //Score
  var resultprediction := predEngine.Predict(sampleIrisData);

  TConsole.NClass.WriteLine('Cluster assigned for setosa flowers: {0}', resultprediction.SelectedClusterId);

  TConsole.NClass.WriteLine('=============== End of process, hit any key to finish ===============');
  TConsole.NClass.ReadKey();
end;


end.
