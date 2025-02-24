# Spam Detection for Text Messages

In this sample, you'll see how to use [ML.Net for Delphi](https://crystalnet-tech.com/Products/mldotNet4Delphi/Default) to predict whether a text message is spam. In the world of machine learning, this type of prediction is known as **binary classification**.

## Problem

Our goal here is to predict whether a text message is spam (an irrelevant/unwanted message). We will use the [SMS Spam Collection Data Set](https://archive.ics.uci.edu/ml/datasets/SMS+Spam+Collection) from UCI, which contains close to 6000 messages that have been classified as being "spam" or "ham" (not spam). We will use this dataset to train a model that can take in new message and predict whether they are spam or not.

This is an example of binary classification, as we are classifying the text messages into one of two categories.

## Solution
To solve this problem, first we will build an estimator to define the ML pipeline we want to use. Then we will train this estimator on existing data, evaluate how good it is, and lastly we'll consume the model to predict whether a few examples messages are spam.

![Build -> Train -> Evaluate -> Consume](../shared_content/modelpipeline.png)

### 1. Build Model

To build the model we will:

* Define how to read the spam dataset that will be downloaded from https://archive.ics.uci.edu/ml/datasets/SMS+Spam+Collection. 

* Apply several data transformations:

    * Convert the label ("spam" or "ham") to a boolean ("true" represents spam) so we can use it with a binary classifier. 
    * Featurize the text message into a numeric vector so a machine learning trainer can use it

* Add a trainer (such as `StochasticDualCoordinateAscent`).

The initial code is similar to the following:

```Delphi
// Set up the MLContext, which is a catalog of components in ML.NET.
var mlContext := TMLContextManager.Create;

// Specify the schema for spam data and read it into DataView.
var data := mlContext.Data.LoadFromTextFile<TSpamInput>(TrainDataPath, #9, True); //#9: tab

// Data process configuration with pipeline data transformations 
//=>
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
//<=

// Set the training algorithm 
var trainer := mlContext.MulticlassClassification.Trainers.OneVersusAll(mlContext.BinaryClassification.Trainers.AveragedPerceptron('Label', 'Features', nil, 1, False, 0, 10))
                          .Append(mlContext.Transforms.Conversion.MapKeyToValue('PredictedLabel', 'PredictedLabel'));
var trainingPipeLine := dataProcessPipeline.Append(trainer);
```

### 2. Evaluate model

For this dataset, we will use [cross-validation](https://en.wikipedia.org/wiki/Cross-validation_(statistics)) to evaluate our model. This will partition the data into 5 'folds', train 5 models (on each combination of 4 folds), and test them on the fold that wasn't used in training.

```Delphi
var crossValidationResults := mlContext.MulticlassClassification.CrossValidate(data, trainingPipeLine, 5);
```

Note that usually we evaluate a model after training it. However, cross-validation includes the model training part so we don't need to do `Fit()` first. However, we will later train the model on the full dataset to take advantage of the additional data.

### 3. Train model
To train the model we will call the estimator's `Fit()` method while providing the full training data.

```Delphi
var model := trainingPipeLine.Fit(data);
```

### 4. Consume model

After the model is trained, you can use the `Predict()` API to predict whether new text is spam. 

```Delphi
//Create a PredictionFunction from our model 
var predictor := mlContext.Model.CreatePredictionEngine<TSpamInput, TSpamPrediction>(model);

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

```
