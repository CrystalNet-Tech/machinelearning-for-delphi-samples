unit BikeSharingDemandConsoleApp;

interface
uses MLContextMgr;

type
  TBikeSharingDemandConsoleApp= class
  public
    class procedure Run;
  end;

implementation

uses CrystalNet.Console, BikeSharingDemand_Models, MLData, ConsoleHelper,
     System.Generics.Collections, CNCoreClrLib.ExceptionMgr, MLTransforms,
     BikeSharingDemand_ModelScoringTester;

const
  ModelsLocation = '..\..\MLModels';
  DatasetsLocation = '..\..\Data';
  TrainingDataRelativePath = DatasetsLocation + '\hour_train.csv';
  TestDataRelativePath = DatasetsLocation + '\hour_test.csv';


{ TBikeSharingDemandConsoleApp }

class procedure TBikeSharingDemandConsoleApp.Run;
var
  TrainingDataLocation, TestDataLocation : string;
  regressionLearners: TDictionary<string, IMLEstimatorOfITransformer>;
  modelInputSchema: IMLDataViewSchema;
begin
  TrainingDataLocation := GetAbsolutePath(TrainingDataRelativePath);
  TestDataLocation := GetAbsolutePath(TestDataRelativePath);

  // Create MLContext to be shared across the model creation workflow objects
  // Set a random seed for repeatable/deterministic results across multiple trainings.
  var mlContext: IMLContextManager := TMLContextManager.Create;

  // 1. Common data loading configuration
  var trainingDataView := mlContext.Data.LoadFromTextFile<TDemandObservation>(TrainingDataLocation, true, ',');
  var testDataView := mlContext.Data.LoadFromTextFile<TDemandObservation>(TestDataLocation, true, ',');

  // 2. Common data pre-process with pipeline data transformations

  // Concatenate all the numeric columns into a single features column
  var dataProcessPipeline := mlContext.Transforms.Concatenate('Features',
                                           ['Season', 'Year', 'Month',
                                           'Hour', 'Holiday', 'Weekday',
                                           'WorkingDay', 'Weather', 'Temperature',
                                           'NormalizedTemperature', 'Humidity', 'Windspeed'])
                               .AppendCacheCheckpoint(mlContext);
                              // Use in-memory cache for small/medium datasets to lower training time.
                              // Do NOT use it (remove .AppendCacheCheckpoint()) when handling very large datasets.

  // (Optional) Peek data in training DataView after applying the ProcessPipeline's transformations
  ConsoleHelper.PeekDataViewInConsole(mlContext, trainingDataView, dataProcessPipeline, 10);
  ConsoleHelper.PeekVectorColumnDataInConsole(mlContext, 'Features', trainingDataView, dataProcessPipeline, 10);

  // Definition of regression trainers/algorithms to use
  //var regressionLearners = new (string name, IEstimator<ITransformer> value)[]
  regressionLearners := TDictionary<string, IMLEstimatorOfITransformer>.Create;
  try
    regressionLearners.Add('FastTree', mlContext.Regression.Trainers.FastTree());
    regressionLearners.Add('Poisson', mlContext.Regression.Trainers.LbfgsPoissonRegression());
    regressionLearners.Add('SDCA', mlContext.Regression.Trainers.Sdca());
    regressionLearners.Add('FastTreeTweedie', mlContext.Regression.Trainers.FastTreeTweedie());
    //Other possible learners that could be included
    //...FastForestRegressor...
    //...GeneralizedAdditiveModelRegressor...
    //...OnlineGradientDescent... (Might need to normalize the features first)

    // 3. Phase for Training, Evaluation and model file persistence
    // Per each regression trainer: Train, Evaluate, and Save a different model
    for var trainer: TPair<string, IMLEstimatorOfITransformer> in regressionLearners do
    begin
      TConsole.NClass.WriteLine('=============== Training the current model ===============');
      var trainingPipeline := dataProcessPipeline.Append(trainer.value);
      var trainedModel := trainingPipeline.Fit(trainingDataView);

      TConsole.NClass.WriteLine('===== Evaluating Model''s accuracy with Test data =====');
      var predictions: IMLDataView := trainedModel.Transform(testDataView);
      var metrics := mlContext.Regression.Evaluate(predictions, 'Label', 'Score');
      ConsoleHelper.PrintRegressionMetrics(trainer.value.ToString(), metrics);

      //Save the model file that can be used by any application
      var modelRelativeLocation := ModelsLocation + '\' + trainer.Key + 'Model.zip';
      var modelPath := GetAbsolutePath(modelRelativeLocation);
      mlContext.Model.Save(trainedModel, trainingDataView.Schema, modelPath);
      TConsole.NClass.WriteLine('The model is saved to {0}', modelPath);
    end;

    // 4. Try/test Predictions with the created models
    // The following test predictions could be implemented/deployed in a different application (production apps)
    // that's why it is seggregated from the previous loop
    // For each trained model, test 10 predictions
    for var learner: TPair<string, IMLEstimatorOfITransformer> in regressionLearners do
    begin
      //Load current model from .ZIP file
      var modelRelativeLocation := ModelsLocation + '\' + learner.Key + 'Model.zip';
      var modelPath := GetAbsolutePath(modelRelativeLocation);

      var trainedModel: IMLTransformer := mlContext.Model.Load(modelPath, modelInputSchema);

      // Create prediction engine related to the loaded trained model
      var predEngine := mlContext.Model.CreatePredictionEngine<TDemandObservation, TDemandPrediction>(trainedModel);

      TConsole.NClass.WriteLine('================== Visualize/test 10 predictions for model {0}Model.zip ==================', learner.Key);
      //Visualize 10 tests comparing prediction with actual/observed values from the test dataset
      TModelScoringTester.VisualizeSomePredictions(mlContext ,learner.Key, TestDataLocation, predEngine, 10);
    end;

    ConsoleHelper.ConsolePressAnyKey();

  finally
    regressionLearners.Free;
  end;
end;

end.
