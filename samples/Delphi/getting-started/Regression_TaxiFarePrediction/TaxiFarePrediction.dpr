program TaxiFarePrediction;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  TaxiFarePrediction_Models in 'TaxiFarePrediction_Models.pas',
  TaxiFarePredictionConsoleApp in 'TaxiFarePredictionConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TTaxiFarePredictionConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
