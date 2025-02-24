# Fraud detection in credit cards (binary classification)

In this sample, you'll see how to use [ML.Net for Delphi](https://crystalnet-tech.com/Products/mldotNet4Delphi/Default) to predict a credit card fraud. In the world of machine learning, this type of prediction is known as binary classification.

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

## ML Task - [Binary Classification](https://en.wikipedia.org/wiki/Binary_classification)

Binary or binomial classification is the task of classifying the elements of a given set into two groups (predicting which group each one belongs to) on the basis of a classification rule. Contexts requiring a decision as to whether or not an item has some qualitative property, some specified characteristic.

If you would like to learn how to detect fraud using anomaly detection, visit the [Anomaly Detection Credit Card Fraud Detection sample](../AnomalyDetection_CreditCardFraudDetection).
  
## Solution

To solve this problem, first you need to build a machine learning model. Then you train the model on existing training data, evaluate how good its accuracy is, and lastly you consume the model (deploying the built model in a different app) to predict a fraud for a sample credit card transaction.

![Build -> Train -> Evaluate -> Consume](../shared_content/modelpipeline.png)


### 1. Build model
Building a model includes:

- Preapre the data and split data for training and tests

- Load the data with TextLoader by specifying the type name that holds data's schema to be mapped with datasets.

- Create an Estimator and transform the data with a Concatenate() and Normalize by Mean Variance. 

- Choosing a trainer/learning algorithm (FastTree) to train the model with.


The initial code is similar to the following:

`````Delphi

    // Create a common ML.NET context.
    // Seed set to any number so you have a deterministic environment for repeateable results
    var mlContext := TMLContextManager.Create(1);

[...]

// Prepare data and create Train/Test split datasets
    PrepDatasets(mlContext, fullDataSetFilePath, trainDataSetFilePath, testDataSetFilePath);

[...]

// Load Datasets
var trainingDataView: IMLDataView := mlContext.Data.LoadFromTextFile<TTransactionObservation>(trainDataSetFilePath, ',', True);
var testDataView: IMLDataView := mlContext.Data.LoadFromTextFile<TTransactionObservation>(testDataSetFilePath, ',', true);

    
[...]

   //Get all the feature column names (All except the Label and the IdPreservationColumn)
   var featureColumnNames := trainDataView.Schema.AsEnumerable()
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
                                                               .Append(mlContext.Transforms.NormalizeMeanVariance('FeaturesNormalizedByMeanVar', 'Features'));

    // Set the training algorithm
    var trainer := mlContext.BinaryClassification.Trainers.FastTree('Label', 'FeaturesNormalizedByMeanVar');

`````

### 2. Train model
Training the model is a process of running the chosen algorithm on a training data (with known fraud values) to tune the parameters of the model. It is implemented in the `Fit()` method from the Estimator object.

To perform training you need to call the `Fit()` method by passing `trainingDataView` object.

`````Delphi    
    var model: IMLTransformer := trainingPipeline.Fit(trainDataView);
`````

### 3. Evaluate model
We need this step to conclude how accurate our model is. To do so, the model from the previous step is run against another dataset that was not used in training (`testDataView`). 

`Evaluate()` compares the predicted values for the test dataset and produces various metrics, such as accuracy, you can explore.

`````Delphi
    EvaluateModel(mlContext, model, testDataView, trainerName);
`````

### 4. Consume model
After the model is trained, you can use the `Predict()` API to predict if a transaction is a fraud, using a IDataSet.

`````Delphi
[...]

 var
   model: IMLTransformer;
   inputSchema: IMLDataViewSchema;
 begin
   var model := mlContext.Model.Load(_modelfile, inputSchema);

   var predictionEngine := mlContext.Model.CreatePredictionEngine<TransactionObservation, TransactionFraudPrediction>(model);
   
[...]

   mlContext.Data.CreateEnumerable<TTransactionObservation>(inputDataForPredictions, false)
                    .Where(function(x: TTransactionObservation): Boolean
                           begin
                            Result := x.&Label = true;
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
                            Result := x.&Label = False;
                           end)
                    .Take(numberOfPredictions)
                    .ForEach(procedure(testData: TTransactionObservation)
                             begin
                               TConsole.NClass.WriteLine('--- Transaction ---');
                               testData.PrintToConsole();
                               predictionEngine.Predict(testData).PrintToConsole(model.GetOutputSchema(inputDataForPredictions.Schema));
                               TConsole.NClass.WriteLine('-------------------');
                             end);

`````
