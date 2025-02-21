program HeartDiseaseDetection;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  HeartDiseaseDetection_Models in 'HeartDiseaseDetection_Models.pas',
  HeartDiseaseDetectionConsoleApp in 'HeartDiseaseDetectionConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    THeartDiseaseDetectionConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
