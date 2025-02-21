unit HeartDiseaseDetectionConsoleApp;

interface
uses MLContextMgr;

type
  THeartDiseaseDetectionConsoleApp = class
  private
    class procedure BuildTrainEvaluateAndSaveModel(const mlContext: IMLContextManager);
    class procedure TestPrediction(const mlContext: IMLContextManager);
  public
    class procedure Run;
  end;


implementation

uses CrystalNet.Console, HeartDiseaseDetection_Models, MLData, ConsoleHelper;

const
  BaseDatasetsRelativePath = '..\..\Data';
  TrainDataRelativePath = BaseDatasetsRelativePath + '\HeartTraining.csv';
  TestDataRelativePath = BaseDatasetsRelativePath + '\HeartTest.csv';
  BaseModelsRelativePath = '..\..\MLModels';
  ModelRelativePath = BaseModelsRelativePath + '\HeartClassification.zip';

//  TrainDataPath = 'C:\CrystalNet\CrystalNet Projects\Delphi Projects\dotNetCore4Delphi\AddOns\MLDotNet\Delphi\Projects\MLDotNetCore_Examples\HeartDiseaseDetection\Data\HeartTraining.csv';
//  TestDataPath = 'C:\CrystalNet\CrystalNet Projects\Delphi Projects\dotNetCore4Delphi\AddOns\MLDotNet\Delphi\Projects\MLDotNetCore_Examples\HeartDiseaseDetection\Data\HeartTest.csv';
//  ModelPath = 'C:\CrystalNet\CrystalNet Projects\Delphi Projects\dotNetCore4Delphi\AddOns\MLDotNet\Delphi\Projects\MLDotNetCore_Examples\HeartDiseaseDetection\MLModels\HeartClassification.zip';


{ THeartDiseaseDetectionConsoleApp }

class procedure THeartDiseaseDetectionConsoleApp.Run;
begin
  var mlContext := TMLContextManager.Create();
  BuildTrainEvaluateAndSaveModel(mlContext);

  TestPrediction(mlContext);

  TConsole.NClass.WriteLine('=============== End of process, hit any key to finish ===============');
  TConsole.NClass.ReadKey();
end;

class procedure THeartDiseaseDetectionConsoleApp.BuildTrainEvaluateAndSaveModel(
  const mlContext: IMLContextManager);
var
  trainedModel: IMLTransformer;
  TrainDataPath, TestDataPath, ModelPath: string;
begin
  TrainDataPath := GetAbsolutePath(TrainDataRelativePath);
  TestDataPath := GetAbsolutePath(TestDataRelativePath);
  ModelPath := GetAbsolutePath(ModelRelativePath);

  // STEP 1: Common data loading configuration
  var trainingDataView := mlContext.Data.LoadFromTextFile<THeartData>(TrainDataPath, ';', true);
  var testDataView := mlContext.Data.LoadFromTextFile<THeartData>(TestDataPath, ';', true);

  // STEP 2: Concatenate the features and set the training algorithm
  var pipeline := mlContext.Transforms.Concatenate('Features', ['Age', 'Sex', 'Cp', 'TrestBps', 'Chol', 'Fbs', 'RestEcg', 'Thalac', 'Exang', 'OldPeak', 'Slope', 'Ca', 'Thal'])
      .Append(mlContext.BinaryClassification.Trainers.FastTree('Label', 'Features'));

  TConsole.NClass.WriteLine('=============== Training the model ===============');
  trainedModel := pipeline.Fit(trainingDataView);
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('=============== Finish the train model. Push Enter ===============');
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('');

  TConsole.NClass.WriteLine('===== Evaluating Model''s accuracy with Test data =====');
  var predictions := trainedModel.Transform(testDataView);

  var metrics := mlContext.BinaryClassification.Evaluate(predictions, 'Label', 'Score');

  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('************************************************************');
  TConsole.NClass.WriteLine('*       Metrics for {0} binary classification model      ', trainedModel.ToString());
  TConsole.NClass.WriteLine('*-----------------------------------------------------------');
  TConsole.NClass.WriteLine('*       Accuracy: {0:P2}', metrics.Accuracy);
  TConsole.NClass.WriteLine('*       Area Under Roc Curve:      {0:P2}', metrics.AreaUnderRocCurve);
  TConsole.NClass.WriteLine('*       Area Under PrecisionRecall Curve:  {0:P2}', metrics.AreaUnderPrecisionRecallCurve);
  TConsole.NClass.WriteLine('*       F1Score:  {0:P2}', metrics.F1Score);
  TConsole.NClass.WriteLine('*       LogLoss:  {0:#.##}', metrics.LogLoss);
  TConsole.NClass.WriteLine('*       LogLossReduction:  {0:#.##}', metrics.LogLossReduction);
  TConsole.NClass.WriteLine('*       PositivePrecision:  {0:#.##}', metrics.PositivePrecision);
  TConsole.NClass.WriteLine('*       PositiveRecall:  {0:#.##}', metrics.PositiveRecall);
  TConsole.NClass.WriteLine('*       NegativePrecision:  {0:#.##}', metrics.NegativePrecision);
  TConsole.NClass.WriteLine('*       NegativeRecall:  {0:P2}', metrics.NegativeRecall);
  TConsole.NClass.WriteLine('************************************************************');
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('');

  TConsole.NClass.WriteLine('=============== Saving the model to a file ===============');
  mlContext.Model.Save(trainedModel, trainingDataView.Schema, ModelPath);
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('=============== Model Saved ============= ');
end;

class procedure THeartDiseaseDetectionConsoleApp.TestPrediction(
  const mlContext: IMLContextManager);
var
  trainedModel: IMLTransformer;
  modelInputSchema: IMLDataViewSchema;
  heartData: THeartData;
  ModelPath: string;
begin
  ModelPath := GetAbsolutePath(ModelRelativePath);
  trainedModel := mlContext.Model.Load(ModelPath, modelInputSchema);

  // Create prediction engine related to the loaded trained model
  var predictionEngine := mlContext.Model.CreatePredictionEngine<THeartData, THeartPrediction>(trainedModel);

  for heartData in HeartSampleData.heartDataList do
  begin
    var prediction := predictionEngine.Predict(heartData);

    TConsole.NClass.WriteLine('=============== Single Prediction  ===============');
    TConsole.NClass.WriteLine('Age: {0} ', heartData.Age);
    TConsole.NClass.WriteLine('Sex: {0} ', heartData.Sex);
    TConsole.NClass.WriteLine('Cp: {0} ', heartData.Cp);
    TConsole.NClass.WriteLine('TrestBps: {0} ', heartData.TrestBps);
    TConsole.NClass.WriteLine('Chol: {0} ', heartData.Chol);
    TConsole.NClass.WriteLine('Fbs: {0} ', heartData.Fbs);
    TConsole.NClass.WriteLine('RestEcg: {0} ', heartData.RestEcg);
    TConsole.NClass.WriteLine('Thalac: {0} ', heartData.Thalac);
    TConsole.NClass.WriteLine('Exang: {0} ', heartData.Exang);
    TConsole.NClass.WriteLine('OldPeak: {0} ', heartData.OldPeak);
    TConsole.NClass.WriteLine('Slope: {0} ', heartData.Slope);
    TConsole.NClass.WriteLine('Ca: {0} ', heartData.Ca);
    TConsole.NClass.WriteLine('Thal: {0} ', heartData.Thal);
    TConsole.NClass.WriteLine('Prediction Value: {0} ', prediction.Prediction);
    var predictionText := 'Not present disease';
    if prediction.Prediction then
      predictionText := 'A disease could be present';

    TConsole.NClass.WriteLine('Prediction: {0} ', predictionText);
    TConsole.NClass.WriteLine('Probability: {0} ', prediction.Probability);
    TConsole.NClass.WriteLine('==================================================');
    TConsole.NClass.WriteLine('');
    TConsole.NClass.WriteLine('');
  end;
end;

end.
