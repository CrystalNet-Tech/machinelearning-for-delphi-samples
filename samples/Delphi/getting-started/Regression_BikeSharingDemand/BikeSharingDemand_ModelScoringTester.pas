unit BikeSharingDemand_ModelScoringTester;

interface

uses MLContextMgr, BikeSharingDemand_Models, MLData, System.Generics.Collections;

type
  TModelScoringTester = class
  private
    class function ReadSampleDataFromCsvFile(dataLocation: string; numberOfRecordsToRead: Integer): System.Generics.Collections.TList<TDemandObservation>; static;
  public
    class procedure VisualizeSomePredictions(mlContext: IMLContextManager; modelName: string; testDataLocation: string;
                                            predEngine: MLPredictionEngine<TDemandObservation, TDemandPrediction>;
                                            numberOfPredictions: Integer); static;
  end;

implementation

uses ConsoleHelper, System.SysUtils, CrystalNet.IO.FileSystem, StrUtils, CrystalNet.Runtime;

{ TModelScoringTester }

class function TModelScoringTester.ReadSampleDataFromCsvFile(
  dataLocation: string;
  numberOfRecordsToRead: Integer): System.Generics.Collections.TList<TDemandObservation>;
var
  index: Integer;
  value: string;
  x: TArray<string>;
begin
  Result := System.Generics.Collections.TList<TDemandObservation>.Create;
  var lines := TFile.NClass.ReadLines(dataLocation);
  var enuemartorOfString := lines.GetEnumerator;
  index := 0;
  while enuemartorOfString.MoveNext do
  begin
    if index = 0 then
      Continue;

    value := enuemartorOfString.Current;
    if String.IsNullOrWhiteSpace(value) then
      Continue;

    x := value.Split([',']);
    var DemandObservation := TDemandObservation.Create;
    with DemandObservation do
    begin
      Season := TSingle.NClass.Parse(x[2]);
      Year := TSingle.NClass.Parse(x[3]);
      Month := TSingle.NClass.Parse(x[4]);
      Hour := TSingle.NClass.Parse(x[5]);
      Holiday := TSingle.NClass.Parse(x[6]);
      Weekday := TSingle.NClass.Parse(x[7]);
      WorkingDay := TSingle.NClass.Parse(x[8]);
      Weather := TSingle.NClass.Parse(x[9]);
      Temperature := TSingle.NClass.Parse(x[10]);
      NormalizedTemperature := TSingle.NClass.Parse(x[11]);
      Humidity := TSingle.NClass.Parse(x[12]);
      Windspeed := TSingle.NClass.Parse(x[13]);
      Count := TSingle.NClass.Parse(x[16])
    end;

    Result.Add(DemandObservation);

    if Result.Count > numberOfRecordsToRead then
      Exit;

    Inc(index)
  end;
end;

class procedure TModelScoringTester.VisualizeSomePredictions(
  mlContext: IMLContextManager; modelName, testDataLocation: string;
  predEngine: MLPredictionEngine<TDemandObservation, TDemandPrediction>;
  numberOfPredictions: Integer);
begin
  //Make a few prediction tests
  // Make the provided number of predictions and compare with observed data from the test dataset
  var testData := ReadSampleDataFromCsvFile(testDataLocation, numberOfPredictions);
  try
    for var i: Integer := 0 to numberOfPredictions - 1 do
    begin
      //Score
      var resultprediction := predEngine.Predict(testData[i]);

      ConsoleHelper.PrintRegressionPredictionVersusObserved(FloatToStr(resultprediction.PredictedCount), FloatToStr(testData[i].Count));
    end;

  finally
    testData.Free;
  end;
end;

end.
