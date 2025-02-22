unit ConsoleHelperExt;

interface
uses CrystalNet.Console, CrystalNet.Console.Enums, MLCollections;


procedure ConsoleWriteHeader(lines: TArray<string>);
procedure ConsolePressAnyKey;
procedure ConsoleWriteException(lines: TArray<string>);

implementation

uses ConsoleHelper, Math, CrystalNet.Runtime;

procedure ConsoleWriteHeader(lines: TArray<string>);
var
  line: string;
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccYellow;
  TConsole.NClass.WriteLine(' ');
  for line in lines do
  begin
    TConsole.NClass.WriteLine(line);
  end;

 var lineEnumerables := MLArray<string>(lines);
 var maxLength := lineEnumerables.Select<Integer>(function(Value: string): Integer
                                                  begin
                                                    Result := Length(Value);
                                                  end).Max();

  TConsole.NClass.WriteLine(TString.Create('#', maxLength));
  TConsole.NClass.ForegroundColor := defaultColor;
end;

procedure ConsolePressAnyKey;
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccGreen;
  TConsole.NClass.WriteLine(' ');
  TConsole.NClass.WriteLine('Press any key to finish.');
  TConsole.NClass.ReadKey();
end;

procedure ConsoleWriteException(lines: TArray<string>);
const
  exceptionTitle = 'EXCEPTION';
var
  line: string;
begin
  var defaultColor := TConsole.NClass.ForegroundColor;
  TConsole.NClass.ForegroundColor := TConsoleColor.ccRed;
  TConsole.NClass.WriteLine(' ');
  TConsole.NClass.WriteLine(exceptionTitle);
  TConsole.NClass.WriteLine(TString.Create('#', Length(exceptionTitle)));
  TConsole.NClass.ForegroundColor := defaultColor;
  for line in lines do
  begin
    TConsole.NClass.WriteLine(line);
  end;
end;

end.
