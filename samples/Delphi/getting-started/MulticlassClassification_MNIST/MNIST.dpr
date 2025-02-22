program MNIST;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MNIST_Models in 'MNIST_Models.pas',
  MNISTConsoleApp in 'MNISTConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas';

begin
  try
    TMNISTConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
