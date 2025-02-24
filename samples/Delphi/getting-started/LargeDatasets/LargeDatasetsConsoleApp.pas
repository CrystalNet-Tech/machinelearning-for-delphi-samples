unit LargeDatasetsConsoleApp;

interface

uses MLCollections, MLContextMgr, MLData, LargeDatasets_Models;

type
  TLargeDatasetsConsoleApp = class
  private
    class procedure AddFeaturesColumn(sourceFilePath, preparedDataPath: string); static;
    class function CreateSingleDataSample(const mlContext: IMLContextManager;
      dataView: IMLDataView): Enumerable<TUrlData>; static;
    class procedure DownloadDataset(originalDataDirectoryPath: string); static;
    class procedure PrepareDataset(originalDataPath, preparedDataPath: string); static;
  public
    class procedure Run;
  end;

implementation

uses ConsoleHelper, CrystalNet.Console, CrystalNet.Runtime, CrystalNet.IO.FileSystem,
  MLCore, CrystalNet.Net.WebClient, CrystalNet.IO.Compression.ZipFile, CrystalNet.IO.FileSystem.Enums,
  SysUtils, Generics.Collections, ICSharpCode.SharpZipLib, CNCoreClrLib.AssemblyMgr,
  ICSharpCode.SharpZipLib.Consts;

const
  SharpZipLibRelativePath = '..\..\Lib\ICSharpCode.SharpZipLib.dll';

  originalDataDirectoryRelativePath = '..\..\Data\OriginalUrlData';
  originalDataReltivePath = '..\..\Data\OriginalUrlData\url_svmlight';
  preparedDataReltivePath = '..\..\Data\PreparedUrlData\url_svmlight';

var
  originalDataDirectoryPath: string;
  originalDataPath: string;
  preparedDataPath: string;

{ TLargeDatasetsConsoleApp }

class procedure TLargeDatasetsConsoleApp.Run;
begin
  originalDataDirectoryPath := GetAbsolutePath(originalDataDirectoryRelativePath);
  originalDataPath := GetAbsolutePath(originalDataReltivePath);
  preparedDataPath := GetAbsolutePath(preparedDataReltivePath);

  //STEP 1: Download dataset
  DownloadDataset(originalDataDirectoryPath);

  //Step 2: Prepare data by adding second column with value total number of features.
  PrepareDataset(originalDataPath, preparedDataPath);

  var mlContext: IMLContextManager := TMLContextManager.Create();

  //STEP 3: Common data loading configuration
  var Path := TPath.NClass.Combine(preparedDataPath, '*');
  var SeparatorChar: Char := '	';
  var HasHeader: Boolean := False;
  var AllowQuoting: Boolean := False;
  var TrimWhitespace: Boolean := False;
  var AllowSparse: Boolean := True;

  var fullDataView := mlContext.Data.LoadFromTextFile<TUrlData>(Path, SeparatorChar, HasHeader, AllowQuoting, TrimWhitespace, AllowSparse);

  //Step 4: Divide the whole dataset into 80% training and 20% testing data.
  var testFraction := 0.2;
  var seed := 1;
  var trainTestData := mlContext.Data.TrainTestSplit(fullDataView, testFraction, seed);
  var trainDataView := trainTestData.TrainSet;
  var testDataView := trainTestData.TestSet;

  //Step 5: Map label value from string to bool
  var UrlLabelMap := TMLDictionary<string, Boolean>.Create();
  UrlLabelMap.Add('+1', True);  //Malicious url
  UrlLabelMap.Add('-1', False); //Benign
  var dataProcessingPipeLine := mlContext.Transforms.Conversion.MapValue<string, Boolean>('LabelKey', UrlLabelMap, 'LabelColumn');
  ConsoleHelper.PeekDataViewInConsole(mlContext, trainDataView, dataProcessingPipeLine, 2);

  //Step 6: Append trainer to pipeline
  var trainingPipeLine := dataProcessingPipeLine.Append(mlContext.BinaryClassification.Trainers.FieldAwareFactorizationMachine('FeatureVector', 'LabelKey'));

  //Step 7: Train the model
  TConsole.NClass.WriteLine('====Training the model=====');
  var mlModel := trainingPipeLine.Fit(trainDataView);
  TConsole.NClass.WriteLine('====Completed Training the model=====');
  TConsole.NClass.WriteLine('');

  //Step 8: Evaluate the model
  TConsole.NClass.WriteLine('====Evaluating the model=====');
  var predictions := mlModel.Transform(testDataView);

  var data := predictions;
  var labelColumnName := 'LabelKey';
  var scoreColumnName := 'Score';

// 'AUC is not defined when there is no positive class in the data (Parameter 'PosSample')'
//  var metrics := mlContext.BinaryClassification.Evaluate(data, labelColumnName, scoreColumnName);
//  ConsoleHelper.PrintBinaryClassificationMetrics(mlModel.ToString(), metrics);

  // Try a single prediction
  TConsole.NClass.WriteLine('====Predicting sample data=====');
  var predEngine := mlContext.Model.CreatePredictionEngine<TUrlData, TUrlPrediction>(mlModel);
  // Create sample data to do a single prediction with it
  var sampleDatas := CreateSingleDataSample(mlContext, trainDataView);
  for var sampleData in sampleDatas do
  begin
    var predictionResult := predEngine.Predict(sampleData);
    TConsole.NClass.WriteLine('Single Prediction --> Actual value: {0} | Predicted value: {1}', sampleData.LabelColumn, predictionResult.Prediction);
  end;

  TConsole.NClass.WriteLine('====End of Process..Press any key to exit====');
  TConsole.NClass.ReadLine();
end;

class procedure TLargeDatasetsConsoleApp.DownloadDataset(originalDataDirectoryPath: string);
begin
  if (not TDirectory.NClass.Exists(originalDataDirectoryPath)) then
  begin
    TConsole.NClass.WriteLine('====Downloading and extracting data====');
    var client := TWebClient.Create;
    try
      //The code below will download a dataset from a third-party, UCI (link), and may be governed by separate third-party terms.
      //By proceeding, you agree to those separate terms.
      client.DownloadFile('https://archive.ics.uci.edu/ml/machine-learning-databases/url/url_svmlight.tar.gz', 'url_svmlight.zip');
    finally
      client.Dispose;
      client := nil;
    end;

    if not TDirectory.NClass.Exists(originalDataDirectoryPath) then
      TDirectory.NClass.CreateDirectory(originalDataDirectoryPath);

    var inputStream := TFile.NClass.OpenRead('url_svmlight.zip');
    var gzipStream := TGZipInputStream.Create(inputStream);
    var tarArchive := TTarArchive.NClass.CreateInputTarArchive(TStream.Wrap(gzipStream));
    tarArchive.ExtractContents(originalDataDirectoryPath);

    tarArchive.Close();
    gzipStream.Close();
    inputStream.Close();
    TConsole.NClass.WriteLine('====Downloading and extracting is completed====');
  end;
end;

class procedure TLargeDatasetsConsoleApp.PrepareDataset(originalDataPath, preparedDataPath: string);
begin
  //Create folder for prepared Data path if it does not exist.
  if (not TDirectory.NClass.Exists(preparedDataPath)) then
  begin
    TDirectory.NClass.CreateDirectory(preparedDataPath);
  end;

  TConsole.NClass.WriteLine('====Preparing Data====');
  TConsole.NClass.WriteLine('');
  //ML.Net API checks for number of features column before the sparse matrix format
  //So add total number of features i.e 3231961 as second column by taking all the files from originalDataPath
  //and save those files in preparedDataPath.
  if (Length(TDirectory.NClass.GetFiles(preparedDataPath)) = 0) then
  begin
//    var ext := new List<string> { '.svm' };
    var ext := '.svm';
    var filesInDirectory := TDirectory.NClass.GetFiles(originalDataPath, '*.*', TSearchOption.soAllDirectories);
    for var file_ in filesInDirectory do
    begin
      if ext.Contains(TPath.NClass.GetExtension(file_)) then
      begin
        AddFeaturesColumn(TPath.NClass.GetFullPath(file_), preparedDataPath);
      end;
    end;
  end;
  TConsole.NClass.WriteLine('====Data Preparation is done====');
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('original data path= {0}', originalDataPath);
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('prepared data path= {0}', preparedDataPath);
  TConsole.NClass.WriteLine('');
end;

class procedure TLargeDatasetsConsoleApp.AddFeaturesColumn(sourceFilePath, preparedDataPath: string);
begin
  var sourceFileName := TPath.NClass.GetFileName(sourceFilePath);
  var preparedFilePath := TPath.NClass.Combine(preparedDataPath, sourceFileName);

  //if the file does not exist in preparedFilePath then copy from sourceFilePath and then add new column
  if (not TFile.NClass.Exists(preparedFilePath)) then
  begin
    TFile.NClass.Copy(sourceFilePath, preparedFilePath, true);
  end;

  var newColumnData :=  '3231961';
  var CSVDump := TFile.NClass.ReadAllLines(preparedFilePath);
  var CSV := TList<TList<string>>.Create;
  for var select in CSVDump do
  begin
    var s := TList<string>.Create(select.Split([' ']));
    CSV.Add(s);
    s.Free;
  end;

  for var i := 0 to CSV.Count - 1 do
    CSV[i].Insert(1, newColumnData);

  var lines: TArray<string>;
  for var i := 0 to CSV.Count - 1 do
  begin
    var data := '';
    for var j := 0 to CSV[i].Count - 1 do
    begin
      data := data + CSV[i][j] + ' ';
    end;
    lines := lines + [data];
  end;

  for var i := CSV.Count - 1 downto 0 do
    CSV[i].Free;

  CSV.Free;

  TFile.NClass.WriteAllLines(preparedFilePath, lines);
end;

class function TLargeDatasetsConsoleApp.CreateSingleDataSample(const mlContext: IMLContextManager; dataView: IMLDataView): Enumerable<TUrlData>;
begin
  // Here (ModelInput object) you could provide new test data, hardcoded or from the end-user application, instead of the row from the file.
  Result := mlContext.Data.CreateEnumerable<TUrlData>(dataView, false).Take(4);                                                                        ;
end;

initialization
	TCoreClrAssembly.RegisterDLLAssembly(sC_ICSharpCodeSharpZipLib_Asm_ID, SharpZipLibRelativePath, False);

end.
