unit ImageClassification_Predictor;

interface

type
  TPredictor = class
  public
    class procedure Execute;
    class function GetAbsolutePath(relativePath: string): string; static;
  end;

implementation

uses
  CrystalNet.Runtime,
  CrystalNet.Runtime.Intf,
  CrystalNet.Console,
  MLContextMgr,
  MLData,
  ImageClassification_Models,
  ImageClassification_Shared,
  SysUtils,
  Math,
  Microsoft.ML.DataView.Intf,
  System.Generics.Collections;

const
  assetsRelativePath = '..\..\predict_assets';

{ TPredictor }

class procedure TPredictor.Execute;
begin
  var assetsPath := GetAbsolutePath(assetsRelativePath);

  var imagesFolderPathForPredictions := TPath.NClass.Combine(assetsPath, 'inputs', 'images-for-predictions');

  //Download from : https://github.com/dotnet/machinelearning-samples/tree/main/samples/csharp/getting-started/DeepLearning_ImageClassification_Training/ImageClassification.Predict/assets/inputs/MLNETModel
  var imageClassifierModelZipFilePath := TPath.NClass.Combine(assetsPath, 'inputs', 'MLNETModel', 'imageClassifier.zip');

  try
      var mlContext: IMLContextManager := TMLContextManager.Create(1);

      TConsole.NClass.WriteLine('Loading model from: {0}', imageClassifierModelZipFilePath);

      // Load the model
      var modelInputSchema: IMLDataViewSchema;
      var loadedModel := mlContext.Model.Load(imageClassifierModelZipFilePath, modelInputSchema);

      // Create prediction engine to try a single prediction (input = ImageData, output = ImagePrediction)
      var predictionEngine := mlContext.Model.CreatePredictionEngine<TInMemoryImageData, TImagePrediction>(loadedModel);

      //Predict the first image in the folder
      var imagesToPredict := TFileUtils.LoadInMemoryImagesFromDirectory(imagesFolderPathForPredictions, false);

      var imageToPredict := imagesToPredict[0];

      // Measure #1 prediction execution time.
      var watch := TStopwatch.NClass.StartNew();

      var prediction := predictionEngine.Predict(imageToPredict);

      // Stop measuring time.
      watch.Stop();
      var elapsedMs := watch.ElapsedMilliseconds;
      TConsole.NClass.WriteLine('First Prediction took: ' + elapsedMs.ToString + 'mlSecs');

      // Measure #2 prediction execution time.
      var watch2 := TStopwatch.NClass.StartNew();

      var prediction2 := predictionEngine.Predict(imageToPredict);

      // Stop measuring time.
      watch2.Stop();
      var elapsedMs2 := watch2.ElapsedMilliseconds;
      TConsole.NClass.WriteLine('Second Prediction took: ' + elapsedMs2.ToString + 'mlSecs');

      // Get the highest score and its index
      var maxScore := MaxValue(prediction.Score);

      TConsole.NClass.WriteLine('Image Filename : [{0}], ' +
                                'Predicted Label : [{1}], ' +
                                'Probability : [{2}] ', imageToPredict.ImageFileName, prediction.PredictedLabel, maxScore);

      //Predict all images in the folder
      //
      TConsole.NClass.WriteLine('');
      TConsole.NClass.WriteLine('Predicting several images...');

      for var currentImageToPredict in imagesToPredict do
      begin
        var currentPrediction := predictionEngine.Predict(currentImageToPredict);

        TConsole.NClass.WriteLine(
            'Image Filename : [{0}], ' +
            'Predicted Label : [{1}], ' +
            'Probability : [{2}]', currentImageToPredict.ImageFileName, currentPrediction.PredictedLabel, MaxValue(currentPrediction.Score));
      end;
  except
    on EX: Exception do
      TConsole.NClass.WriteLine(EX.ToString());
  end;

  TConsole.NClass.WriteLine('Press any key to end the app..');
  TConsole.NClass.ReadKey();
end;

class function TPredictor.GetAbsolutePath(relativePath: string): string;
begin
  Result := TFileUtils.GetAbsolutePath(relativePath);
end;

end.
