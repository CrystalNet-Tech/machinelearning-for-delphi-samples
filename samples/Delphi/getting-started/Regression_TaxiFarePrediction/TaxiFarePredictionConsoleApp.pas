unit TaxiFarePredictionConsoleApp;


interface

uses MLContextMgr, TaxiFarePrediction_Models, MLData, MLCore;

type
  TTaxiFarePredictionConsoleApp = class
  private
    class function BuildTrainEvaluateAndSaveModel(mlContext: IMLContextManager): IMLTransformer;
    class procedure TestSinglePrediction(MLContext: IMLContextManager);
  public
    class procedure Run;
  end;

implementation

uses MLOptions, CrystalNet.Console, CrystalNet.Runtime, ConsoleHelper, CrystalNet.Runtime.Enums;

const
  BaseDatasetsRelativePath = '..\..\Data';
  TrainDataRelativePath = BaseDatasetsRelativePath + '\taxi-fare-train.csv';
  TestDataRelativePath = BaseDatasetsRelativePath + '\taxi-fare-test.csv';
  BaseModelsRelativePath = '..\..\MLModels';
  ModelRelativePath = BaseModelsRelativePath+ '\TaxiFareModel.zip';

{ TTaxiFarePredictionConsoleApp }

class procedure TTaxiFarePredictionConsoleApp.Run;
var
  mlContext: IMLContextManager;
begin
  //Create ML Context with seed for repeatable/deterministic results
  mlContext := TMLContextManager.Create(0);

  // Create, Train, Evaluate and Save a model
  BuildTrainEvaluateAndSaveModel(mlContext);

  // Make a single test prediction loding the model from .ZIP file
  TestSinglePrediction(mlContext);

//  // Paint regression distribution chart for a number of elements read from a Test DataSet file
//  PlotRegressionChart(mlContext, TestDataPath, 100, []);

  TConsole.NClass.WriteLine('Press any key to exit..');
  TConsole.NClass.ReadLine();
end;

class function TTaxiFarePredictionConsoleApp.BuildTrainEvaluateAndSaveModel(
  mlContext: IMLContextManager): IMLTransformer;
var
  TrainDataPath, TestDataPath, ModelPath : string;
begin
  TrainDataPath := GetAbsolutePath(TrainDataRelativePath);
  TestDataPath := GetAbsolutePath(TestDataRelativePath);
  ModelPath := GetAbsolutePath(ModelRelativePath);

  // STEP 1: Common data loading configuration
  var baseTrainingDataView := mlContext.Data.LoadFromTextFile<TTaxiTrip>(TrainDataPath, ',', True);
  var testDataView := mlContext.Data.LoadFromTextFile<TTaxiTrip>(TestDataPath, ',', True);

  //Sample code of removing extreme data like 'outliers' for FareAmounts higher than $150 and lower than $1 which can be error-data
  var cnt := baseTrainingDataView.GetColumn<System.Single>('FareAmount').Count;
  var trainingDataView := mlContext.Data.FilterRowsByColumn(baseTrainingDataView, 'FareAmount', 1, 150);
  var cnt2 := trainingDataView.GetColumn<System.Single>('FareAmount').Count;

  // STEP 2: Common data process configuration with pipeline data transformations
  var dataProcessPipeline := mlContext.Transforms.CopyColumns('Label', 'FareAmount')
                  .Append(mlContext.Transforms.Categorical.OneHotEncoding('VendorIdEncoded', 'VendorId'))
                  .Append(mlContext.Transforms.Categorical.OneHotEncoding('RateCodeEncoded', 'RateCode'))
                  .Append(mlContext.Transforms.Categorical.OneHotEncoding('PaymentTypeEncoded', 'PaymentType'))
                  .Append(mlContext.Transforms.NormalizeMeanVariance('PassengerCount'))
                  .Append(mlContext.Transforms.NormalizeMeanVariance('TripTime'))
                  .Append(mlContext.Transforms.NormalizeMeanVariance('TripDistance'))
                  .Append(mlContext.Transforms.Concatenate('Features',
                    ['VendorIdEncoded', 'RateCodeEncoded', 'PaymentTypeEncoded', 'PassengerCount', 'TripTime', 'TripDistance']));

  // (OPTIONAL) Peek data (such as 5 records) in training DataView after applying the ProcessPipeline's transformations into 'Features'
  PeekDataViewInConsole(mlContext, trainingDataView, dataProcessPipeline, 5);
  PeekVectorColumnDataInConsole(mlContext, 'Features', trainingDataView, dataProcessPipeline, 5);

  // STEP 3: Set the training algorithm, then create and config the modelBuilder - Selected Trainer (SDCA Regression algorithm)
  var trainer := mlContext.Regression.Trainers.Sdca('Label', 'Features');
  var trainingPipeline := dataProcessPipeline.Append(trainer);

  // STEP 4: Train the model fitting to the DataSet
  //The pipeline is trained on the dataset that has been loaded and transformed.
  TConsole.NClass.WriteLine('=============== Training the model ===============');
  var trainedModel := trainingPipeline.Fit(trainingDataView);

  // STEP 5: Evaluate the model and show accuracy stats
  TConsole.NClass.WriteLine('===== Evaluating Model''s accuracy with Test data =====');

  var predictions := trainedModel.Transform(testDataView);
  var metrics := mlContext.Regression.Evaluate(predictions, 'Label', 'Score');

  PrintRegressionMetrics(trainer.ToString(), metrics);

  // STEP 6: Save/persist the trained model to a .ZIP file
  mlContext.Model.Save(trainedModel, trainingDataView.Schema, ModelPath);

  TConsole.NClass.WriteLine('The model is saved to {0}', ModelPath);

  Result := trainedModel;
end;

class procedure TTaxiFarePredictionConsoleApp.TestSinglePrediction(
  MLContext: IMLContextManager);
var
  modelInputSchema: IMLDataViewSchema;
  ModelPath : string;
begin
  ModelPath := GetAbsolutePath(ModelRelativePath);

  //Sample:
  //vendor_id,rate_code,passenger_count,trip_time_in_secs,trip_distance,payment_type,fare_amount
  //VTS,1,1,1140,3.75,CRD,15.5

  var taxiTripSample := TTaxiTrip.Create;
  with taxiTripSample do
  begin
    VendorId := 'VTS';
    RateCode := '1';
    PassengerCount := 1;
    TripTime := 1140;
    TripDistance := 3.75;
    PaymentType := 'CRD';
    FareAmount := 0; // To predict. Actual/Observed := 15.5
  end;

  ///
  var trainedModel := mlContext.Model.Load(ModelPath, modelInputSchema);

  // Create prediction engine related to the loaded trained model
  var predEngine := mlContext.Model.CreatePredictionEngine<TTaxiTrip, TTaxiTripFarePrediction>(trainedModel);

  //Score
  var resultprediction := predEngine.Predict(taxiTripSample);
  ///

  TConsole.NClass.WriteLine('**********************************************************************');
  TConsole.NClass.WriteLine('Predicted fare: {0:0.####}, actual fare: 15.5', resultprediction.FareAmount);
  TConsole.NClass.WriteLine('**********************************************************************');
end;

end.
