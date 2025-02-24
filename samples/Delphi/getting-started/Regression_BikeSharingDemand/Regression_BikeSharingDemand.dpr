program Regression_BikeSharingDemand;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  BikeSharingDemand_Models in 'BikeSharingDemand_Models.pas',
  BikeSharingDemand_ModelScoringTester in 'BikeSharingDemand_ModelScoringTester.pas',
  BikeSharingDemandConsoleApp in 'BikeSharingDemandConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TBikeSharingDemandConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
