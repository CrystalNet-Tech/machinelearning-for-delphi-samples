# Fraud detection in credit cards (based on anomaly/outlier detection)

In this sample, you'll see how to use ML.Net for Delphi to predict a credit card fraud. In the world of machine learning, this type of prediction is known as anomaly (or outlier) detection.
  

## API version: Dynamic and Estimators-based API

It is important to note that this sample uses the dynamic API with Estimators.
  

## Problem

This problem is centered around predicting if credit card transaction (with its related info/variables) is a fraud or no. 
 
The input dataset of the transactions contain only numerical input variables which are the result of previous PCA (Principal Component Analysis) transformations. Unfortunately, due to confidentiality issues, the original features and additional background information are not available, but the way you build the model doesn't change.  

Features V1, V2, ... V28 are the principal components obtained with PCA, the only features which have not been transformed with PCA are 'Time' and 'Amount'. 

The feature 'Time' contains the seconds elapsed between each transaction and the first transaction in the dataset. The feature 'Amount' is the transaction Amount, this feature can be used for example-dependant cost-sensitive learning. Feature 'Class' is the response variable and it takes value 1 in case of fraud and 0 otherwise.

The dataset is highly unbalanced, the positive class (frauds) account for 0.172% of all transactions.

Using those datasets you build a model that when predicting it will analyze a transaction's input variables and predict a fraud value of false or true.
  

## DataSet

The training and testing data is based on a public [dataset available at Kaggle](https://www.kaggle.com/mlg-ulb/creditcardfraud) originally from Worldline and the Machine Learning Group (http://mlg.ulb.ac.be) of ULB (Université Libre de Bruxelles), collected and analysed during a research collaboration. 

The datasets contains transactions made by credit cards in September 2013 by european cardholders. This dataset presents transactions that occurred in two days, where we have 492 frauds out of 284,807 transactions.

By: Andrea Dal Pozzolo, Olivier Caelen, Reid A. Johnson and Gianluca Bontempi. Calibrating Probability with Undersampling for Unbalanced Classification. In Symposium on Computational Intelligence and Data Mining (CIDM), IEEE, 2015

More details on current and past projects on related topics are available on http://mlg.ulb.ac.be/BruFence and http://mlg.ulb.ac.be/ARTML
  

## ML Task - [Anomaly Detection](https://en.wikipedia.org/wiki/Anomaly_detection)

Anomaly (or outlier) detection is the identification of rare items, events or observations which raise suspicions by differing significantly from the majority of the data. Typically the anomalous items will translate to some kind of problem such as bank fraud, a structural defect, medical problems or errors in a text. 

If you would like to learn how to detect fraud using binary classification, visit the [Binary Classification Credit Card Fraud Detection sample](../BinaryClassification_CreditCardFraudDetection).  

## Solution

To solve this problem, first you need to build a machine learning model. Then you train the model on existing training data, evaluate how good its accuracy is, and lastly you consume the model (deploying the built model in a different app) to predict a fraud for a sample credit card transaction.

![Build -> Train -> Evaluate -> Consume](../shared_content/modelpipeline.png)


### 1. Build model

Building a model includes:

- Prepare the data and split data for training and tests.

- Load the data with TextLoader by specifying the type name that holds data's schema to be mapped with datasets.

- Create an Estimator and transform the data with a `Concatenate()` and Normalize by LP Norm. 

- Choosing a trainer/learning algorithm Randomized PCA to train the model with.


The initial code is similar to the following:

`````Delphi

    // Create a common ML.NET context.
    // Seed set to any number so you have a deterministic environment for repeateable results
    var mlContext: IMLContextManager := TMLContextManager.Create(1);

[...]
    // Prepare data and create Train/Test split datasets
    PrepDatasets(mlContext, fullDataSetFilePath, trainDataSetFilePath, testDataSetFilePath);

[...]

    //Load the original single dataset
    var originalFullData: IMLDataView := mlContext.Data.LoadFromTextFile<TTransactionObservation>(fullDataSetFilePath, ',', true);
                
    // Split the data 80:20 into train and test sets, train and evaluate.
    var trainTestData := mlContext.Data.TrainTestSplit(originalFullData, 0.2, 1);

    // 80% of original dataset
    var trainData := trainTestData.TrainSet;

    // 20% of original dataset
    var testData := trainTestData.TestSet;
    
[...]

    // Get all the feature column names (All except the Label and the IdPreservationColumn)
  var featureColumnNames: Tarray<string> := trainDataView.Schema.AsEnumerable()
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
                                                             .Append(mlContext.Transforms.NormalizeLpNorm('NormalizedFeatures', 'Features'));


    // In Anomaly Detection, the learner assumes all training examples have label 0, as it only learns from normal examples.
    // If any of the training examples has label 1, it is recommended to use a Filter transform to filter them out before training:
    var normalTrainDataView: IMLDataView := mlContext.Data.FilterRowsByColumn(trainDataView, 'Label', 0, 1);
    
[...]

    var options := TMLRandomizedPcaTrainerOptions.Create;
    with options do
    begin
      FeatureColumnName := 'NormalizedFeatures';  // The name of the feature column. The column data must be a known-sized vector of Single.
      ExampleWeightColumnName := null;		        // The name of the example weight column (optional). To use the weight column, the column data must be of type Single.
      Rank := 7;					                        // The number of components in the PCA.
      Oversampling := 20;				                  // Oversampling parameter for randomized PCA training.
      EnsureZeroMean := true;			                // If enabled, data is centered to be zero mean.
      Seed := 1;					                        // The seed for random number generation.
    end;

    // Create an anomaly detector. Its underlying algorithm is randomized PCA.
    var trainer := mlContext.AnomalyDetection.Trainers.RandomizedPca(options);

    var trainingPipeline := dataProcessPipeline.Append(trainer);

`````


### 2. Train model

Training the model is a process of running the chosen algorithm on a training data to tune the parameters of the model. It is implemented in the `Fit()` method from the Estimator object.

To perform training you need to call the `Fit()` method while providing the training dataset (`trainData.csv`) in a DataView object.

`````Delphi    
    var model := trainingPipeline.Fit(normalTrainDataView);
`````


### 3. Evaluate model

We need this step to conclude how accurate our model is. To do so, the model from the previous step is run against another dataset that was not used in training (`testData.csv`). 

`Evaluate()` compares the predicted values for the test dataset and produces various metrics, such as AUC, you can explore.

`````Delphi
    EvaluateModel(mlContext, model, testDataView);
`````


### 4. Consume model
  
After the model is trained, you can use the `Predict()` API to predict if a transaction is a fraud, using a IDataSet.

`````Delphi
[...]

    var inputDataForPredictions: IMLDataView := mlContext.Data.LoadFromTextFile<TTransactionObservation>(_dasetFile, ',', True);

    var model: IMLTransformer := mlContext.Model.Load(_modelfile, inputSchema);

    var predictionEngine := mlContext.Model.CreatePredictionEngine<TTransactionObservation, TTransactionFraudPrediction>(model);

[...]

    mlContext.Data.CreateEnumerable<TTransactionObservation>(inputDataForPredictions, false)
                      .Where(function(x: TTransactionObservation): Boolean
                             begin
                              Result := x.&Label > 0;
                             end)
                      .Take(numberOfPredictions)
                      .ForEach(procedure(testData: TTransactionObservation)
                               begin
                                 TConsole.NClass.WriteLine('--- Transaction ---');
                                 testData.PrintToConsole();
                                 predictionEngine.Predict(testData).PrintToConsole();
                                 TConsole.NClass.WriteLine('-------------------');
                               end);
[...]

    mlContext.Data.CreateEnumerable<TTransactionObservation>(inputDataForPredictions, false)
                      .Where(function(x: TTransactionObservation): Boolean
                             begin
                              Result := x.&Label < 1;
                             end)
                      .Take(numberOfPredictions)
                      .ForEach(procedure(testData: TTransactionObservation)
                               begin
                                 TConsole.NClass.WriteLine('--- Transaction ---');
                                 testData.PrintToConsole();
                                 predictionEngine.Predict(testData).PrintToConsole();
                                 TConsole.NClass.WriteLine('-------------------');
                               end);

`````
