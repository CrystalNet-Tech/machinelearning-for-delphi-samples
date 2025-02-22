program Clustering_Iris;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ConsoleHelper in '..\Common\ConsoleHelper.pas',
  IrisClusteringConsoleApp in 'IrisClusteringConsoleApp.pas',
  IrisClustering_Models in 'IrisClustering_Models.pas';

begin
  try
    TIrisClassificationConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
