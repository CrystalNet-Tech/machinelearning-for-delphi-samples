unit HeartDiseaseDetection_Models;

interface
uses MLCore, MLAttributes, System.Generics.Collections;

type
  THeartData = class(TMLEntity)
  public
    [LoadColumn(0)]
    Age: Single;
    [LoadColumn(1)]
    Sex: Single;
    [LoadColumn(2)]
    Cp: Single;
    [LoadColumn(3)]
    TrestBps: Single;
    [LoadColumn(4)]
    Chol: Single;
    [LoadColumn(5)]
    Fbs: Single;
    [LoadColumn(6)]
    RestEcg: Single;
    [LoadColumn(7)]
    Thalac: Single;
    [LoadColumn(8)]
    Exang: Single;
    [LoadColumn(9)]
    OldPeak: Single;
    [LoadColumn(10)]
    Slope: Single;
    [LoadColumn(11)]
    Ca: Single;
    [LoadColumn(12)]
    Thal: Single;
    [LoadColumn(13)]
    &Label: Boolean;
  end;

  THeartPrediction = class(TMLEntity)
  public
    // ColumnName attribute is used to change the column name from
    // its default value, which is the name of the field.
    [ColumnName('PredictedLabel')]
    Prediction: Boolean;

    // No need to specify ColumnName attribute, because the field
    // name "Probability" is the column name we want.
    Probability: Single;

    Score: Single;
  end;

  THeartSampleData = class
  private
    FheartDataList: TList<THeartData>;
  public
    constructor Create;
    destructor Destroy; override;
    property HeartDataList: TList<THeartData> read FheartDataList;
  end;

var
  HeartSampleData: THeartSampleData;

implementation

uses SysUtils;

{ THeartSampleData }

constructor THeartSampleData.Create;
begin
  FheartDataList := TList<THeartData>.Create;
  var heartData1 := THeartData.Create;
  with heartData1 do
  begin
    Age := 36.0;
    Sex := 1.0;
    Cp := 4.0;
    TrestBps := 145.0;
    Chol := 210.0;
    Fbs := 0.0;
    RestEcg := 2.0;
    Thalac := 148.0;
    Exang := 1.0;
    OldPeak := 1.9;
    Slope := 2.0;
    Ca := 1.0;
    Thal := 7.0;
  end;
  FheartDataList.Add(heartData1);

  var heartData2 := THeartData.Create;
  with heartData2 do
  begin
    Age := 95.0;
    Sex := 1.0;
    Cp := 4.0;
    TrestBps := 145.0;
    Chol := 210.0;
    Fbs := 0.0;
    RestEcg := 2.0;
    Thalac := 148.0;
    Exang := 1.0;
    OldPeak := 1.9;
    Slope := 2.0;
    Ca := 1.0;
    Thal := 7.0;
  end;
  FheartDataList.Add(heartData2);

  var heartData3 := THeartData.Create;
  with heartData3 do
  begin
    Age := 46.0;
    Sex := 1.0;
    Cp := 4.0;
    TrestBps := 135.0;
    Chol := 192.0;
    Fbs := 0.0;
    RestEcg := 0.0;
    Thalac := 148.0;
    Exang := 0.0;
    OldPeak := 0.3;
    Slope := 2.0;
    Ca := 0.0;
    Thal := 6.0;
  end;
  FheartDataList.Add(heartData3);

  var heartData4 := THeartData.Create;
  with heartData4 do
  begin
    Age := 45.0;
    Sex := 0.0;
    Cp := 1.0;
    TrestBps := 140.0;
    Chol := 221.0;
    Fbs := 1.0;
    RestEcg := 1.0;
    Thalac := 150.0;
    Exang := 0.0;
    OldPeak := 2.3;
    Slope := 3.0;
    Ca := 0.0;
    Thal := 6.0;
  end;
  FheartDataList.Add(heartData4);

  var heartData5 := THeartData.Create;
  with heartData5 do
  begin
    Age := 88.0;
    Sex := 0.0;
    Cp := 1.0;
    TrestBps := 140.0;
    Chol := 221.0;
    Fbs := 1.0;
    RestEcg := 1.0;
    Thalac := 150.0;
    Exang := 0.0;
    OldPeak := 2.3;
    Slope := 3.0;
    Ca := 0.0;
    Thal := 6.0;
  end;
  FheartDataList.Add(heartData5);
end;

destructor THeartSampleData.Destroy;
var
  I: Integer;
begin
  for I := 0 to FheartDataList.Count - 1 do
  begin
    FreeAndNil(FheartDataList[I]);
  end;

  FheartDataList.Free;
  inherited;
end;

initialization
  HeartSampleData := THeartSampleData.Create;
finalization
  HeartSampleData.Free;
end.
