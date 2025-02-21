unit CreditCardFraudDetection_Models;

interface
uses MLCore, MLAttributes;

type

  TTransactionFraudPrediction = class(TMLEntity)
  public
    &Label: Single;

    /// <summary>
    /// The non-negative, unbounded score that was calculated by the anomaly detection model.
    /// Fraudulent transactions (Anomalies) will have higher scores than normal transactions
    /// </summary>
    Score: Single;
    
    /// <summary>
    /// The predicted label, based on the score. A value of true indicates an anomaly.
    /// </summary>
    PredictedLabel: Boolean;

    procedure PrintToConsole;
  end;

  TTransactionObservation = class(TMLEntity)
  public
    [LoadColumn(0)]
    Time: Single;

    [LoadColumn(1)]
    V1: Single;

    [LoadColumn(2)]
    V2: Single;

    [LoadColumn(3)]
    V3: Single;

    [LoadColumn(4)]
    V4: Single;

    [LoadColumn(5)]
    V5: Single;

    [LoadColumn(6)]
    V6: Single;

    [LoadColumn(7)]
    V7: Single;

    [LoadColumn(8)]
    V8: Single;

    [LoadColumn(9)]
    V9: Single;

    [LoadColumn(10)]
    V10: Single;

    [LoadColumn(11)]
    V11: Single;

    [LoadColumn(12)]
    V12: Single;

    [LoadColumn(13)]
    V13: Single;

    [LoadColumn(14)]
    V14: Single;

    [LoadColumn(15)]
    V15: Single;

    [LoadColumn(16)]
    V16: Single;

    [LoadColumn(17)]
    V17: Single;

    [LoadColumn(18)]
    V18: Single;

    [LoadColumn(19)]
    V19: Single;

    [LoadColumn(20)]
    V20: Single;

    [LoadColumn(21)]
    V21: Single;

    [LoadColumn(22)]
    V22: Single;

    [LoadColumn(23)]
    V23: Single;

    [LoadColumn(24)]
    V24: Single;

    [LoadColumn(25)]
    V25: Single;

    [LoadColumn(26)]
    V26: Single;

    [LoadColumn(27)]
    V27: Single;

    [LoadColumn(28)]
    V28: Single;

    [LoadColumn(29)]
    Amount: Single;

    [LoadColumn(30)]
    &Label: Single;

    procedure PrintToConsole;
  end;

implementation

uses CrystalNet.Console;

{ TTransactionFraudPrediction }

procedure TTransactionFraudPrediction.PrintToConsole;
begin
  // There is currently an issue where PredictedLabel is always set to true
  // Due to this issue, we'll manually choose the treshold that will indicate an anomaly
  // Issue: https://github.com/dotnet/machinelearning/issues/3990
  TConsole.NClass.WriteLine('Predicted Label: {0}  (Score: {1})', PredictedLabel, Score);
end;

{ TTransactionObservation }

procedure TTransactionObservation.PrintToConsole;
begin
  TConsole.NClass.WriteLine('Label: {0}', &Label);
  TConsole.NClass.WriteLine('Features: [V1] {0} [V2] {1} [V3] {2} ... [V28] {3} Amount: {4}', [V1, V2, V3, V28, Amount]);
end;

end.
