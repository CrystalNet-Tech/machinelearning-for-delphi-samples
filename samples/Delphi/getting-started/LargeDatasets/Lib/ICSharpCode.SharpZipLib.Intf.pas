unit ICSharpCode.SharpZipLib.Intf;

{$WARN HIDING_MEMBER OFF}
{$WARN HIDDEN_VIRTUAL OFF}

interface
uses
	CNCoreClrLib.BridgeMgr, CrystalNet.Runtime.Intf, CNCoreClrLib.CallbackMgr, 
	CrystalNet.Runtime.Enums, ICSharpCode.SharpZipLib.Consts,
	CNCoreClrLib.RttiMgr;

type
{ Forward Declarations }

	ITarArchive = interface;

	[CoreTypeSignature(ICSHARPCODE_SHARPZIPLIB_ZIP_COMPRESSION_STREAMS_INFLATERINPUTSTREAM)]
	IInflaterInputStream = interface(ICoreClrInstance)
	['{431D7C05-26AF-4308-87E7-6A9BF21C4DDF}']
	end;

	[CoreTypeSignature(ICSHARPCODE_SHARPZIPLIB_ZIP_COMPRESSION_STREAMS_DEFLATEROUTPUTSTREAM)]
	IDeflaterOutputStream = interface(ICoreClrInstance)
	['{D9311C14-D3E2-44F7-AC22-D7D8C92977BC}']
	end;

{	Event Handlers	}

{$M+}
	TAsyncCallback = reference to procedure(ar: IIAsyncResult);
{$M-}

	[CoreTypeSignature(ICSHARPCODE_SHARPZIPLIB_GZIP_GZIPINPUTSTREAM)]
	IGZipInputStream = interface(IInflaterInputStream)
	['{B1C1E974-8142-43C2-B1D9-092BAD227645}']
	{ public }
		function BeginWrite(buffer: TArray<Byte>; offset: Integer; count: Integer; callback: TAsyncCallback; state: Variant): IIAsyncResult;
		procedure Close();
		procedure Flush();
		function Read(buffer: TArray<Byte>; offset: Integer; count: Integer): Integer;
		function Seek(offset: Int64; origin: TSeekOrigin): Int64;
		procedure SetLength(value: Int64);
		procedure Write(buffer: TArray<Byte>; offset: Integer; count: Integer);
		procedure WriteByte(value: Byte);
	end;

	[CoreTypeSignature(ICSHARPCODE_SHARPZIPLIB_GZIP_GZIPOUTPUTSTREAM)]
	IGZipOutputStream = interface(IDeflaterOutputStream)
	['{60766AF9-290A-44B3-A35B-126E58427550}']
	{ public }
		function BeginRead(buffer: TArray<Byte>; offset: Integer; count: Integer; callback: TAsyncCallback; state: Variant): IIAsyncResult;
		function BeginWrite(buffer: TArray<Byte>; offset: Integer; count: Integer; callback: TAsyncCallback; state: Variant): IIAsyncResult;
		procedure Close();
		procedure Finish();
		procedure Flush();
		function GetLevel(): Integer;
		function Read(buffer: TArray<Byte>; offset: Integer; count: Integer): Integer;
		function ReadByte(): Integer;
		function Seek(offset: Int64; origin: TSeekOrigin): Int64;
		procedure SetLength(value: Int64);
		procedure SetLevel(level: Integer);
		procedure Write(buffer: TArray<Byte>; offset: Integer; count: Integer);
		procedure WriteByte(value: Byte);
	end;

	ITarArchiveClass = interface(ICoreClrClass)
	['{79C1DD6C-0086-41CA-96E8-6AB82CA63F27}']
	{ public }
		{ class } function CreateInputTarArchive(inputStream: IStream): ITarArchive; overload;
		{ class } function CreateInputTarArchive(inputStream: IStream; blockFactor: Integer): ITarArchive; overload;
		{ class } function CreateOutputTarArchive(outputStream: IStream): ITarArchive; overload;
		{ class } function CreateOutputTarArchive(outputStream: IStream; blockFactor: Integer): ITarArchive; overload;
	end;

	[CoreTypeSignature(ICSHARPCODE_SHARPZIPLIB_TAR_TARARCHIVE)]
	ITarArchive = interface(IIDisposable)
	['{41366E47-9C93-45DB-A2FA-90426414FC0B}']
	{ private }
		function _GetProp_ApplyUserInfoOverrides: Boolean;
		procedure _SetProp_ApplyUserInfoOverrides(Value: Boolean);
		function _GetProp_AsciiTranslate: Boolean;
		procedure _SetProp_AsciiTranslate(Value: Boolean);
		function _GetProp_GroupId: Integer;
		function _GetProp_GroupName: string;
		function _GetProp_PathPrefix: string;
		procedure _SetProp_PathPrefix(Value: string);
		function _GetProp_RecordSize: Integer;
		function _GetProp_RootPath: string;
		procedure _SetProp_RootPath(Value: string);
		function _GetProp_UserId: Integer;
		function _GetProp_UserName: string;
	{ public }
		procedure Close();
		procedure CloseArchive();
		procedure ExtractContents(destinationDirectory: string);
		procedure ListContents();
		procedure SetAsciiTranslation(asciiTranslate: Boolean);
		procedure SetKeepOldFiles(keepOldFiles: Boolean);
		procedure SetUserInfo(userId: Integer; userName: string; groupId: Integer; groupName: string);
		property ApplyUserInfoOverrides: Boolean read _GetProp_ApplyUserInfoOverrides write _SetProp_ApplyUserInfoOverrides;
		property AsciiTranslate: Boolean read _GetProp_AsciiTranslate write _SetProp_AsciiTranslate;
		property GroupId: Integer read _GetProp_GroupId;
		property GroupName: string read _GetProp_GroupName;
		property PathPrefix: string read _GetProp_PathPrefix write _SetProp_PathPrefix;
		property RecordSize: Integer read _GetProp_RecordSize;
		property RootPath: string read _GetProp_RootPath write _SetProp_RootPath;
		property UserId: Integer read _GetProp_UserId;
		property UserName: string read _GetProp_UserName;
	end;

	[CoreTypeSignature(ICSHARPCODE_SHARPZIPLIB_TAR_TARINPUTSTREAM)]
	ITarInputStream = interface(IStream)
	['{C1091B56-F1C5-4CA2-BAFD-6CEA21A23FD1}']
	{ private }
		function _GetProp_Available: Int64;
		function _GetProp_CanRead: Boolean;
		function _GetProp_CanSeek: Boolean;
		function _GetProp_CanWrite: Boolean;
		function _GetProp_IsMarkSupported: Boolean;
		function _GetProp_Length: Int64;
		function _GetProp_Position: Int64;
		procedure _SetProp_Position(Value: Int64);
		function _GetProp_RecordSize: Integer;
	{ public }
		procedure Close();
		procedure CopyEntryContents(outputStream: IStream);
		procedure Flush();
		function GetRecordSize(): Integer;
		procedure Mark(markLimit: Integer);
		function Read(buffer: TArray<Byte>; offset: Integer; count: Integer): Integer;
		function ReadByte(): Integer;
		procedure Reset();
		function Seek(offset: Int64; origin: TSeekOrigin): Int64;
		procedure SetLength(value: Int64);
		procedure Skip(skipCount: Int64);
		procedure Write(buffer: TArray<Byte>; offset: Integer; count: Integer);
		procedure WriteByte(value: Byte);
		property Available: Int64 read _GetProp_Available;
		property CanRead: Boolean read _GetProp_CanRead;
		property CanSeek: Boolean read _GetProp_CanSeek;
		property CanWrite: Boolean read _GetProp_CanWrite;
		property IsMarkSupported: Boolean read _GetProp_IsMarkSupported;
		property Length: Int64 read _GetProp_Length;
		property Position: Int64 read _GetProp_Position write _SetProp_Position;
		property RecordSize: Integer read _GetProp_RecordSize;
	end;

	[CoreTypeSignature(ICSHARPCODE_SHARPZIPLIB_TAR_TAROUTPUTSTREAM)]
	ITarOutputStream = interface(IStream)
	['{2D622ECE-7879-41F2-AEDE-B2DB72F595A4}']
	{ private }
		function _GetProp_CanRead: Boolean;
		function _GetProp_CanSeek: Boolean;
		function _GetProp_CanWrite: Boolean;
		function _GetProp_Length: Int64;
		function _GetProp_Position: Int64;
		procedure _SetProp_Position(Value: Int64);
		function _GetProp_RecordSize: Integer;
	{ public }
		procedure Close();
		procedure CloseEntry();
		procedure Finish();
		procedure Flush();
		function GetRecordSize(): Integer;
		function Read(buffer: TArray<Byte>; offset: Integer; count: Integer): Integer;
		function ReadByte(): Integer;
		function Seek(offset: Int64; origin: TSeekOrigin): Int64;
		procedure SetLength(value: Int64);
		procedure Write(buffer: TArray<Byte>; offset: Integer; count: Integer);
		procedure WriteByte(value: Byte);
		property CanRead: Boolean read _GetProp_CanRead;
		property CanSeek: Boolean read _GetProp_CanSeek;
		property CanWrite: Boolean read _GetProp_CanWrite;
		property Length: Int64 read _GetProp_Length;
		property Position: Int64 read _GetProp_Position write _SetProp_Position;
		property RecordSize: Integer read _GetProp_RecordSize;
	end;

implementation

procedure RegisterTypes;
begin
	TRegGenericTypes.RegisterTypeNames('TAsyncCallback', SYSTEM_ASYNCCALLBACK, True);
	TRegGenericTypes.RegisterTypeNames('TProgressMessageHandler', ICSHARPCODE_SHARPZIPLIB_TAR_PROGRESSMESSAGEHANDLER, True);
end;

initialization
	RegisterTypes;

end.

