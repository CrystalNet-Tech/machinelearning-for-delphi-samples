unit ImageClassificationConsoleApp;

// https://github.com/dotnet/machinelearning-samples/tree/main/samples/csharp/getting-started/DeepLearning_ImageClassification_Training

interface
type
  TImageClassificationConsoleApp = class
  private
  public
    class procedure Run;
  end;

implementation

uses ImageClassification_Predictor, ImageClassification_Trainer, SysUtils, MLAssembly,CNCoreClrLib.AssemblyMgr, CrystalNet.Collections.Immutable,
CrystalNet.Runtime;

{ TImageClassificationConsoleApp }

class procedure TImageClassificationConsoleApp.Run;
begin
{$IFDEF MSWINDOWS}
  {$IFDEF WIN32}
    raise Exception.Create('This Image Classification Deep Learning Example works on 64bit platform');
  {$ENDIF}
{$ENDIF}

  TTrainer.Execute;
  TPredictor.Execute;
end;
end.
