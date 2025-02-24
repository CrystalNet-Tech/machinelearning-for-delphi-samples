unit WebRankingConsoleApp;

interface
uses MLContextMgr, MLData;

type
  TWebRankingConsoleApp = class
  private
    class procedure ConsumeModel(const mlContext: IMLContextManager;
      model: IMLTransformer; modelPath: string; data: IMLDataView); static;
    class procedure EvaluateModel(const mlContext: IMLContextManager;
      model: IMLTransformer; data: IMLDataView); static;
    class function CreatePipeline(const mlContext: IMLContextManager;
      dataView: IMLDataView): IMLEstimatorChain<IMLTransformer>; static;
    class procedure PrepareData(inputPath, outputPath, trainDatasetPath, trainDatasetUrl,
      testDatasetUrl, testDatasetPath, validationDatasetUrl, validationDatasetPath: string); static;
  public
    class procedure Run;
  end;

implementation

uses WebRanking_Models, ConsoleHelper, SysUtils, CrystalNet.Console, MLCollections, CrystalNet.IO.FileSystem,
  CrystalNet.Net.WebClient;

const
  AssetsPath = '..\..\Assets';
  TrainDatasetUrl = 'https://aka.ms/mlnet-resources/benchmarks/MSLRWeb10KTrain720kRows.tsv';
  ValidationDatasetUrl = 'https://aka.ms/mlnet-resources/benchmarks/MSLRWeb10KValidate240kRows.tsv';
  TestDatasetUrl = 'https://aka.ms/mlnet-resources/benchmarks/MSLRWeb10KTest240kRows.tsv';

  InputRelativePath = AssetsPath + '\Input\';
  OutputRelativePath = AssetsPath + '\Output\';
  TrainDatasetPath = InputRelativePath + 'MSLRWeb10KTrain720kRows.tsv';
  ValidationDatasetPath = InputRelativePath + 'MSLRWeb10KValidate240kRows.tsv';
  TestDatasetPath = InputRelativePath + 'MSLRWeb10KTest240kRows.tsv';
  ModelRelativePath = OutputRelativePath + 'RankingModel.zip';

// Prints out the the individual scores used to determine the relative ranking.
procedure PrintScores(predictions: Enumerable<TSearchResultPrediction>);
begin
  for var prediction in predictions do
  begin
    TConsole.NClass.WriteLine('GroupId: {0}, Score: {1}', prediction.GroupId, prediction.Score);
  end;
end;

{ TWebRankingConsoleApp }

class procedure TWebRankingConsoleApp.Run;
var
  InputPath, OutputPath, ModelPath: string;
begin
{$IFDEF MSWINDOWS}
  {$IFDEF WIN32}
    raise Exception.Create('This Web Ranking Example works on 64bit platform');
  {$ENDIF}
{$ENDIF}

  InputPath := GetAbsolutePath(InputRelativePath);
  OutputPath := GetAbsolutePath(OutputRelativePath);
  ModelPath := GetAbsolutePath(ModelRelativePath);

  // Create a common ML.NET context.
  // Seed set to any number so you have a deterministic environment for repeateable results.
  var mlContext := TMLContextManager.Create(0);

  try
    PrepareData(InputPath, OutputPath, TrainDatasetPath, TrainDatasetUrl, TestDatasetUrl, TestDatasetPath, ValidationDatasetUrl, ValidationDatasetPath);

    // Create the pipeline using the training data's schema; the validation and testing data have the same schema.
    var separatorChar: Char := #9;
    var hasHeader:= true;
    var trainData := mlContext.Data.LoadFromTextFile<TSearchResultData>(TrainDatasetPath, separatorChar, hasHeader);

    var pipeline := CreatePipeline(mlContext, trainData);

    // Train the model on the training dataset. To perform training you need to call the Fit() method.
    TConsole.NClass.WriteLine('===== Train the model on the training dataset =====');
    TConsole.NClass.WriteLine();
    var model := pipeline.Fit(trainData);

    // Evaluate the model using the metrics from the validation dataset; you would then retrain and reevaluate the model until the desired metrics are achieved.
    TConsole.NClass.WriteLine('===== Evaluate the model''s result quality with the validation data =====');
    TConsole.NClass.WriteLine();
    separatorChar := '	';
    hasHeader := false;
    var validationData := mlContext.Data.LoadFromTextFile<TSearchResultData>(ValidationDatasetPath, separatorChar, hasHeader);
    EvaluateModel(mlContext, model, validationData);

    // Combine the training and validation datasets.
    var validationDataEnum := mlContext.Data.CreateEnumerable<TSearchResultData>(validationData, false);
    var trainDataEnum := mlContext.Data.CreateEnumerable<TSearchResultData>(trainData, false);
    var trainValidationDataEnum := validationDataEnum.Concat(trainDataEnum);
    var trainValidationData := mlContext.Data.LoadFromEnumerable<TSearchResultData>(trainValidationDataEnum);

    // Train the model on the train + validation dataset.
    TConsole.NClass.WriteLine('===== Train the model on the training + validation dataset =====');
    TConsole.NClass.WriteLine();
    model := pipeline.Fit(trainValidationData);

    // Evaluate the model using the metrics from the testing dataset; you do this only once and these are your final metrics.
    TConsole.NClass.WriteLine('===== Evaluate the model''s result quality with the testing data =====');
    TConsole.NClass.WriteLine();
    separatorChar := #9;
    hasHeader := false;
    var testData := mlContext.Data.LoadFromTextFile<TSearchResultData>(TestDatasetPath, separatorChar, hasHeader);
    EvaluateModel(mlContext, model, testData);

    // Combine the training, validation, and testing datasets.
    var testDataEnum := mlContext.Data.CreateEnumerable<TSearchResultData>(testData, false);
    var allDataEnum := trainValidationDataEnum.Concat(testDataEnum);
    var allData := mlContext.Data.LoadFromEnumerable<TSearchResultData>(allDataEnum);

    // Retrain the model on all of the data, train + validate + test.
    TConsole.NClass.WriteLine('===== Train the model on the training + validation + test dataset =====');
    TConsole.NClass.WriteLine();
    model := pipeline.Fit(allData);

    // Save and consume the model to perform predictions.
    // Normally, you would use new incoming data; however, for the purposes of this sample, we'll reuse the test data to show how to do predictions.
    ConsumeModel(mlContext, model, ModelPath, testData);
  except
    on E: Exception do
      TConsole.NClass.WriteLine(e.Message);
  end;

  TConsole.NClass.Write('Done!');
  TConsole.NClass.ReadLine();
end;

class procedure TWebRankingConsoleApp.ConsumeModel(
  const mlContext: IMLContextManager; model: IMLTransformer; modelPath: string;
  data: IMLDataView);
begin
  TConsole.NClass.WriteLine('===== Save the model =====');
  TConsole.NClass.WriteLine();

  // Save the model
  mlContext.Model.Save(model, nil, modelPath);

  TConsole.NClass.WriteLine('===== Consume the model =====');
    TConsole.NClass.WriteLine();

  // Load the model to perform predictions with it.
  var predictionPipelineSchema: IMLDataViewSchema;
  var predictionPipeline := mlContext.Model.Load(modelPath, predictionPipelineSchema);

  // Predict rankings.
  var predictions := predictionPipeline.Transform(data);

  // In the predictions, get the scores of the search results included in the first query (e.g. group).
  var searchQueries := mlContext.Data.CreateEnumerable<TSearchResultPrediction>(predictions, False);
  var firstGroupId := searchQueries.First().GroupId;
  var firstGroupPredictions := searchQueries.Take(100)
                                            .Where(function(p: TSearchResultPrediction): Boolean
                                                   begin
                                                     Result := p.GroupId = firstGroupId
                                                   end);
                                            //.OrderByDescending(p => p.Score).ToList();

  // The individual scores themselves are NOT a useful measure of result quality; instead, they are only useful as a relative measure to other scores in the group.
  // The scores are used to determine the ranking where a higher score indicates a higher ranking versus another candidate result.
  PrintScores(firstGroupPredictions);
end;

class function TWebRankingConsoleApp.CreatePipeline(
  const mlContext: IMLContextManager;
  dataView: IMLDataView): IMLEstimatorChain<IMLTransformer>;
const
  FeaturesVectorName = 'Features';
begin
  TConsole.NClass.WriteLine('===== Set up the trainer =====');
  TConsole.NClass.WriteLine();

  // Specify the columns to include in the feature input data.
  var featureCols := dataView.Schema.AsEnumerable()
      .Select<string>(function(s: IMLDataViewSchemaColumn): string
                      begin
                        Result := s.Name;
                      end)
      .Where(function(c: string): Boolean
             begin
              Result := (c <> 'Label') and (c <> 'GroupId');
             end)
      .ToArray();

  // Create an Estimator and transform the data:
  // 1. Concatenate the feature columns into a single Features vector.
  // 2. Create a key type for the label input data by using the value to key transform.
  // 3. Create a key type for the group input data by using a hash transform.
  var dataPipeline := mlContext.Transforms.Concatenate(FeaturesVectorName, featureCols)
      .Append(mlContext.Transforms.Conversion.MapValueToKey('Label'))
      .Append(mlContext.Transforms.Conversion.Hash('GroupId', 'GroupId', 20));

  // Set the LightGBM LambdaRank trainer.
  var trainer := mlContext.Ranking.Trainers.LightGbm('Label', FeaturesVectorName, 'GroupId');
  var trainerPipeline := dataPipeline.Append(trainer);

  Result := trainerPipeline;
end;

class procedure TWebRankingConsoleApp.EvaluateModel(
  const mlContext: IMLContextManager; model: IMLTransformer;
  data: IMLDataView);
begin
  // Use the model to perform predictions on the test data.
  var predictions := model.Transform(data);

  TConsole.NClass.WriteLine('===== Use metrics for the data using NDCG@3 =====\n');

  // Evaluate the metrics for the data using NDCG; by default, metrics for the up to 3 search results in the query are reported (e.g. NDCG@3).
  EvaluateMetrics(mlContext, predictions);

  // Evaluate metrics for up to 10 search results (e.g. NDCG@10).
  // TO CHECK:
  //TConsole.NClass.WriteLine('===== Use metrics for the data using NDCG@10 =====\n');
  //ConsoleHelper.EvaluateMetrics(mlContext, predictions, 10);
end;

class procedure TWebRankingConsoleApp.PrepareData(inputPath, outputPath,
  trainDatasetPath, trainDatasetUrl, testDatasetUrl, testDatasetPath,
  validationDatasetUrl, validationDatasetPath: string);
begin
  TConsole.NClass.WriteLine('===== Prepare data =====\n');

  if (not TDirectory.NClass.Exists(outputPath)) then
  begin
    TDirectory.NClass.CreateDirectory(outputPath);
  end;

  if (not TDirectory.NClass.Exists(inputPath)) then
  begin
    TDirectory.NClass.CreateDirectory(inputPath);
  end;

  if (not TFile.NClass.Exists(trainDatasetPath)) then
  begin
    TConsole.NClass.WriteLine('===== Download the train dataset - this may take several minutes =====');
    TConsole.NClass.WriteLine();
    var client1 := TWebClient.Create;
    try
      client1.DownloadFile(trainDatasetUrl, TrainDatasetPath);
    finally
      client1.Dispose;
      client1 := nil;
    end;
  end;

  if (not TFile.NClass.Exists(validationDatasetPath)) then
  begin
    TConsole.NClass.WriteLine('===== Download the validation dataset - this may take several minutes =====');
    TConsole.NClass.WriteLine();
    var client2 := TWebClient.Create;
    try
      client2.DownloadFile(validationDatasetUrl, validationDatasetPath);
    finally
      client2.Dispose;
      client2 := nil;
    end;
  end;

  if (not TFile.NClass.Exists(testDatasetPath)) then
  begin
    TConsole.NClass.WriteLine('===== Download the test dataset - this may take several minutes =====');
    TConsole.NClass.WriteLine();
    var client3 := TWebClient.Create;
    try
      client3.DownloadFile(testDatasetUrl, testDatasetPath);
    finally
      client3.Dispose;
      client3 := nil;
    end;
  end;

  TConsole.NClass.WriteLine('===== Download is finished =====');
  TConsole.NClass.WriteLine();
end;

end.
