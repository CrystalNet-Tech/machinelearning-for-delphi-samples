unit ICSharpCode.SharpZipLib;

interface
uses
	CNCoreClrLib.BridgeMgr, CrystalNet.Runtime.Intf, ICSharpCode.SharpZipLib.Consts, 
	CNCoreClrLib.Intf, CNCoreClrLib.AssemblyMgr, ICSharpCode.SharpZipLib.Intf;

type
	TInflaterInputStream = class(TCoreClrGenericImport<ICoreClrClass, IInflaterInputStream>);

	TDeflaterOutputStream = class(TCoreClrGenericImport<ICoreClrClass, IDeflaterOutputStream>);

	TTarArchive = class(TCoreClrGenericImport<ITarArchiveClass, ITarArchive>);

	TGZipInputStream = class(TCoreClrGenericImport<ICoreClrClass, IGZipInputStream>)
	public
		class function Create(baseInputStream: IStream): IGZipInputStream; overload;
		class function Create(baseInputStream: IStream; size: Integer): IGZipInputStream; overload;
	end;

	TGZipOutputStream = class(TCoreClrGenericImport<ICoreClrClass, IGZipOutputStream>)
	public
		class function Create(baseOutputStream: IStream): IGZipOutputStream; overload;
		class function Create(baseOutputStream: IStream; size: Integer): IGZipOutputStream; overload;
	end;

	TTarInputStream = class(TCoreClrGenericImport<ICoreClrClass, ITarInputStream>)
	public
		class function Create(inputStream: IStream): ITarInputStream; overload;
		class function Create(inputStream: IStream; blockFactor: Integer): ITarInputStream; overload;
	end;

	TTarOutputStream = class(TCoreClrGenericImport<ICoreClrClass, ITarOutputStream>)
	public
		class function Create(outputStream: IStream): ITarOutputStream; overload;
		class function Create(outputStream: IStream; blockFactor: Integer): ITarOutputStream; overload;
	end;

function GetAssembly: ICoreClrAssembly;

implementation

function GetAssembly: ICoreClrAssembly;
begin
	Result := TCoreClrAssembly.GetRegisterAssembly(sC_ICSharpCodeSharpZipLib_Asm_ID);
end;

{	TGZipInputStream	}

class function TGZipInputStream.Create(baseInputStream: IStream): IGZipInputStream;
begin
	Result := inherited Create([baseInputStream]);
end;

class function TGZipInputStream.Create(baseInputStream: IStream; size: Integer): IGZipInputStream;
begin
	Result := inherited Create([baseInputStream, size]);
end;

{	TGZipOutputStream	}

class function TGZipOutputStream.Create(baseOutputStream: IStream): IGZipOutputStream;
begin
	Result := inherited Create([baseOutputStream]);
end;

class function TGZipOutputStream.Create(baseOutputStream: IStream; size: Integer): IGZipOutputStream;
begin
	Result := inherited Create([baseOutputStream, size]);
end;

{	TTarInputStream	}

class function TTarInputStream.Create(inputStream: IStream): ITarInputStream;
begin
	Result := inherited Create([inputStream]);
end;

class function TTarInputStream.Create(inputStream: IStream; blockFactor: Integer): ITarInputStream;
begin
	Result := inherited Create([inputStream, blockFactor]);
end;

{	TTarOutputStream	}

class function TTarOutputStream.Create(outputStream: IStream): ITarOutputStream;
begin
	Result := inherited Create([outputStream]);
end;

class function TTarOutputStream.Create(outputStream: IStream; blockFactor: Integer): ITarOutputStream;
begin
	Result := inherited Create([outputStream, blockFactor]);
end;

//initialization
//	TCoreClrAssembly.RegisterDLLAssembly(sC_ICSharpCodeSharpZipLib_Asm_ID, sC_ICSharpCodeSharpZipLib_sC_AssemblyPath, False); // problem with resolver
end.

