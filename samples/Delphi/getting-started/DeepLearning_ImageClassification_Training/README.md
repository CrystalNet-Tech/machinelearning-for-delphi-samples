# Image Classification Model Training - Preferred API (Based on native TensorFlow transfer learning)

## Problem
Image classification is a common problem within the Deep Learning subject. This sample shows how to create your own custom image classifier by training your model based on the transfer learning approach which is basically retraining a pre-trained model (architecture such as InceptionV3 or ResNet) so you get a custom model trained on your own images.

In this sample app you create your own custom image classifier model by natively training a TensorFlow model from ML.NET API with your own images.

*Image classifier scenario – Train your own custom deep learning model with ML.NET*
![](https://devblogs.microsoft.com/dotnet/wp-content/uploads/sites/10/2019/08/image-classifier-scenario.png)


## Dataset (Imageset)

> *Image set license*
>
> This sample's dataset is based on the 'flower_photos imageset' available from Tensorflow at [this URL](http://download.tensorflow.org/example_images/flower_photos.tgz).
> All images in this archive are licensed under the Creative Commons By-Attribution License, available at:
https://creativecommons.org/licenses/by/2.0/
>
> The full license information is provided in the LICENSE.txt file which is included as part of the same image set downloaded as a .zip file.

The by default imageset being downloaded by the sample has 200 images evenly distributed across 5 flower classes:

    Images --> flower_photos_small_set -->
               |
               daisy
               |
               dandelion
               |
               roses
               |
               sunflowers
               |
               tulips

The name of each sub-folder is important because that'll be the name of each class/label the model is going to use to classify the images.

## ML Task - Image Classification

To solve this problem, first we will build an ML model. Then we will train the model on existing data, evaluate how good it is, and lastly we'll consume the model to classify a new image.

![](../shared_content/modelpipeline.png)

### 1. Build Model

Building the model includes the following steps:
* Loading the image files (file paths in this case) into an IDataView
* Image classification using the ImageClassification estimator (high level API)

Define the schema of data in a class type and refer that type while loading the images from the files folder.

```Delphi
TImageData = class(TMLEntity)
private
  FLabel: string;
  FImagePath: string;
public
  Constructor Create(imagePath: string; &Label: string);

  property &Label: string read FLabel write FLabel;
  property ImagePath: string read FImagePath write FImagePath;
end;
```

Since the API uses in-memory images so later on you'll be able to score the model with in-memory images, you need to define a class containing the image's bits in the type `byte[] Image`, like the following:

```Delphi
TInMemoryImageData = class(TMLEntity)
private
  FImage: TArray<byte>;
  FLabel: string;
  FImageFileName: string;
public
  Constructor Create(Image: TArray<byte>; &Label: string; ImageFileName: string);

  property Image: TArray<byte> read FImage write FImage;
  property &Label: string read FLabel write FLabel;
  property ImageFileName: string read FImageFileName write FImageFileName;
end;
```

Download the imageset and load its information by using the LoadImagesFromDirectory() and LoadFromEnumerable().

```Delphi
// 1. Download the image set and unzip
var finalImagesFolderName: string := DownloadImageSet(imagesDownloadFolderPath);
var fullImagesetFolderPath: string := TPath.NClass.Combine(imagesDownloadFolderPath, finalImagesFolderName);

var mlContext: IMLContextManager := TMLContextManager.Create(1);

// 2. Load the initial full image-set into an IDataView and shuffle so it'll be better balanced
var images: TArray<TImageData> := LoadImagesFromDirectory(fullImagesetFolderPath, True);
var fullImagesDataset: MLDataView := mlContext.Data.LoadFromEnumerable<TImageData>(images);
var shuffledFullImageFilePathsDataset: MLDataView := mlContext.Data.ShuffleRows(fullImagesDataset);
```

Once it's loaded into the IMLDataView, the rows are shuffled so the dataset is better balanced before spliting into the training/test datasets.

Now, this next step is very important. Since we want the ML model to work with in-memory images, we need to load the images into the dataset and actually do it by calling fit() and transform().
This step needs to be done in a initial and seggregated pipeline in the first place so the filepaths won't be used by the pipeline and model to create when training.

```Delphi
// 3. Load Images with in-memory type within the IDataView and Transform Labels to Keys (Categorical)
var shuffledFullImagesDataset: MLDataView := mlContext.Transforms.Conversion.MapValueToKey('LabelAsKey', 'Label', 1000000, TMLKeyOrdinality.KoByValue)
                                                  .Append(mlContext.Transforms.LoadRawImageBytes('Image', fullImagesetFolderPath, 'ImagePath'))
                                                  .Fit(shuffledFullImageFilePathsDataset)
                                                  .Transform(shuffledFullImageFilePathsDataset);
```

In addition we also transformed the Labels to Keys (Categorical) before splitting the dataset. This is also important to do it before splitting if you don't want to deal/match the KeyOrdinality if transforming the labels in a second pipeline (the training pipeline).

Now, let's split the dataset in two datasets, one for training and the second for testing/validating the quality of the model.

```Delphi
// 4. Split the data 80:20 into train and test sets, train and evaluate.
var trainTestData := mlContext.Data.TrainTestSplit(shuffledFullImagesDataset, 0.2);
var trainDataView: IMLDataView := trainTestData.TrainSet;
var testDataView: IMLDataView := trainTestData.TestSet;
```

As the most important step, you define the model's training pipeline where you can see how easily you can train a new TensorFlow model which under the covers is based on transfer learning from a by default architecture (pre-trained model) such as *Resnet V2 500*.

```Delphi
// 5. Define the model's training pipeline using DNN default values
//
var pipeline := mlContext.MulticlassClassification.Trainers.ImageClassification('LabelAsKey', 'Image', 'Score', 'PredictedLabel', testDataView)
                  .Append(mlContext.Transforms.Conversion.MapKeyToValue('PredictedLabel', 'PredictedLabel'));

```

The important line in the above code is the line using the `mlContext.MulticlassClassification.Trainers.ImageClassification` classifier trainer which as you can see is a high level API where you just need to provide which column has the images, the column with the labels (column to predict) and a validation dataset to calculate quality metrics while training so the model can tune itself (change internal hyper-parameters) while training.

Under the covers this model training is based on a native TensorFlow DNN transfer learning from a default architecture (pre-trained model) such as *Resnet V2 50*. You can also select the one you want to derive from by configuring the optional hyper-parameters.

It is that simple, you don't even need to make image transformations (resize, normalizations, etc.). Depending on the used DNN architecture, the framework is doing the required image transformations under the covers so you simply need to use that single API.

#### Optional use of advanced hyper-parameters

There’s another overloaded method for advanced users where you can also specify those optional hyper-parameters such as epochs, batchSize, learningRate, a specific DNN architecture such as [Inception v3](https://cloud.google.com/tpu/docs/inception-v3-advanced) or [Resnet v2101](https://medium.com/@bakiiii/microsoft-presents-deep-residual-networks-d0ebd3fe5887) and other typical DNN parameters, but most users can get started with the simplified API.

The following is how you use the advanced DNN parameters:

```Delphi
// 5.1 (OPTIONAL) Define the model's training pipeline by using explicit hyper-parameters

//var options : TMLImageClassificationTrainerOptions.Create();
//with options do
//begin
//    FeatureColumnName := 'Image';
//    LabelColumnName := 'LabelAsKey';
//    // Just by changing/selecting InceptionV3/MobilenetV2/ResnetV250
//    // you can try a different DNN architecture (TensorFlow pre-trained model).
//    Arch := TMLArchitecture.aMobilenetV2,
//    Epoch := 50;       //100
//    BatchSize := 10;
//    LearningRate := 0.01;,
//    MetricsCallback := procedure (metrics) begin TConsole.NClass.WriteLine(metrics) end;
//    ValidationSet := testDataView;
//end;

//var pipeline := mlContext.MulticlassClassification.Trainers.ImageClassification(options)
//        .Append(mlContext.Transforms.Conversion.MapKeyToValue('PredictedLabel', 'PredictedLabel'));
```

### 2. Train model
In order to begin the training process you run `Fit` on the built pipeline:

```Delphi
// 4. Train/create the ML model
var trainedModel: IMLTransformer := pipeline.Fit(trainDataView);
```

### 3. Evaluate model

After the training, we evaluate the model's quality by using the test dataset.

The `Evaluate` function needs an `IDataView` with the predictions generated from the test dataset by calling Transfor().

```Delphi
// 5. Get the quality metrics (accuracy, etc.)
var predictionsDataView: IMLDataView := trainedModel.Transform(testDataset);

var metrics := mlContext.MulticlassClassification.Evaluate(predictionsDataView, 'LabelAsKey', 'Score', 'PredictedLabel');
ConsoleHelper.PrintMultiClassClassificationMetrics('TensorFlow DNN Transfer Learning', metrics);
```

Finally, you save the model:
```Delphi
// Save the model to assets/outputs (You get ML.NET .zip model file and TensorFlow .pb model file)
mlContext.Model.Save(trainedModel, trainDataView.Schema, outputMlNetModelFilePath);
```
