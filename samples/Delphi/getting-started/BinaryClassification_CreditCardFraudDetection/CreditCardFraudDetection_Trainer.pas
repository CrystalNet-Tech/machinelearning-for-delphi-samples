unit CreditCardFraudDetection_Trainer;

interface

uses MLContextMgr, MLData;

type
  TTrainer = class
  private
    class procedure EvaluateModel(const mlContext: IMLContextManager; model: IMLTransformer; testDataView: IMLDataView; trainerName: string);
    class procedure SaveModel(const mlContext: IMLContextManager;  model: IMLTransformer; modelFilePath: string; trainingDataSchema: IMLDataViewSchema);
  public
    class procedure Execute;

    class procedure PrepDatasets(const mlContext: IMLContextManager; fullDataSetFilePath, trainDataSetFilePath, testDataSetFilePath: string);
    class function TrainModel(const mlContext: IMLContextManager; trainDataView: IMLDataView; var trainerName: string): IMLTransformer;
    class procedure InspectData(const mlContext: IMLContextManager; data: IMLDataView; records: Integer);
    class procedure UnZipDataSet(zipDataSet, destinationFile: string);
    class procedure ShowObservationsFilteredByLabel(const mlContext: IMLContextManager; dataView: IMLDataView; &label: Boolean = True; count: Integer = 2);
  end;

implementation

uses CreditCardFraudDetection_Models, CrystalNet.Console, CrystalNet.IO.FileSystem, CrystalNet.IO.Compression.ZipFile,
  CrystalNet.Runtime, ConsoleHelper, MLOptions, Variants, MLCollections;

const
  AssetsRelativePath = '..\..\..\Trainer\assets';



{ TTrainer }

class procedure TTrainer.Execute;
var
  trainerName: string;
begin
  // File paths
  var assetsPath := GetAbsolutePath(AssetsRelativePath);
  var zipDataSet := TPath.NClass.Combine(assetsPath, 'input', 'creditcardfraud-dataset.zip');
  var fullDataSetFilePath := TPath.NClass.Combine(assetsPath, 'input', 'creditcard.csv');
  var trainDataSetFilePath := TPath.NClass.Combine(assetsPath, 'output', 'trainData.csv');
  var testDataSetFilePath := TPath.NClass.Combine(assetsPath, 'output', 'testData.csv');
  var modelFilePath := TPath.NClass.Combine(assetsPath, 'output', 'fastTree.zip');

  // Unzip the original dataset as it is too large for GitHub repo if not zipped
  UnZipDataSet(zipDataSet, fullDataSetFilePath);

  // Create a common ML.NET context.
  // Seed set to any number so you have a deterministic environment for repeateable results
  var mlContext := TMLContextManager.Create(1);

  // Prepare data and create Train/Test split datasets
  PrepDatasets(mlContext, fullDataSetFilePath, trainDataSetFilePath, testDataSetFilePath);

  // Load Datasets
  var trainingDataView := mlContext.Data.LoadFromTextFile<TTransactionObservation>(trainDataSetFilePath, ',', True);
  var testDataView := mlContext.Data.LoadFromTextFile<TTransactionObservation>(testDataSetFilePath, ',', true);

  // Train Model
  var model := TrainModel(mlContext, trainingDataView, trainerName);

  // Evaluate quality of Model
  EvaluateModel(mlContext, model, testDataView, trainerName);

  // Save model
  SaveModel(mlContext, model, modelFilePath, trainingDataView.Schema);

  TConsole.NClass.WriteLine('=============== Press any key ===============');
  TConsole.NClass.ReadKey();
end;

class procedure TTrainer.EvaluateModel(const mlContext: IMLContextManager;
  model: IMLTransformer; testDataView: IMLDataView; trainerName: string);
begin
  // Evaluate the model and show accuracy stats
  TConsole.NClass.WriteLine('===== Evaluating Model''s accuracy with Test data =====');

  var predictions := model.Transform(testDataView);

  var metrics := mlContext.BinaryClassification.Evaluate(predictions);

  PrintBinaryClassificationMetrics(trainerName, metrics);
end;

class procedure TTrainer.InspectData(const mlContext: IMLContextManager;
  data: IMLDataView; records: Integer);
begin
  // We want to make sure we have both True and False observations
  TConsole.NClass.WriteLine('Show 4 fraud transactions (true)');
  ShowObservationsFilteredByLabel(mlContext, data, true, records);

  TConsole.NClass.WriteLine('Show 4 NOT-fraud transactions (false)');
  ShowObservationsFilteredByLabel(mlContext, data, false, records);
end;

class procedure TTrainer.PrepDatasets(const mlContext: IMLContextManager;
  fullDataSetFilePath, trainDataSetFilePath, testDataSetFilePath: string);
begin
  // Only prep-datasets if train and test datasets don't exist yet
  if (not TFile.NClass.Exists(trainDataSetFilePath) and not TFile.NClass.Exists(testDataSetFilePath)) then
  begin
    TConsole.NClass.WriteLine('===== Preparing train/test datasets =====');

    // Load the original single dataset
    var originalFullData := mlContext.Data.LoadFromTextFile<TTransactionObservation>(fullDataSetFilePath, ',', true);

    // Split the data 80:20 into train and test sets, train and evaluate.
    var trainTestData := mlContext.Data.TrainTestSplit(originalFullData, 0.2, 1);
    var trainData := trainTestData.TrainSet;
    var testData := trainTestData.TestSet;

    // Inspect TestDataView to make sure there are true and false observations in test dataset, after spliting
    InspectData(mlContext, testData, 4);

    // Save train split
    var fileStream := TFile.NClass.Create(trainDataSetFilePath);
    try
      mlContext.Data.SaveAsText(trainData, fileStream, ',', true, true);
    finally
      fileStream.Dispose;
      fileStream := nil;
    end;

    // Save test split
    fileStream := TFile.NClass.Create(testDataSetFilePath);
    try
      mlContext.Data.SaveAsText(testData, fileStream, ',', true, true);
    finally
      fileStream.Dispose;
      fileStream := nil;
    end;
  end;
end;

class procedure TTrainer.SaveModel(const mlContext: IMLContextManager;
  model: IMLTransformer; modelFilePath: string;
  trainingDataSchema: IMLDataViewSchema);
begin
  mlContext.Model.Save(model, trainingDataSchema, modelFilePath);

  TConsole.NClass.WriteLine('Saved model to ' + modelFilePath);
end;

class function TTrainer.TrainModel(const mlContext: IMLContextManager;
  trainDataView: IMLDataView; var trainerName: string): IMLTransformer;
begin
  // Get all the feature column names (All except the Label and the IdPreservationColumn)
  var featureColumnNames := trainDataView.Schema.AsEnumerable()
							  .Select<string>(function(column: IMLDataViewSchemaColumn): string
							  begin
								  Result := column.Name;     // Get all the column names
							  end)
							  .Where(function(name: string): Boolean
									 begin
									   Result := (name <> 'Label') and                 // Do not include the Label column
				   					             (name <> 'IdPreservationColumn') and  // Do not include the IdPreservationColumn/StratificationColumn
									             (name <> 'Time');                     // Do not include the Time column. Not needed as feature column
									 end)
							  .ToArray();

  // Create the data process pipeline
  var dataProcessPipeline := mlContext.Transforms.Concatenate('Features', featureColumnNames)
                                                             .Append(mlContext.Transforms.DropColumns(['Time']))
                                                             .Append(mlContext.Transforms.NormalizeMeanVariance('FeaturesNormalizedByMeanVar', 'Features'));

  // (OPTIONAL) Peek data (such as 2 records) in training DataView after applying the ProcessPipeline's transformations into 'Features'
  ConsoleHelper.PeekDataViewInConsole(mlContext, trainDataView, dataProcessPipeline, 2);
  ConsoleHelper.PeekVectorColumnDataInConsole(mlContext, 'Features', trainDataView, dataProcessPipeline, 1);


  // Set the training algorithm
  var trainer := mlContext.BinaryClassification.Trainers.FastTree('Label', 'FeaturesNormalizedByMeanVar');

  var trainingPipeline := dataProcessPipeline.Append(trainer);

  ConsoleHelper.ConsoleWriteHeader(['=============== Training model ===============']);

  var model := trainingPipeline.Fit(trainDataView);

  ConsoleHelper.ConsoleWriteHeader(['=============== End of training process ===============']);

  // Append feature contribution calculator in the pipeline. This will be used
  // at prediction time for explainability.
  var fccPipeline := model.Append(mlContext.Transforms
      .CalculateFeatureContribution(model.LastTransformer)
      .Fit(dataProcessPipeline.Fit(trainDataView).Transform(trainDataView)));

  trainerName := fccPipeline.ToString();
  Result := fccPipeline;
end;

class procedure TTrainer.UnZipDataSet(zipDataSet, destinationFile: string);
begin
  if (not TFile.NClass.Exists(destinationFile)) then
  begin
    var destinationDirectory := TPath.NClass.GetDirectoryName(destinationFile);
    TZipFile.NClass.ExtractToDirectory(zipDataSet, destinationDirectory);
  end
end;

class procedure TTrainer.ShowObservationsFilteredByLabel(const mlContext: IMLContextManager; dataView: IMLDataView; &label: Boolean; count: Integer);
begin
  // Convert to an enumerable of user-defined type.
  var dataEnumerables := mlContext.Data.CreateEnumerable<TTransactionObservation>(dataView, false);
  var data: TArray<TTransactionObservation>;

  for var x in dataEnumerables do
  begin
    var labelNo := 0;
    if x.&Label = &label then
    begin
      data := data + [x];
    end;

    // Take a couple values as an array.
    if Length(data) >= count then
      Break;
  end;

  // Print to Console
  for var row in data do
    row.PrintToConsole();
end;

end.

