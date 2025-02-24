program SentimentAnalysis;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SentimentAnalysis_Models in 'SentimentAnalysis_Models.pas',
  SentimentAnalysisConsoleApp in 'SentimentAnalysisConsoleApp.pas',
  ConsoleHelper in '..\..\Common\ConsoleHelper.pas';

begin
  try
    TSentimentAnalysisConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
