unit CreditCardFraudDetection_Predictor;

interface

type
  TPredictor = class
  private
  public
    class procedure Execute;
    class procedure CopyModelAndDatasetFromTrainingProject(ATrainOutput, AssetsPath: string);
  end;

  TPredictorContext = class
  private
    _modelfile: string;
    _dasetFile: string;
  public
    constructor Create(modelfile, dasetFile: string);
    procedure RunMultiplePredictions(numberOfPredictions: Integer);
  end;

implementation

uses MLContextMgr, CreditCardFraudDetection_Models, CrystalNet.Console, MLData,
  CrystalNet.Runtime, CrystalNet.IO.FileSystem, CrystalNet.Runtime.Intf, ConsoleHelper;

type
  TTransactionFraudPredictionWithContribution = class(TTransactionFraudPrediction)
  private
    FFeatureContributions: TArray<Single>;
  public
    procedure PrintToConsole(dataview: IMLDataViewSchema); overload;

    property FeatureContributions: TArray<Single> read FFeatureContributions write FFeatureContributions;
  end;


{ TTransactionFraudPredictionWithContribution }

procedure TTransactionFraudPredictionWithContribution.PrintToConsole(
  dataview: IMLDataViewSchema);
var
  slots: MLVBuffer<IReadOnlyMemory<Char>>;
begin
  inherited PrintToConsole();
  dataview.GetColumnOrNull('Features').Value.GetSlotNames(slots);
  var featureNames := slots.DenseValues().ToArray();
  TConsole.NClass.WriteLine('Feature Contributions: ' +
                            '[{0}] {1} ' +
                            '[{2}] {3} ' +
                            '[{4}] {5} ... ' +
                            '[{6}] {7} ' +
                            '[{8}] {9}',
                             [featureNames[0], FeatureContributions[0], featureNames[1], FeatureContributions[1],
                             featureNames[2], FeatureContributions[2], featureNames[27], FeatureContributions[27],
                             featureNames[28], FeatureContributions[28]]);
end;

{ TPredictor }

class procedure TPredictor.Execute;
var
  assetsPath, trainOutput: string;
  inputDatasetForPredictions, modelFilePath: string;
begin
  assetsPath := GetAbsolutePath('..\..\.\Predictor/assets');
  trainOutput := GetAbsolutePath('..\..\..\..\Trainer/assets/output');

  //Always copy the trained model from the trainer project just in case there's a new version trained.
  CopyModelAndDatasetFromTrainingProject(trainOutput, assetsPath);

  inputDatasetForPredictions := TPath.NClass.Combine(assetsPath, 'input', 'testData.csv');
  modelFilePath := TPath.NClass.Combine(assetsPath, 'input', 'fastTree.zip');

  // Create model predictor to perform a few predictions
  var modelPredictor := TPredictorContext.Create(modelFilePath, inputDatasetForPredictions);
  try
    modelPredictor.RunMultiplePredictions(5);
    TConsole.NClass.WriteLine('=============== Press any key ===============');
  finally
    modelPredictor.Free;
  end;
  TConsole.NClass.ReadKey();

end;

class procedure TPredictor.CopyModelAndDatasetFromTrainingProject(ATrainOutput,
  assetsPath: string);
begin
  if (not TFile.NClass.Exists(TPath.NClass.Combine(ATrainOutput, 'testData.csv')) or
      not TFile.NClass.Exists(TPath.NClass.Combine(ATrainOutput, 'fastTree.zip'))) then
  begin
    TConsole.NClass.WriteLine('***** YOU NEED TO RUN THE TRAINING PROJECT FIRST *****');
    TConsole.NClass.WriteLine('=============== Press any key ===============');
    TConsole.NClass.ReadKey();
    TEnvironment.NClass.Exit(0);
  end;

  // Copy files from train output
  TDirectory.NClass.CreateDirectory(assetsPath);

  for var &file in TDirectory.NClass.GetFiles(ATrainOutput) do
  begin
    var fileDestination := TPath.NClass.Combine(TPath.NClass.Combine(assetsPath, 'input'), TPath.NClass.GetFileName(&file));

    if (TFile.NClass.Exists(fileDestination)) then
    begin
      TFile.NClass.Delete(fileDestination);
    end;

    if ((TPath.NClass.GetFileName(&file) = 'testData.csv') or (TPath.NClass.GetFileName(&file) = 'fastTree.zip')) then
        TFile.NClass.Copy(&file, TPath.NClass.Combine(TPath.NClass.Combine(assetsPath, 'input'), TPath.NClass.GetFileName(&file)));
  end;
end;

{ TPredictorContext }

constructor TPredictorContext.Create(modelfile, dasetFile: string);
begin
  _modelfile := modelfile;
  _dasetFile := dasetFile;
end;

procedure TPredictorContext.RunMultiplePredictions(numberOfPredictions: Integer);
var
  inputSchema: IMLDataViewSchema;
begin
  var mlContext := TMLContextManager.Create();

  // Load data as input for predictions
  var inputDataForPredictions := mlContext.Data.LoadFromTextFile<TTransactionObservation>(_dasetFile, ',', True);

  TConsole.NClass.WriteLine('Predictions from saved model:');

  var model := mlContext.Model.Load(_modelfile, inputSchema);

  var predictionEngine := mlContext.Model.CreatePredictionEngine<TTransactionObservation, TTransactionFraudPredictionWithContribution>(model);

  TConsole.NClass.WriteLine();
  TConsole.NClass.WriteLine();
  TConsole.NClass.WriteLine(' Test {0} transactions, from the test datasource, that should be predicted as fraud (true):', numberOfPredictions);

  mlContext.Data.CreateEnumerable<TTransactionObservation>(inputDataForPredictions, false)
                    .Where(function(x: TTransactionObservation): Boolean
                           begin
                            Result := x.&Label = true;
                           end)
                    .Take(numberOfPredictions)
                    .ForEach(procedure(testData: TTransactionObservation)
                             begin
                               TConsole.NClass.WriteLine('--- Transaction ---');
                               testData.PrintToConsole();
                               predictionEngine.Predict(testData).PrintToConsole();
                               TConsole.NClass.WriteLine('-------------------');
                             end);

  TConsole.NClass.WriteLine();
  TConsole.NClass.WriteLine();
  TConsole.NClass.WriteLine(' Test {0} transactions, from the test datasource, that should NOT be predicted as fraud (false):', numberOfPredictions);

  mlContext.Data.CreateEnumerable<TTransactionObservation>(inputDataForPredictions, false)
                    .Where(function(x: TTransactionObservation): Boolean
                           begin
                            Result := x.&Label = False;
                           end)
                    .Take(numberOfPredictions)
                    .ForEach(procedure(testData: TTransactionObservation)
                             begin
                               TConsole.NClass.WriteLine('--- Transaction ---');
                               testData.PrintToConsole();
                               predictionEngine.Predict(testData).PrintToConsole(model.GetOutputSchema(inputDataForPredictions.Schema));
                               TConsole.NClass.WriteLine('-------------------');
                             end);
end;

end.
