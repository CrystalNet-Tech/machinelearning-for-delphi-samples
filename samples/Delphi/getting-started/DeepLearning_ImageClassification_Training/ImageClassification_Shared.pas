unit ImageClassification_Shared;

interface

uses
  ImageClassification_Models,
  MLCatalogs;

type
  TImageRecord = record
    ImagePath: string;
    &Label: string;
  end;

  TFileUtils = class
  private

  public
   class function LoadImagesFromDirectory(folder: string; useFolderNameasLabel: Boolean): TArray<TImageRecord>; static;
   class function LoadInMemoryImagesFromDirectory(folder: string; useFolderNameasLabel: Boolean = true): TArray<TInMemoryImageData>; static;
   class function GetAbsolutePath(relativePath: string): string; static;
  end;

implementation

uses
  ConsoleHelper,
  CrystalNet.IO.FileSystem,
  CrystalNet.IO.FileSystem.Enums,
  CrystalNet.Runtime,
  SysUtils;

{ TFileUtils }

class function TFileUtils.GetAbsolutePath(relativePath: string): string;
begin
  Result := ConsoleHelper.GetAbsolutePath(relativePath);
end;

class function TFileUtils.LoadImagesFromDirectory(folder: string;
  useFolderNameasLabel: Boolean): TArray<TImageRecord>;
var
  m_imageRecord: TImageRecord;
begin
  var allImagesPath := TDirectory.NClass.GetFiles(folder, '*', TSearchOption.soAllDirectories);

  var imagesPath: TArray<string> := [];
  for var imagePath: string in allImagesPath do
  begin
    var extension: string := TPath.NClass.GetExtension(imagePath);
    if (extension = '.jpg') or (extension = '.png') then
    begin
      imagesPath := imagesPath + [imagePath];
    end;
  end;

  Result := [];
  if useFolderNameasLabel then
  begin
    for var imagePath: string in imagesPath do
    begin
      m_imageRecord.ImagePath := imagePath;
      m_imageRecord.&Label := TDirectory.NClass.GetParent(imagePath).Name;
      Result := Result + [m_imageRecord];
    end;
  end
  else
  begin
    for var imagePath: string in imagesPath do
    begin
      var _label := TPath.NClass.GetFileName(imagePath);
      for var index := 0 to Length(_label) - 1 do
      begin
        if (not TChar.NClass.IsLetter(_label[index])) then
        begin
          _label := _label.Substring(0, index);
          break;
        end;
      end;
      m_imageRecord.ImagePath := imagePath;
      m_imageRecord.&Label := _label;
      Result := Result + [m_imageRecord];
   end;
  end;
end;

class function TFileUtils.LoadInMemoryImagesFromDirectory(folder: string;
  useFolderNameasLabel: Boolean): TArray<TInMemoryImageData>;
begin
  Result := [];
  var images: TArray<TImageRecord> := TFileUtils.LoadImagesFromDirectory(folder, useFolderNameAsLabel);
  for var image in images do
  begin
    var imMemoryImageData := TInMemoryImageData.Create(TFile.NClass.ReadAllBytes(image.imagePath), image.&Label, image.ImagePath);
    Result := Result + [imMemoryImageData];
  end;
end;

end.
