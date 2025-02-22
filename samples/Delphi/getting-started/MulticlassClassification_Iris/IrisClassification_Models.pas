unit IrisClassification_Models;

interface
uses MLAttributes, MLCore, System.Generics.Collections;

type
  TIrisData = class(TMLEntity)
  public
    [LoadColumn(0)]
    &Label: Single;

    [LoadColumn(1)]
    SepalLength: Single;

    [LoadColumn(2)]
    SepalWidth: Single;

    [LoadColumn(3)]
    PetalLength: Single;

    [LoadColumn(4)]
    PetalWidth: Single;
  end;

  TIrisPrediction = class(TMLEntity)
  public
    Score: TArray<Single>;
  end;

  TSampleIrisData = class
  private
    FIris1: TIrisData;
    FIris2: TIrisData;
    FIris3: TIrisData;
  public
    constructor Create;
    destructor Destroy; override;
    property Iris1: TIrisData read FIris1;
    property Iris2: TIrisData read FIris2;
    property Iris3: TIrisData read FIris3;
  end;

var
  SampleIrisData: TSampleIrisData;


implementation

{ TSampleIrisData }

constructor TSampleIrisData.Create;
begin
  FIris1 := TIrisData.Create;
  with FIris1 do
  begin
    SepalLength := 5.1;
    SepalWidth := 3.3;
    PetalLength := 1.6;
    PetalWidth := 0.2;
  end;

  FIris2 := TIrisData.Create;
  with FIris2 do
  begin
    SepalLength := 6.0;
    SepalWidth := 3.4;
    PetalLength := 6.1;
    PetalWidth := 2.0;
  end;

  FIris3 := TIrisData.Create;
  with FIris3 do
  begin
    SepalLength := 4.4;
    SepalWidth := 3.1;
    PetalLength := 2.5;
    PetalWidth := 1.2;
  end;
end;

destructor TSampleIrisData.Destroy;
begin
  FIris1.Free;
  FIris2.Free;
  FIris3.Free;
  inherited;
end;

initialization
  SampleIrisData := TSampleIrisData.Create;
finalization
  SampleIrisData.Free;

end.
