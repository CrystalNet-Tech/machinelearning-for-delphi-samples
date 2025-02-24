# MNIST Classification

In this introductory sample, you'll see how to use [ML.Net for Delphi](https://crystalnet-tech.com/Products/mldotNet4Delphi/Default) to classify handwritten digits from 0 to 9 using the MNIST dataset. This is a **multiclass classification** problem that we will solve using SDCA (Stochastic Dual Coordinate Ascent) algorithm.

## Problem

The MNIST data set contains handwritten images of digits, ranging from 0 to 9.

The MNIST dataset we are using contains 65 columns of numbers. The first 64 columns in each row are integer values in the range from 0 to 16. These values are calculated by dividing 32 x 32 bitmaps into non-overlapping blocks of 4 x 4. The number of ON pixels is counted in each of these blocks, which generates an input matrix of 8 x 8. The last column in each row is the number that is represented by the values in the first 64 columns. These first 64 columns are our features and our ML model will use these features to classifiy the testing images. The last column in our training and validation datasets is the label - the actual number that we will predict using our ML model.

the ML model that we will build will return probabilities for a given image of being one of the numbers from 0 to 9 as explained above.

## DataSet

Dataset is avaialble at UCI Machine Learning Repository i.e http://archive.ics.uci.edu/ml/datasets/Optical+Recognition+of+Handwritten+Digits

Citation to Dataset is added [here](./MNIST/Data/Datasets-Citation.txt)

## ML task - Multiclass classification
The generalized problem of **multiclass classification** is to classify items into one of three or more classes. (Classifying items into one of the two classes is called **binary classification**).

## Solution
To solve this problem, first we will build an ML model. Then we will train the model on existing data, evaluate how good it is, and lastly we'll consume the model to predict a number the given image represents.

![Build -> Train -> Evaluate -> Consume](../shared_content/modelpipeline.png)

### 1. Build model

Building a model includes: 
* Uploading data (`optdigits-train.csv`) with (`DataReader`)
* Create an Estimator and transform the data in the first 64 columns to one column so it can be used effectively by an ML algorithm (with `Concatenate`)
* Choosing a learning algorithm (`StochasticDualCoordinateAscent`). 


The initial code is similar to the following:
```Delphi
// STEP 1: Common data loading configuration
var trainData := mlContext.Data.LoadFromTextFile(TrainDataPath,
		 [
		  TMLTextLoaderColumn.Create('PixelValues', TMLDataKind.dkSingle, 0, 63),
		  TMLTextLoaderColumn.Create('Number', TMLDataKind.dkSingle, 64)
		 ], ',', False);

var testData := mlContext.Data.LoadFromTextFile(TestDataPath,
		[
		  TMLTextLoaderColumn.Create('PixelValues', TMLDataKind.dkSingle, 0, 63),
		  TMLTextLoaderColumn.Create('Number', TMLDataKind.dkSingle, 64)
		], ',', False);

// STEP 2: Common data process configuration with pipeline data transformations
// Use in-memory cache for small/medium datasets to lower training time. Do NOT use it (remove .AppendCacheCheckpoint()) when handling very large datasets.
var dataProcessPipeline := mlContext.Transforms.Conversion.MapValueToKey('Label', 'Number', 1000000, TMLKeyOrdinality.koByValue)
                                  .Append(mlContext.Transforms.Concatenate('Features', ['PixelValues'])
                                  .AppendCacheCheckpoint(mlContext));

// STEP 3: Set the training algorithm, then create and config the modelBuilder
var trainer := mlContext.MulticlassClassification.Trainers.SdcaMaximumEntropy('Label', 'Features');
var trainingPipeline := dataProcessPipeline.Append(trainer).Append(mlContext.Transforms.Conversion.MapKeyToValue('Number','Label'));
```

### 2. Train model
Training the model is a process of running the chosen algorithm on a training data to tune the parameters of the model. Our training data consists of pixel values and the digit they represent. It is implemented in the `Fit()` method from the Estimator object. 

To perform training we just call the method providing the training dataset (optdigits-train.csv file) in a DataView object.

```Delphi
// STEP 4: Train the model fitting to the DataSet            
var trainedModel := trainingPipeline.Fit(trainData);

```
### 3. Evaluate model
We need this step to conclude how accurate our model operates on new data. To do so, the model from the previous step is run against another dataset that was not used in training (`optdigits-val.csv`). `MulticlassClassification.Evaluate` calculates the difference between known types and values predicted by the model in various metrics.

```Delphi
var predictions := trainedModel.Transform(testData);
var metrics := mlContext.MulticlassClassification.Evaluate(predictions, 'Number', 'Score')

ConsoleHelper.PrintMultiClassClassificationMetrics(trainer.ToString(), metrics);
```

>*To learn more on how to understand the metrics, check out the Machine Learning glossary from the [ML.NET Guide](https://docs.microsoft.com/en-us/dotnet/machine-learning/) or use any available materials on data science and machine learning*.

If you are not satisfied with the quality of the model, there are a variety of ways to improve it, which will be covered in the *examples* category.

### 4. Consume model
After the model is trained, we can use the `Predict()` API to predict the probability of being correct digit.

```Delphi
var
  modelInputSchema: IMLDataViewSchema;
  ModelPath: string;
[...]

ModelPath := GetAbsolutePath(ModelRelativePath);
var trainedModel := mlContext.Model.Load(ModelPath, modelInputSchema);

// Create prediction engine related to the loaded trained model
var predEngine := mlContext.Model.CreatePredictionEngine<TInputData, TTOutPutData>(trainedModel);

var resultprediction1 := predEngine.Predict(SampleMNISTData.MNIST1);

TConsole.NClass.WriteLine('Actual: 7     Predicted probability:       zero:  {0:0.####}', resultprediction1.Score[0]);
TConsole.NClass.WriteLine('                                           One :  {0:0.####}', resultprediction1.Score[1]);
TConsole.NClass.WriteLine('                                           two:   {0:0.####}', resultprediction1.Score[2]);
TConsole.NClass.WriteLine('                                           three: {0:0.####}', resultprediction1.Score[3]);
TConsole.NClass.WriteLine('                                           four:  {0:0.####}', resultprediction1.Score[4]);
TConsole.NClass.WriteLine('                                           five:  {0:0.####}', resultprediction1.Score[5]);
TConsole.NClass.WriteLine('                                           six:   {0:0.####}', resultprediction1.Score[6]);
TConsole.NClass.WriteLine('                                           seven: {0:0.####}', resultprediction1.Score[7]);
TConsole.NClass.WriteLine('                                           eight: {0:0.####}', resultprediction1.Score[8]);
TConsole.NClass.WriteLine('                                           nine:  {0:0.####}', resultprediction1.Score[9]);
TConsole.NClass.WriteLine();
```

Where `SampleMNISTData.MNIST1` stores the pixel values of the digit that want to predict using the ML model.

```Delphi
[...]

constructor TSampleMNISTData.Create;
begin
  FMNIST1 := TInputData.Create;
  with FMNIST1 do
  begin
    PixelValues := [ 0, 0, 0, 0, 14, 13, 1, 0, 0, 0, 0, 5, 16, 16, 2, 0, 0, 0, 0, 14, 16, 12, 0, 0, 0, 1, 10, 16, 16, 12, 0, 0, 0, 3, 12, 14, 16, 9, 0, 0, 0, 0, 0, 5, 16, 15, 0, 0, 0, 0, 0, 4, 16, 14, 0, 0, 0, 0, 0, 1, 13, 16, 1, 0 ];
  end; //num 1

[...]
```
