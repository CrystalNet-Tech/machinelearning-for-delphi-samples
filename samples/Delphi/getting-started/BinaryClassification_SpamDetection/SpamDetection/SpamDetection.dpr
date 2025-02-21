program SpamDetection;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SpamDetection_Models in 'SpamDetection_Models.pas',
  SpamDetectionConsoleApp in 'SpamDetectionConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TSpamDetectionConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
