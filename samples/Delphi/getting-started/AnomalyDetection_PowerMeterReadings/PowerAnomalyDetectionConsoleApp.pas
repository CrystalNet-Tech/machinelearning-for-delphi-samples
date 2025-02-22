unit PowerAnomalyDetectionConsoleApp;

interface

uses MLContextMgr, MLData, MLCore;

type
  TPowerAnomalyDetectionConsoleApp = class
  private
    class procedure BuildTrainModel(const MLContext: IMLContextManager; DataView: MLDataView);
    class procedure DetectAnomalies(const MLContext: IMLContextManager; DataView: MLDataView);
  public
    class procedure Run;
  end;


implementation

uses MLOptions, CrystalNet.Console, CrystalNet.Console.Enums, CrystalNet.Runtime, ConsoleHelper, CrystalNet.Runtime.Enums,
  PowerAnomalyDetection_Models;

const
  DatasetsRelativePath = '..\..\Data';
  BaseModelsRelativePath = '..\..\MLModels';
  TrainingDatarelativePath = DatasetsRelativePath + '\power-export_min.csv';
  ModelRelativePath = BaseModelsRelativePath + '\PowerAnomalyDetectionModel.zip';

var
  ModelPath: string;

{ TPowerAnomalyDetectionConsoleApp }

class procedure TPowerAnomalyDetectionConsoleApp.Run;
var
  TrainingDataPath: string;
begin
  TrainingDataPath := GetAbsolutePath(TrainingDatarelativePath);
  ModelPath := GetAbsolutePath(ModelRelativePath);

  var mlContext := TMLContextManager.Create(0);

  // load data
  var dataView := mlContext.Data.LoadFromTextFile<TMeterData>(TrainingDataPath, ',', true);

  // transform options
  BuildTrainModel(mlContext, dataView);  // using SsaSpikeEstimator

  DetectAnomalies(mlContext, dataView);

  TConsole.NClass.WriteLine();
  TConsole.NClass.WriteLine('Press any key to exit');
  TConsole.NClass.Read();
end;

class procedure TPowerAnomalyDetectionConsoleApp.BuildTrainModel(
  const MLContext: IMLContextManager; DataView: MLDataView);
// Configure the Estimator
const
 PValueSize = 30;
 SeasonalitySize = 30;
 TrainingSize = 90;
 ConfidenceInterval = 98;
begin
  var outputColumnName := 'Prediction';
  var inputColumnName := 'ConsumptionDiffNormalized';

  var trainigPipeLine := mlContext.Transforms.DetectSpikeBySsa(
      outputColumnName,
      inputColumnName,
      ConfidenceInterval,
      PValueSize,
      TrainingSize,
      SeasonalitySize);

  var trainedModel := trainigPipeLine.Fit(dataView);

  // STEP 6: Save/persist the trained model to a .ZIP file
  mlContext.Model.Save(trainedModel, dataView.Schema, ModelPath);

  TConsole.NClass.WriteLine('The model is saved to {0}', ModelPath);
  TConsole.NClass.WriteLine('');
end;

class procedure TPowerAnomalyDetectionConsoleApp.DetectAnomalies(
  const MLContext: IMLContextManager; DataView: MLDataView);
var
  modelInputSchema: IMLDataViewSchema;
begin
  var trainedModel := mlContext.Model.Load(ModelPath, modelInputSchema);

  var transformedData := trainedModel.Transform(dataView);

  // Getting the data of the newly created column as an IEnumerable
  var predictions := mlContext.Data.CreateEnumerable<TSpikePrediction>(transformedData, false);

  var colCDN := dataView.GetColumn<Single>('ConsumptionDiffNormalized');
  var colTime := dataView.GetColumn<TDateTime>('time');

  // Output the input data and predictions
  TConsole.NClass.WriteLine('======Displaying anomalies in the Power meter data=========');
  TConsole.NClass.WriteLine('Date               ReadingDiff Alert Score P-Value');

  var i: Integer := 0;
  for var p in predictions do
  begin
    if (p.Prediction[0] = 1) then
    begin
      TConsole.NClass.BackgroundColor := TConsoleColor.ccDarkYellow;
      TConsole.NClass.ForegroundColor := TConsoleColor.ccBlack;
    end;
    TConsole.NClass.WriteLine('{0} {1:0.0000} {2:0.00} {3:0.00} {4:0.00}', [colTime.ElementAt(i), colCDN.ElementAt(i), p.Prediction[0], p.Prediction[1], p.Prediction[2]]);
    TConsole.NClass.ResetColor();
    Inc(i);
  end;
end;

end.
