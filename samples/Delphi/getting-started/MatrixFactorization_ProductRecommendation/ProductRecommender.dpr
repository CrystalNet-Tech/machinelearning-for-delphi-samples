program ProductRecommender;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ProductRecommender_Models in 'ProductRecommender_Models.pas',
  ProductRecommenderConsoleApp in 'ProductRecommenderConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TProductRecommenderConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
