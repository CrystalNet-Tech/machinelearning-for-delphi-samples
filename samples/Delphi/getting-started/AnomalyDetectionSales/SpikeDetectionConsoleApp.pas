unit SpikeDetectionConsoleApp;

//https://github.com/dotnet/machinelearning-samples/tree/main/samples/csharp/end-to-end-apps/AnomalyDetection-Sales

interface

uses MLContextMgr, SpikeDetection_Models, MLData, MLCore;

type
  TSpikeDetectionConsoleApp = class
  private
    class var mlContext: IMLContextManager;
    class function DetectSpike(Size: Integer; DataView: IMLDataView): IMLTransformer;
    class function DetectChangepoint(Size: Integer; DataView: IMLDataView): IMLTransformer;
    class procedure SaveModel(MLContext: IMLContextManager; TrainedModel: IMLTransformer; ModelPath: string; DataView: IMLDataView);
    class function CreateEmptyDataView(): IMLDataView;
  public
    class procedure Run;
  end;


implementation

uses MLOptions, CrystalNet.Console, CrystalNet.Console.Enums, CrystalNet.Runtime, ConsoleHelper, CrystalNet.Runtime.Enums;

const
  BaseDatasetsRelativePath = '..\..\Data';
  DatasetRelativePath = BaseDatasetsRelativePath + '/Product-sales.csv';
  BaseModelsRelativePath = '..\..\MLModels';
  ModelRelativePath1 = BaseModelsRelativePath + '/ProductSalesSpikeModel.zip';
  ModelRelativePath2 = BaseModelsRelativePath + '/ProductSalesChangePointModel.zip';


{ TSpikeDetectionConsoleApp }

class function TSpikeDetectionConsoleApp.CreateEmptyDataView: IMLDataView;
begin
  //Create empty DataView. We just need the schema to call fit()
  var enumerableData: TArray<TProductSalesData>;
  Result := mlContext.Data.LoadFromEnumerable<TProductSalesData>(enumerableData);
end;

class function TSpikeDetectionConsoleApp.DetectChangepoint(Size: Integer;
  DataView: IMLDataView): IMLTransformer;
begin
  TConsole.NClass.WriteLine('===============Detect Persistent changes in pattern===============');

  // STEP 1: Setup transformations using DetectIidChangePoint.
  var estimator := mlContext.Transforms.DetectIidChangePoint('Prediction', 'numSales', 95, Trunc(Size / 4));

  // STEP 2:The Transformed Model.
  // In IID Change point detection, we don't need need to do training, we just need to do transformation.
  // As you are not training the model, there is no need to load IDataView with real data, you just need schema of data.
  // So create empty data view and pass to Fit() method.
  var tansformedModel := estimator.Fit(CreateEmptyDataView());

  // STEP 3: Use/test model.
  // Apply data transformation to create predictions.
  var transformedData := tansformedModel.Transform(dataView);
  var predictions := mlContext.Data.CreateEnumerable<TProductSalesPrediction>(transformedData, False);

  TConsole.NClass.WriteLine('Prediction column obtained post-transformation.');
  TConsole.NClass.WriteLine('Alert Score P-Value Martingale value');

  for var p in predictions do
  begin
    if p.Prediction[0] = 1 then
    begin
      TConsole.NClass.WriteLine('{0} {1:0.00} {2:0.00} {3:0.00}  <-- alert is on, predicted changepoint', [p.Prediction[0], p.Prediction[1], p.Prediction[2], p.Prediction[3]]);
    end
    else
    begin
      TConsole.NClass.WriteLine('{0} {1:0.00} {2:0.00} {3:0.00}', [p.Prediction[0], p.Prediction[1], p.Prediction[2], p.Prediction[3]]);
    end;
  end;
  TConsole.NClass.WriteLine('');

  Result := tansformedModel;
end;

class function TSpikeDetectionConsoleApp.DetectSpike(Size: Integer;
  DataView: IMLDataView): IMLTransformer;
begin
  TConsole.NClass.WriteLine('===============Detect temporary changes in pattern===============');

  // STEP 1: Create Estimator.
  var estimator := mlContext.Transforms.DetectIidSpike('Prediction', 'numSales', 95, Trunc(size / 4));

  // STEP 2:The Transformed Model.
  // In IID Spike detection, we don't need to do training, we just need to do transformation.
  // As you are not training the model, there is no need to load IDataView with real data, you just need schema of data.
  // So create empty data view and pass to Fit() method.
  var tansformedModel := estimator.Fit(CreateEmptyDataView());

  // STEP 3: Use/test model.
  // Apply data transformation to create predictions.
  var transformedData := tansformedModel.Transform(dataView);
  var predictions := mlContext.Data.CreateEnumerable<TProductSalesPrediction>(transformedData, False);

  TConsole.NClass.WriteLine('Alert Score P-Value');
  for var p in predictions do
  begin
    if p.Prediction[0] = 1 then
    begin
        TConsole.NClass.BackgroundColor := TConsoleColor.ccDarkYellow;
        TConsole.NClass.ForegroundColor := TConsoleColor.ccBlack;
    end;
    TConsole.NClass.WriteLine('{0} {1:0.00} {2:0.00}', p.Prediction[0], p.Prediction[1], p.Prediction[2]);
    TConsole.NClass.ResetColor();
  end;
  TConsole.NClass.WriteLine('');

  Result := tansformedModel;
end;

class procedure TSpikeDetectionConsoleApp.SaveModel(
  MLContext: IMLContextManager; TrainedModel: IMLTransformer; ModelPath: string;
  DataView: IMLDataView);
begin
  TConsole.NClass.WriteLine('=============== Saving model ===============');
  mlcontext.Model.Save(trainedModel,dataView.Schema, modelPath);

  TConsole.NClass.WriteLine('The model is saved to {modelPath}');
end;

class procedure TSpikeDetectionConsoleApp.Run;
const
  size = 36;
var
  DatasetPath,
  SpikeModelPath,
  ChangePointModelPath: string;
begin
  DatasetPath := GetAbsolutePath(DatasetRelativePath);
  SpikeModelPath := GetAbsolutePath(ModelRelativePath1);
  ChangePointModelPath := GetAbsolutePath(ModelRelativePath2);

  // Create MLContext to be shared across the model creation workflow objects.
  mlContext := TMLContextManager.Create();

  // Assign the Number of records in dataset file to constant variable.

  // Load the data into IDataView.
  // This dataset is used for detecting spikes or changes not for training.
  var dataView := mlContext.Data.LoadFromTextFile<TProductSalesData>(DatasetPath, true, ',');

  // Detect temporary changes (spikes) in the pattern.
  var trainedSpikeModel := DetectSpike(size, dataView);

  // Detect persistent change in the pattern.
  var trainedChangePointModel := DetectChangepoint(size, dataView);

  SaveModel(mlContext, trainedSpikeModel, SpikeModelPath, dataView);
  SaveModel(mlContext, trainedChangePointModel, ChangePointModelPath, dataView);

  TConsole.NClass.WriteLine('=============== End of process, hit any key to finish ===============');
  TConsole.NClass.ReadLine();
end;

end.
