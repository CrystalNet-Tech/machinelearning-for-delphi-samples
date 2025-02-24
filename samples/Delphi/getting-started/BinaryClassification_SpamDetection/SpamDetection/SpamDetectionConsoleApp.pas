unit SpamDetectionConsoleApp;


interface

uses MLData, MLCore;

type
  TSpamDetectionConsoleApp = class
  private
    class procedure ClassifyMessage<TSrc, TDst: TMLEntity>(
      Predictor: MLPredictionEngine<TSrc, TDst>; Message: string);
  public
    class procedure Run;
  end;

implementation

uses SpamDetection_Models, CrystalNet.Net.WebClient, CrystalNet.IO.FileSystem, MLContextMgr,
     MLOptions, CrystalNet.IO.Compression.ZipFile, CrystalNet.Console, ConsoleHelper,
     CNCoreClrLib.ExceptionMgr, CrystalNet.Runtime;


{ TSpamDetectionConsoleApp }

class procedure TSpamDetectionConsoleApp.Run;
var
  TrainDataPath, DataDirectoryPath: string;
  AppPath, AppDirectoryPath: string;
begin
  try
    AppPath := TPath.NClass.GetDirectoryName(ParamStr(0));
    AppDirectoryPath := TPath.NClass.GetFullPath(TPath.NClass.Combine(AppPath, '..\..\'));
    DataDirectoryPath := TPath.NClass.Combine([AppDirectoryPath, 'Data', 'spamfolder']);
    TrainDataPath  := TPath.NClass.Combine([AppDirectoryPath, 'Data', 'spamfolder', 'SMSSpamCollection']);

    // Download the dataset if it doesn't exist.
    if not TFile.NClass.Exists(TrainDataPath) then
    begin
      var client := TWebClient.Create;
      try
        //The code below will download a dataset from a third-party, UCI (link), and may be governed by separate third-party terms.
        //By proceeding, you agree to those separate terms.
        client.DownloadFile('https://archive.ics.uci.edu/ml/machine-learning-databases/00228/smsspamcollection.zip', 'spam.zip');
      finally
        client.Dispose;
        client := nil;
      end;

      TZipFile.NClass.ExtractToDirectory('spam.zip', DataDirectoryPath);
    end;

    // Set up the MLContext, which is a catalog of components in ML.NET.
    var mlContext := TMLContextManager.Create;
    var textFeaturizingEstimatorOptions: IMLTextFeaturizingEstimatorOptions := TMLTextFeaturizingEstimatorOptions.Create;
    try
      // Specify the schema for spam data and read it into DataView.
      var data := mlContext.Data.LoadFromTextFile<TSpamInput>(TrainDataPath, #9, True);

      // Create the estimator which converts the text label to boolean, featurizes the text, and adds a linear trainer.
      // Data process configuration with pipeline data transformations
      textFeaturizingEstimatorOptions.WordFeatureExtractor := TMLWordBagEstimatorOptions.Create;
      with textFeaturizingEstimatorOptions.WordFeatureExtractor do
      begin
        NgramLength := 2;
        UseAllLengths := False;
      end;

      textFeaturizingEstimatorOptions.CharFeatureExtractor := TMLWordBagEstimatorOptions.Create;
      with textFeaturizingEstimatorOptions.CharFeatureExtractor do
      begin
        NgramLength := 3;
        UseAllLengths := False;
      end;
      textFeaturizingEstimatorOptions.Norm := TMLNormFunction.nfL2;

      var dataProcessPipeline := mlContext.Transforms.Conversion.MapValueToKey('Label', 'Label')
                                  .Append(mlContext.Transforms.Text.FeaturizeText('FeaturesText', textFeaturizingEstimatorOptions, ['Message']))
                                  .Append(mlContext.Transforms.CopyColumns('Features', 'FeaturesText'))
                                  .AppendCacheCheckpoint(mlContext);

      // Set the training algorithm
      var trainer := mlContext.MulticlassClassification.Trainers.OneVersusAll(mlContext.BinaryClassification.Trainers.AveragedPerceptron('Label', 'Features', nil, 1, False, 0, 10))
                                .Append(mlContext.Transforms.Conversion.MapKeyToValue('PredictedLabel', 'PredictedLabel'));
      var trainingPipeLine := dataProcessPipeline.Append(trainer);

      // Evaluate the model using cross-validation.
      // Cross-validation splits our dataset into 'folds', trains a model on some folds and
      // evaluates it on the remaining fold. We are using 5 folds so we get back 5 sets of scores.
      // Let's compute the average AUC, which should be between 0.5 and 1 (higher is better).
      TConsole.NClass.WriteLine('=============== Cross-validating to get model''s accuracy metrics ===============');
      //Investigate, error calling CrossValidate
      var crossValidationResults := mlContext.MulticlassClassification.CrossValidate(data, trainingPipeLine, 5);
      ConsoleHelper.PrintMulticlassClassificationFoldsAverageMetrics(trainer.ToString, crossValidationResults);

      // Now let's train a model on the full dataset to help us get better results
      var model := trainingPipeLine.Fit(data);

      //Create a PredictionFunction from our model
      var predictor := mlContext.Model.CreatePredictionEngine<TSpamInput, TSpamPrediction>(model);

      TConsole.NClass.WriteLine('=============== Predictions for below data===============');
      // Test a few examples
      ClassifyMessage<TSpamInput, TSpamPrediction>(predictor, 'That''s a great idea. It should work.');
      ClassifyMessage<TSpamInput, TSpamPrediction>(predictor, 'free medicine winner! congratulations');
      ClassifyMessage<TSpamInput, TSpamPrediction>(predictor, 'Yes we should meet over the weekend!');
      ClassifyMessage<TSpamInput, TSpamPrediction>(predictor, 'you win pills and free entry vouchers');

      TConsole.NClass.WriteLine('=============== End of process, hit any key to finish =============== ');
      TConsole.NClass.ReadLine();

    finally
//      mlContext.Free;
      textFeaturizingEstimatorOptions := nil;
    end;
  except
    on E: ECoreClrException do
    begin
      TConsole.NClass.WriteLine(E.ToString);
      TConsole.NClass.ReadLine();
    end;
  end;
end;

class procedure TSpamDetectionConsoleApp.ClassifyMessage<TSrc, TDst>(Predictor: MLPredictionEngine<TSrc, TDst>; Message: string);
begin
  var input := TSpamInput.Create;
  try
    input.Message := message;
    var prediction := predictor.Predict(input);

    var isSpamInfo := 'not spam';
    if TSpamPrediction(prediction).isSpam = 'spam' then
      isSpamInfo := 'spam';

    TConsole.NClass.WriteLine('The message ''{0}'' is {1}', input.Message, isSpamInfo);
  finally
    input.Free;
  end;
end;

end.
