unit ProductRecommenderConsoleApp;

interface
uses MLContextMgr;

type
  TProductRecommenderConsoleApp = class
  public
    class procedure Run;
  end;

implementation
uses CrystalNet.Console, MLOptions, ProductRecommender_Models, MLData,  CrystalNet.Runtime,ConsoleHelper;


//1. Do remember to replace amazon0302.txt with dataset from https://snap.stanford.edu/data/amazon0302.html
//2. Replace column names with ProductID and CoPurchaseProductID. It should look like this:
//   ProductID	CoPurchaseProductID
//   0	1
//   0  2
const
  BaseDataSetRelativePath = '..\..\Data';
  TrainingDataRelativePath = BaseDataSetRelativePath + '\Amazon0302.txt';

{ TProductRecommenderConsoleApp }

class procedure TProductRecommenderConsoleApp.Run;
var
  TrainingDataLocation: string;
begin
  TrainingDataLocation := GetAbsolutePath(TrainingDataRelativePath);

  //STEP 1: Create MLContext to be shared across the model creation workflow objects
  var mlContext := TMLContextManager.Create;

  //STEP 2: Read the trained data using TextLoader by defining the schema for reading the product co-purchase dataset
  //        Do remember to replace amazon0302.txt with dataset from https://snap.stanford.edu/data/amazon0302.html
  var traindata := mlContext.Data.LoadFromTextFile(TrainingDataLocation,
              [
                 TMLTextLoaderColumn.Create('Label', TMLDataKind.dkSingle, 0),
                 TMLTextLoaderColumn.Create('ProductID', TMLDataKind.dkUInt32, [TMLTextLoaderRange.Create(1)], TMLKeyCount.Create(262111)),
                 TMLTextLoaderColumn.Create('CoPurchaseProductID', TMLDataKind.dkUInt32, [TMLTextLoaderRange.Create(1)], TMLKeyCount.Create(262111))
              ], #9, True);

  //STEP 3: Your data is already encoded so all you need to do is specify options for MatrxiFactorizationTrainer with a few extra hyperparameters
  //        LossFunction, Alpa, Lambda and a few others like K and C as shown below and call the trainer.
  var options: IMLMatrixFactorizationTrainerOptions := TMLMatrixFactorizationTrainerOptions.Create();
  options.MatrixColumnIndexColumnName := 'ProductID';
  options.MatrixRowIndexColumnName := 'CoPurchaseProductID';
  options.LabelColumnName := 'Label';
  options.LossFunction := TMLLossFunctionType.lftSquareLossOneClass;
  options.Alpha := 0.01;
  options.Lambda := 0.025;
  // For better results use the following parameters
  //options.K = 100;
  //options.C = 0.00001;

  //Step 4: Call the MatrixFactorization trainer by passing options.
  var est := mlContext.Recommendation().Trainers.MatrixFactorization(options);

  //STEP 5: Train the model fitting to the DataSet
  //Please add Amazon0302.txt dataset from https://snap.stanford.edu/data/amazon0302.html to Data folder if FileNotFoundException is thrown.
  var model := est.Fit(traindata);

  //STEP 6: Create prediction engine and predict the score for Product 63 being co-purchased with Product 3.
  //        The higher the score the higher the probability for this particular productID being co-purchased
  var predictionengine := mlContext.Model.CreatePredictionEngine<TProductEntry, TCopurchase_prediction>(model);

  var ProductEntry := TProductEntry.Create;
  ProductEntry.ProductID := 3;
  ProductEntry.CoPurchaseProductID := 63;
  var prediction := predictionengine.Predict(ProductEntry);

  TConsole.NClass.WriteLine('\n For ProductID = 3 and  CoPurchaseProductID = 63 the predicted score is {0}', TMath.NClass.Round(prediction.Score, 1));
  TConsole.NClass.WriteLine('=============== End of process, hit any key to finish ===============');
  TConsole.NClass.ReadKey();
end;

end.
