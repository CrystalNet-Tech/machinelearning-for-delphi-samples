unit ImageClassification_Common;

interface

uses CrystalNet.Runtime.Intf;

type
  TCompress = class
  public
    /// <summary>
    /// Copy the contents of one <see cref="Stream"/> to another.
    /// </summary>
    /// <param name="source">The stream to source data from.</param>
    /// <param name="destination">The stream to write data to.</param>
    /// <param name="buffer">The buffer to use during copying.</param>
    class procedure Copy(Source, Destination: IStream; Buffer: TArray<Byte>); static;

    class procedure ExtractGZip(gzipFileName: string; targetDir: string); static;
    class procedure UnZip(gzArchiveName: string; destFolder: string); static;
    class procedure ExtractTGZ(gzArchiveName: string; destFolder: string); static;
  end;

  TWeb = class
  public
    class function Download(url, destDir, destFileName: string): Boolean; static;
  end;

implementation

uses ICSharpCode.SharpZipLib, ICSharpCode.SharpZipLib.Intf, CrystalNet.Runtime,
      CrystalNet.Runtime.Enums, CrystalNet.IO.FileSystem, SysUtils, CrystalNet.Console,
      System.Threading, CrystalNet.IO.Compression.ZipFile, MLCore, CrystalNet.Net.WebClient;

{ TCompress }

class procedure TCompress.ExtractGZip(gzipFileName, targetDir: string);
var
  fs: IFileStream;
  fsOut: IFileStream;
  gzipStream: IGZipInputStream;
  fnOut: string;
  dataBuffer: TArray<byte>;
begin
  // Use a 4K buffer. Any larger is a waste.
  SetLength(dataBuffer, 4096);

  fs := TFileStream.Create(gzipFileName, TFileMode.fmOpen, [TFileAccess.faRead]);
  try
    gzipStream := TGZipInputStream.Create(fs);
    try
      // Change this to your needs
      fnOut := TPath.NClass.Combine(targetDir, TPath.NClass.GetFileNameWithoutExtension(gzipFileName));

      fsOut := TFile.NClass.Create(fnOut);
      try
        TCompress.Copy(TStream.Wrap(gzipStream), fsOut, dataBuffer);
        fsOut.Close;
      finally
        fsOut.Dispose;
      end;
    finally
      gzipStream.Close;
    end;

    fs.Close;
  finally
    fs.Dispose;
  end;
end;

class procedure TCompress.ExtractTGZ(gzArchiveName, destFolder: string);
begin
  var archiveNames := gzArchiveName.Split(TPath.NClass.DirectorySeparatorChar);
  var archiveLastNames := archiveNames[Length(archiveNames)-1].Split(['.']);
  var flag := archiveLastNames[0] + '.bin';
  if TFile.NClass.Exists(TPath.NClass.Combine(destFolder, flag)) then
    Exit;

  TConsole.NClass.WriteLine('Extracting.');

  var task := TTask.Run(
    procedure
    begin
      var inStream := TFile.NClass.OpenRead(gzArchiveName);
      try
        var gzipStream := TGZipInputStream.Create(inStream);
        try
          var tarArchive := TTarArchive.NClass.CreateInputTarArchive(TStream.Wrap(gzipStream));
          try
            tarArchive.ExtractContents(destFolder);
            tarArchive.Close;
          finally
            tarArchive.Dispose;
          end;
        finally
          gzipStream.Close
        end;
        inStream.Close;
      finally
        inStream.Dispose;
      end;
    end);

  while task.Status <> TTaskStatus.Completed do
  begin
    Sleep(200);
    TConsole.NClass.Write('.');
  end;

  TFile.NClass.Create(TPath.NClass.Combine(destFolder, flag));
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('Extracting is completed.');
end;

class procedure TCompress.UnZip(gzArchiveName, destFolder: string);
begin
  var archiveNames := gzArchiveName.Split(TPath.NClass.DirectorySeparatorChar);
  var archiveLastNames := archiveNames[Length(archiveNames)-1].Split(['.']);
  var flag := archiveLastNames[0] + '.bin';

  if TFile.NClass.Exists(TPath.NClass.Combine(destFolder, flag)) then
    Exit;

  TConsole.NClass.WriteLine('Extracting.');
  var task := TTask.Run(
    procedure
    begin
       TZipFile.NClass.ExtractToDirectory(gzArchiveName, destFolder);
    end);

  while task.Status <> TTaskStatus.Completed do
  begin
    Sleep(200);
    TConsole.NClass.Write('.');
  end;

  TFile.NClass.Create(TPath.NClass.Combine(destFolder, flag));
  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('Extracting is completed.');
end;

class procedure TCompress.Copy(Source: IStream; Destination: IStream; Buffer: TArray<Byte>);
begin
  if Source = nil then
    Guard.RaiseArgumentNullException('Source');

  if Destination = nil then
    Guard.RaiseArgumentNullException('Destination');

  if Buffer = nil then
    Guard.RaiseArgumentNullException('Buffer');

  // Ensure a reasonable size of buffer is used without being prohibitive.
  if Length(buffer) < 128 then
    Guard.RaiseArgumentException('Buffer is too small', 'Buffer');

  var copying: Boolean := True;

  while (copying) do
  begin
    var bytesRead: Integer := source.Read(buffer, 0, Length(buffer));
    if (bytesRead > 0) then
    begin
      destination.Write(buffer, 0, bytesRead);
    end
    else
    begin
      destination.Flush();
      copying := false;
    end;
  end;
end;

{ TWeb }

class function TWeb.Download(url, destDir, destFileName: string): Boolean;
begin
  if (destFileName = '') then
  begin
    var urls := url.Split(TPath.NClass.DirectorySeparatorChar);
    destFileName := urls[High(urls)];
  end;

  TDirectory.NClass.CreateDirectory(destDir);

  var relativeFilePath: string := TPath.NClass.Combine(destDir, destFileName);

  if (TFile.NClass.Exists(relativeFilePath)) then
  begin
    TConsole.NClass.WriteLine(relativeFilePath + ' already exists.');
    Exit(False);
  end;

  var wc := TWebClient.Create();
  TConsole.NClass.WriteLine('Downloading '+ relativeFilePath);

  var download := TTask.Run(
    procedure
    begin
      wc.DownloadFile(url, relativeFilePath);
    end);

  while download.Status <> TTaskStatus.Completed do
  begin
    Sleep(200);
    TConsole.NClass.Write('.');
  end;

  TConsole.NClass.WriteLine('');
  TConsole.NClass.WriteLine('Downloaded '+ relativeFilePath);

  Result := True;
end;

end.
