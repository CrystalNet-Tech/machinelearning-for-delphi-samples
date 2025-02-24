unit SrEntireDetection_Models;

interface

uses MLAttributes, MLCore;

type
  TPhoneCallsData = class(TMLEntity)
  public
    [LoadColumn(0)]
    timestamp: string;

    [LoadColumn(1)]
    value: Double;
  end;

  TPhoneCallsPrediction = class(TMLEntity)
  public
    //vector to hold anomaly detection results. Including isAnomaly, anomalyScore, magnitude, expectedValue, boundaryUnits, upperBoundary and lowerBoundary.
    [VectorType(7)]
    Prediction: TArray<Double>;
  end;

implementation

end.
