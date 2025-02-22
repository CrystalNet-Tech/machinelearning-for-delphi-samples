program MovieRecommendation;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MovieRecommendation_Models in 'MovieRecommendation_Models.pas',
  MovieRecommendationConsoleApp in 'MovieRecommendationConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TMovieRecommendationConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
