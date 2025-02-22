unit PowerAnomalyDetection_Models;

interface

uses MLAttributes, MLCore;

type
  TMeterData = class(TMLEntity)
  public
    [LoadColumn(0)]
    name: string;
    [LoadColumn(1)]
    time: TDateTime;
    [LoadColumn(2)]
    ConsumptionDiffNormalized : Single;
  end;

  TSpikePrediction = class(TMLEntity)
  public
    [VectorType(3)]
    Prediction: TArray<Double>;
  end;


implementation


end.
