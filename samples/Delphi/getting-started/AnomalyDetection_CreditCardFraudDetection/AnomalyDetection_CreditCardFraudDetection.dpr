program AnomalyDetection_CreditCardFraudDetection;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  CreditCardFraudDetection_Models in 'CreditCardFraudDetection_Models.pas',
  CreditCardFraudDetection_Predictor in 'CreditCardFraudDetection_Predictor.pas',
  CreditCardFraudDetection_Trainer in 'CreditCardFraudDetection_Trainer.pas',
  CreditCardFraudDetectionConsoleApp in 'CreditCardFraudDetectionConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TCreditCardFraudDetectionConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
