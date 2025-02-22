unit ImageClassification_Trainer;

interface

uses
  MLContextMgr,
  MLData,
  ImageClassification_Models,
  Microsoft.ML.Data.Intf,
  CNCoreClrLib.BridgeMgr;

type
  TTrainer = class
  private
    class procedure EvaluateModel(const mlContext: IMLContextManager; testDataset: IMLDataView; trainedModel: IMLTransformer);
    class procedure TrySinglePrediction(imagesFolderPathForPredictions: string; const mlContext: IMLContextManager;  trainedModel: IMLTransformer);
  public
    class procedure Execute;

    class function LoadImagesFromDirectory(folder: string; useFolderNameAsLabel: Boolean = True): TArray<TImageData>; static;
    class function DownloadImageSet(imagesDownloadFolder: string): string; static;
    class function GetAbsolutePath(relativePath: string): string; static;
    class procedure FilterMLContextLog(sender: ICoreClrInstance; e: ILoggingEventArgs);
  end;

implementation

uses
  ImageClassification_Shared,
  ImageClassification_Common,
  CrystalNet.Runtime,
  CrystalNet.Console,
  ConsoleHelper,
  MLTransforms,
  SysUtils;


const
 fileName = 'flower_photos_small_set.zip';
 assetsRelativePath = '..\..\train_assets';


{ TTrainer }

class function TTrainer.DownloadImageSet(imagesDownloadFolder: string): string;
begin
  // get a set of images to teach the network about the new classes

  //SINGLE SMALL FLOWERS IMAGESET (200 files)
  var url := 'https://aka.ms/mlnet-resources/datasets/flower_photos_small_set.zip';
  TWeb.Download(url, imagesDownloadFolder, fileName);
  TCompress.UnZip(TPath.NClass.Join(imagesDownloadFolder, fileName), imagesDownloadFolder);

  //SINGLE FULL FLOWERS IMAGESET (3,600 files)
  //string fileName = 'flower_photos.tgz';
  //string url = $'http://download.tensorflow.org/example_images/{fileName}';
  //Web.Download(url, imagesDownloadFolder, fileName);
  //Compress.ExtractTGZ(TPath.NClass.Join(imagesDownloadFolder, fileName), imagesDownloadFolder);

  Result := TPath.NClass.GetFileNameWithoutExtension(fileName);
end;

class procedure TTrainer.EvaluateModel(const mlContext: IMLContextManager;
  testDataset: IMLDataView; trainedModel: IMLTransformer);
begin
  TConsole.NClass.WriteLine('Making predictions in bulk for evaluating model''s quality...');

  // Measuring time
  var watch := TStopwatch.NClass.StartNew();

  var predictionsDataView := trainedModel.Transform(testDataset);


  var metrics := mlContext.MulticlassClassification.Evaluate(predictionsDataView, 'LabelAsKey', 'Score', 'PredictedLabel');

  ConsoleHelper.PrintMultiClassClassificationMetrics('TensorFlow DNN Transfer Learning', metrics);

  watch.Stop();
  var elapsed2Ms := watch.ElapsedMilliseconds;

  TConsole.NClass.WriteLine('Predicting and Evaluation took: {0} seconds', elapsed2Ms / 1000);
end;

class procedure TTrainer.Execute;
begin
  var assetsPath: string := GetAbsolutePath(assetsRelativePath);

  var outputMlNetModelFilePath: string := TPath.NClass.Combine(assetsPath, 'outputs', 'imageClassifier.zip');
  var imagesFolderPathForPredictions: string := TPath.NClass.Combine(assetsPath, 'inputs', 'test-images');

  var imagesDownloadFolderPath: string := TPath.NClass.Combine(assetsPath, 'inputs', 'images');

  // 1. Download the image set and unzip
  var finalImagesFolderName: string := DownloadImageSet(imagesDownloadFolderPath);
  var fullImagesetFolderPath: string := TPath.NClass.Combine(imagesDownloadFolderPath, finalImagesFolderName);

  var mlContext := TMLContextManager.Create(1);

  // Specify MLContext Filter to only show feedback log/traces about ImageClassification
  // This is not needed for feedback output if using the explicit MetricsCallback parameter
  mlContext.Log := FilterMLContextLog;

  // 2. Load the initial full image-set into an IDataView and shuffle so it'll be better balanced
  var images: TArray<TImageData> := LoadImagesFromDirectory(fullImagesetFolderPath, True);
  var fullImagesDataset: MLDataView := mlContext.Data.LoadFromEnumerable<TImageData>(images);
  var shuffledFullImageFilePathsDataset: MLDataView := mlContext.Data.ShuffleRows(fullImagesDataset);

  // 3. Load Images with in-memory type within the IDataView and Transform Labels to Keys (Categorical)
  var shuffledFullImagesDataset: MLDataView := mlContext.Transforms.Conversion.MapValueToKey('LabelAsKey', 'Label', 1000000, TMLKeyOrdinality.KoByValue)
      .Append(mlContext.Transforms.LoadRawImageBytes('Image', fullImagesetFolderPath, 'ImagePath'))
      .Fit(shuffledFullImageFilePathsDataset)
      .Transform(shuffledFullImageFilePathsDataset);

  // 4. Split the data 80:20 into train and test sets, train and evaluate.
  var trainTestData := mlContext.Data.TrainTestSplit(shuffledFullImagesDataset, 0.2);
  var trainDataView: IMLDataView := trainTestData.TrainSet;
  var testDataView: IMLDataView := trainTestData.TestSet;

  // 5. Define the model's training pipeline using DNN default values
  //
  var pipeline := mlContext.MulticlassClassification.Trainers.ImageClassification('LabelAsKey', 'Image', 'Score', 'PredictedLabel', testDataView)
                  .Append(mlContext.Transforms.Conversion.MapKeyToValue('PredictedLabel', 'PredictedLabel'));

  // 5.1 (OPTIONAL) Define the model's training pipeline by using explicit hyper-parameters
  //
  //var options = new ImageClassificationTrainer.Options()
  //{
  //    FeatureColumnName = 'Image',
  //    LabelColumnName = 'LabelAsKey',
  //    // Just by changing/selecting InceptionV3/MobilenetV2/ResnetV250
  //    // you can try a different DNN architecture (TensorFlow pre-trained model).
  //    Arch = ImageClassificationTrainer.Architecture.MobilenetV2,
  //    Epoch = 50,       //100
  //    BatchSize = 10,
  //    LearningRate = 0.01f,
  //    MetricsCallback = (metrics) => TConsole.NClass.WriteLine(metrics),
  //    ValidationSet = testDataView
  //};

  //var pipeline = mlContext.MulticlassClassification.Trainers.ImageClassification(options)
  //        .Append(mlContext.Transforms.Conversion.MapKeyToValue(
  //            outputColumnName: 'PredictedLabel',
  //            inputColumnName: 'PredictedLabel'));

  // 6. Train/create the ML model
  TConsole.NClass.WriteLine('*** Training the image classification model with DNN Transfer Learning on top of the selected pre-trained model/architecture ***');

  // Measuring training time
  var watch := TStopwatch.NClass.StartNew();

  //Train
  var trainedModel := pipeline.Fit(trainDataView);

  watch.Stop();
  var elapsedMs := watch.ElapsedMilliseconds;

  TConsole.NClass.WriteLine('Training with transfer learning took: {0} seconds', elapsedMs / 1000);

  // 7. Get the quality metrics (accuracy, etc.)
  EvaluateModel(mlContext, testDataView, trainedModel);

  // 8. Save the model to assets/outputs (You get ML.NET .zip model file and TensorFlow .pb model file)
  mlContext.Model.Save(trainedModel, trainDataView.Schema, outputMlNetModelFilePath);
  TConsole.NClass.WriteLine('Model saved to: {0}', outputMlNetModelFilePath);

  // 9. Try a single prediction simulating an end-user app
  TrySinglePrediction(imagesFolderPathForPredictions, mlContext, trainedModel);

  TConsole.NClass.WriteLine('Press any key to finish');
  TConsole.NClass.ReadKey();
end;

class procedure TTrainer.FilterMLContextLog(sender: ICoreClrInstance;
  e: ILoggingEventArgs);
begin
  if (e.Message.StartsWith('[Source=ImageClassificationTrainer;')) then
  begin
    TConsole.NClass.WriteLine(e.Message);
  end;
end;

class function TTrainer.GetAbsolutePath(relativePath: string): string;
begin
  Result := TFileUtils.GetAbsolutePath(relativePath);
end;

class function TTrainer.LoadImagesFromDirectory(folder: string;
  useFolderNameAsLabel: Boolean): TArray<TImageData>;
begin
  Result := [];
  var images: TArray<TImageRecord> := TFileUtils.LoadImagesFromDirectory(folder, useFolderNameAsLabel);
  for var image in images do
  begin
    var imageRecord := TImageData.Create(image.ImagePath, image.&Label);
    Result := Result + [imageRecord];
  end;
end;

class procedure TTrainer.TrySinglePrediction(
  imagesFolderPathForPredictions: string; const mlContext: IMLContextManager;
  trainedModel: IMLTransformer);
begin
  // Create prediction function to try one prediction
  var predictionEngine := mlContext.Model.CreatePredictionEngine<TInMemoryImageData, TImagePrediction>(trainedModel);

  var testImages := TFileUtils.LoadInMemoryImagesFromDirectory(imagesFolderPathForPredictions, false);

  var imageToPredict := testImages[0];


  var prediction := predictionEngine.Predict(imageToPredict);

  var predictionScores: string := '';
  for var score: Single in prediction.Score do
  begin
    if predictionScores <> '' then
      predictionScores := predictionScores + ', ';

    predictionScores := predictionScores + score.ToString;
  end;

  TConsole.NClass.WriteLine(
      'Image Filename : [{0}], ' +
      'Scores : [{1)}], ' +
      'Predicted Label : {2}', imageToPredict.ImageFileName, predictionScores, prediction.PredictedLabel);
end;

end.
