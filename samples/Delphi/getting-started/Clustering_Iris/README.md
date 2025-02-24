# Clustering Iris Data

In this introductory sample, you'll see how to use [ML.Net for Delphi](https://crystalnet-tech.com/Products/mldotNet4Delphi/Default) to divide iris flowers into different groups that correspond to different types of iris. In the world of machine learning, this task is known as **clustering**.

## Problem
To demonstrate clustering API in action, we will use three types of iris flowers: setosa, versicolor, and virginica. All of them are stored in the same dataset. Even though the type of these flowers is known, we will not use it and run clustering algorithm only on flower parameters such as petal length, petal width, etc. The task is to group all flowers into three different clusters. We would expect the flowers of different types belong to different clusters.

The inputs of the model are following iris parameters:
* petal length
* petal width
* sepal length
* sepal width

## ML task - Clustering
The generalized problem of **clustering** is to group a set of objects in such a way that objects in the same group are more similar to each other than to those in other groups.

Some other examples of clustering:
* group news articles into topics: sports, politics, tech, etc.
* group customers by purchase preferences.
* divide a digital image into distinct regions for border detection or object recognition.

Clustering can look similar to multiclass classification, but the difference is that for clustering tasks we don't know the answers for the past data. So there is no "tutor"/"supervisor" that can tell if our algorithm's prediction was right or wrong. This type of ML task is called **unsupervised learning**.

## Solution
To solve this problem, first we will build and train an ML model. Then we will use trained model for predicting a cluster for iris flowers.

### 1. Build model

Building a model includes: uploading data (`iris-full.txt` with `TextLoader`), transforming the data so it can be used effectively by an ML algorithm (with `Concatenate`), and choosing a learning algorithm (`KMeans`). All of those steps are stored in `trainingPipeline`:
```Delphi
//Create the MLContext to share across components for deterministic results
var mlContext: IMLContextManager := TMLContextManager.Create(0); ////Seed set to any number so you have a deterministic environment

// STEP 1: Common data loading configuration
var TextLoaderColumns: TArray<IMLTextLoaderColumn> :=  [
                                                        TMLTextLoaderColumn.Create('Label', TMLDataKind.dkSingle, 0),
                                                        TMLTextLoaderColumn.Create('SepalLength', TMLDataKind.dkSingle, 1),
                                                        TMLTextLoaderColumn.Create('SepalWidth', TMLDataKind.dkSingle, 2),
                                                        TMLTextLoaderColumn.Create('PetalLength', TMLDataKind.dkSingle, 3),
                                                        TMLTextLoaderColumn.Create('PetalWidth', TMLDataKind.dkSingle, 4)
                                                       ];

var fullData: IMLDataView := mlContext.Data.LoadFromTextFile(DataPath, TextLoaderColumns, True, #9{'\t'});
                                                
//Split dataset in two parts: TrainingDataset (80%) and TestDataset (20%)
var trainTestData := mlContext.Data.TrainTestSplit(fullData, 0.2);
var trainingDataView := trainTestData.TrainSet;
var testingDataView := trainTestData.TestSet;

//STEP 2: Process data transformations in pipeline
var dataProcessPipeline := mlContext.Transforms.Concatenate('Features', ['SepalLength', 'SepalWidth', 'PetalLength', 'PetalWidth']);

// STEP 3: Create and train the model     
var trainer := mlContext.Clustering.Trainers.KMeans('Features', '', 3);
var trainingPipeline := dataProcessPipeline.Append(trainer);
```
### 2. Train model
Training the model is a process of running the chosen algorithm on the given data. To perform training you need to call the Fit() method.
```Delphi
var trainedModel := trainingPipeline.Fit(trainingDataView);
```
### 3. Consume model
After the model is build and trained, we can use the `Predict()` API to predict the cluster for an iris flower and calculate the distance from given flower parameters to each cluster (each centroid of a cluster).

```Delphi
// Test with one sample text 
var sampleIrisData := TIrisData.Create;
with sampleIrisData do
begin
  SepalLength := 3.3;
  SepalWidth := 1.6;
  PetalLength := 0.2;
  PetalWidth := 5.1;
end;

// Create prediction engine related to the loaded trained model
var predEngine := mlContext.Model.CreatePredictionEngine<TIrisData, TIrisPrediction>(model);

//Score
var resultprediction := predEngine.Predict(sampleIrisData);

TConsole.NClass.WriteLine('Cluster assigned for setosa flowers: {0}', resultprediction.SelectedClusterId);

```
