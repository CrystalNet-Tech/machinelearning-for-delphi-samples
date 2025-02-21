unit SentimentAnalysisConsoleApp;

interface

type
  TSentimentAnalysisConsoleApp = class
  public
    class procedure Run;
  end;

implementation

uses
  SysUtils, MLContextMgr, MLData, SentimentAnalysis_Models, CrystalNet.Runtime, System.TypInfo, ConsoleHelper, CNCoreClrLib.ExceptionMgr;

const
  BaseDatasetsRelativePath = '..\..\Data';
  DataRelativePath = BaseDatasetsRelativePath + '\wikiDetoxAnnotated40kRows.tsv';
  BaseModelsRelativePath = '..\..\MLModels';
  ModelRelativePath = BaseModelsRelativePath + '\SentimentModel.zip';


{ TSentimentAnalysisConsoleApp }

class procedure TSentimentAnalysisConsoleApp.Run;
var
  mlContext: IMLContextManager;
  dataView: IMLDataView;
  trainTestSplit: IMLTrainTestData;
  trainingData, testData: IMLDataView;
  trainedModel: IMLTransformer;
  ModelPath, DataPath: string;
begin
  try
    ModelPath := GetAbsolutePath(ModelRelativePath);
    DataPath := GetAbsolutePath(DataRelativePath);

  // Create MLContext to be shared across the model creation workflow objects
  // Set a random seed for repeatable/deterministic results across multiple trainings.
    mlContext := TMLContextManager.Create;
    // STEP 1: Common data loading configuration
     dataView := mlContext.Data.LoadFromTextFile<TSentimentIssue>(DataPath, '	', True);
    trainTestSplit := mlContext.Data.TrainTestSplit(dataView, 0.2);
    trainingData := trainTestSplit.TrainSet;
    testData := trainTestSplit.TestSet;

    // STEP 2: Common data process configuration with pipeline data transformations
    var dataProcessPipeline := mlContext.Transforms.Text.FeaturizeText('Features', 'Text');

    // STEP 3: Set the training algorithm, then create and config the modelBuilder
    var trainer := mlContext.BinaryClassification.Trainers.SdcaLogisticRegression('Label', 'Features');
    var trainingPipeline := dataProcessPipeline.Append(trainer);

    // STEP 4: Train the model fitting to the DataSet
    trainedModel := trainingPipeline.Fit(trainingData);

    // STEP 5: Evaluate the model and show accuracy stats
    var predictions := trainedModel.Transform(testData);
    var metrics := mlContext.BinaryClassification.Evaluate(predictions, 'Label', 'Score');

    ConsoleHelper.PrintBinaryClassificationMetrics(trainer.ToString(), metrics);

    // STEP 6: Save/persist the trained model to a .ZIP file
    mlContext.Model.Save(trainedModel, trainingData.Schema, ModelPath);

    WriteLn('The model is saved to %s', ModelPath);

    // TRY IT: Make a single test prediction, loading the model from .ZIP file
    var sampleStatement := TSentimentIssue.Create;
    try
      sampleStatement.Text := 'I love this movie!';

      // Create prediction engine related to the loaded trained model
      var predEngine := mlContext.Model.CreatePredictionEngine<TSentimentIssue, TSentimentPrediction>(trainedModel);

      // Score
      var resultprediction := predEngine.Predict(sampleStatement);

      Writeln('=============== Single Prediction  ===============');

      var sample := '';
      if resultprediction.Prediction then
        sample := 'Toxic'
      else
        sample := 'Non Toxic';

      Writeln('Text: '+ sampleStatement.Text + ' | Prediction: ' +  sample + ' sentiment | Probability of being toxic: '+ FloatToStr(resultprediction.Probability));
      Writeln('================End of Process.Hit any key to exit==================================');
    finally
      sampleStatement.Free;
    end;
  except
    on E: ECoreClrException do
    begin
      Writeln(E.ToString);
      Readln;
    end;
  end;
end;

//class procedure TSentimentAnalysisConsoleApp.Run;
////var
////  mlContext: TMLContextManager;
////  dataView: IIDataView;
////  trainTestSplit: ITrainTestData;
////  trainingData, testData: IIDataView;
////  trainedModel: IITransformer;
//begin
////  // Create MLContext to be shared across the model creation workflow objects
////  // Set a random seed for repeatable/deterministic results across multiple trainings.
////  mlContext := TMLContextManager.Create;
////  try
////    // STEP 1: Common data loading configuration
////    dataView := mlContext.Data.LoadFromTextFile<TSentimentIssue>(DataPath, '	', True);
////    trainTestSplit := mlContext.Data.TrainTestSplit(dataView, 0.2);
////    trainingData := trainTestSplit.TrainSet;
////    testData := trainTestSplit.TestSet;
////
////    // STEP 2: Common data process configuration with pipeline data transformations
////    var dataProcessPipeline := mlContext.Transforms.Text.FeaturizeText('Features', 'Text');
////
////    // STEP 3: Set the training algorithm, then create and config the modelBuilder
////    var trainer := mlContext.BinaryClassification.Trainers.SdcaLogisticRegression('Label', 'Features');
////    var trainingPipeline := TMLPipelineExtension.Append<ITextFeaturizingEstimator, ISdcaLogisticRegressionBinaryTrainer>(dataProcessPipeline, trainer);
////
////    // STEP 4: Train the model fitting to the DataSet
////    trainedModel := trainingPipeline.Fit(trainingData);
////
////    // STEP 5: Evaluate the model and show accuracy stats
////    var predictions := trainedModel.Transform(testData);
//////      var metrics := mlContext.BinaryClassification.Evaluate(predictions, 'Label', 'Score');
//////  ConsoleHelper.PrintBinaryClassificationMetrics(trainer.ToString(), metrics);
////
////    // STEP 6: Save/persist the trained model to a .ZIP file
////    mlContext.Model.Save(trainedModel, trainingData.Schema, ModelPath);
////
////    WriteLn('The model is saved to %s', ModelPath);
////
////    // TRY IT: Make a single test prediction, loading the model from .ZIP file
////    var sampleStatement := TSentimentIssue.Create;
////    try
////      sampleStatement.Text := 'I love this movie!';
////      // Create prediction engine related to the loaded trained model
////      var predEngine := mlContext.Model.CreatePredictionEngine<TSentimentIssue, TSentimentPrediction>(trainedModel);
////
////      // Score
////      var resultprediction := predEngine.Predict(sampleStatement);
////
////      Writeln('=============== Single Prediction  ===============');
////
////      var sample := '';
////      if TConvert.NClass.ToBoolean(resultprediction.Prediction) then
////        sample := 'Toxic'
////      else
////        sample := 'Non Toxic';
////
////      Writeln('Text: '+ sampleStatement.Text + ' | Prediction: ' +  sample + ' sentiment | Probability of being toxic: '+ FloatToStr(resultprediction.Probability));
////      Writeln('================End of Process.Hit any key to exit==================================');
////    finally
////      sampleStatement.Free;
////    end;
////  finally
////    mlContext.Free;
////  end;
//end;

end.
