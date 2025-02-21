unit CreditCardFraudDetectionConsoleApp;

interface
type
  TCreditCardFraudDetectionConsoleApp = class
  private
  public
    class procedure Run;
  end;

implementation
uses CreditCardFraudDetection_Predictor, CreditCardFraudDetection_Trainer;

{ TCreditCardFraudDetectionConsoleApp }

class procedure TCreditCardFraudDetectionConsoleApp.Run;
begin
  TTrainer.Execute;
  TPredictor.Execute;
end;

end.
