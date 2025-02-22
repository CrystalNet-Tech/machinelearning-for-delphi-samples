program ImageClassification;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ImageClassification_Common in 'ImageClassification_Common.pas',
  ImageClassification_Models in 'ImageClassification_Models.pas',
  ImageClassification_Predictor in 'ImageClassification_Predictor.pas',
  ImageClassification_Shared in 'ImageClassification_Shared.pas',
  ImageClassification_Trainer in 'ImageClassification_Trainer.pas',
  ImageClassificationConsoleApp in 'ImageClassificationConsoleApp.pas',
  ConsoleHelper in '..\Common\ConsoleHelper.pas',
  ICSharpCode.SharpZipLib.Consts in 'Lib\ICSharpCode.SharpZipLib.Consts.pas',
  ICSharpCode.SharpZipLib.Intf in 'Lib\ICSharpCode.SharpZipLib.Intf.pas',
  ICSharpCode.SharpZipLib in 'Lib\ICSharpCode.SharpZipLib.pas';

begin
  try
    TImageClassificationConsoleApp.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
