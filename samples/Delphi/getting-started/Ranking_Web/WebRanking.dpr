program WebRanking;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  WebRanking_Models in 'WebRanking_Models.pas',
  WebRankingConsoleApp in 'WebRankingConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TWebRankingConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
