unit FileIO;
// Interfaced objects are implicitly reference counted and freed.
// Therefore there are no explicit Free method on the files.  

interface

{$i define.inc}
{$i Types.inc}


uses SysUtils;

type
  TFilePath = String;


  TPathList = class
  public
    constructor Create;
    procedure AddFolder(folderPath: TFilePath);
    function FindFile(filePath: TFilePath): TFilePath;
    function GetSize: Integer;
    function ToString: String; override;
  private
  var
    paths: array of TFilePath;
  end;


type
  TFilePosition = Longint;
// https://www.freepascal.org/docs-html/rtl/system/filemode.html
type
  IFile = interface
    procedure Assign(filePath: TFilePath);
    procedure Close;
    procedure Erase();
    function EOF(): Boolean;
    procedure Reset(); // Open for reading
    procedure Rewrite(); // Open for writing
  end;

type
  IBinaryFile = interface(IFile)
    // https://www.freepascal.org/docs-html/rtl/system/blockread.html
    procedure BlockRead(var Buf; Count: Longint; var Result: Longint);
    // https://www.freepascal.org/docs-html/rtl/system/filepos.html
    function FilePos(): Int64;
    procedure Read(var c: Char);
    procedure Reset(l: Longint); overload;
    procedure Seek2(Pos: Int64);
  end;

type
  ITextFile = interface(IFile)
    procedure Flush;
    // https://www.freepascal.org/docs-html/rtl/system/read.html
    procedure Read(var c: Char);
    procedure ReadLn(var s: String);

    function Write(s: String): ITextFile; overload;
    function Write(s: String; w: Integer): ITextFile; overload;
    function Write(i: Integer; w: Integer): ITextFile; overload;

    procedure WriteLn; overload;
    procedure WriteLn(s: String); overload;
    procedure WriteLn(s1: String; s2: String); overload;
    procedure WriteLn(s1: String; s2: String; s3: String); overload;
  end;

type
  TFileSystem = class
  public
  const
    PathDelim = DirectorySeparator;
    class function CreateBinaryFile: IBinaryFile; static;
    class function CreateTextFile: ITextFile; static;
    class function FileExists_(filePath: TFilePath): Boolean;
    class function NormalizePath(filePath: TFilePath): String;
  end;

implementation


type
  TFile = class(TInterfacedObject, IFile)
  protected
    filePath: TFilePath;
  public
    constructor Create;
    procedure Assign(filePath: TFilePath); virtual; abstract;
    procedure Close; virtual; abstract;
    procedure Erase(); virtual; abstract;
    function EOF(): Boolean; virtual; abstract;
    procedure Reset(); virtual; abstract;  // Open for reading
    procedure Rewrite(); virtual; abstract;  // Open for writing
  end;

type
  TTextFile = class(TFile, ITextFile)
{$IFNDEF PAS2JS}
  private
  type TSystemTextFile = System.TextFile;
  private
    f: TSystemTextFile;
{$ENDIF}
  public
    constructor Create;
    procedure Assign(filePath: TFilePath); override;
    procedure Close; override;
    procedure Erase(); override;
    function EOF(): Boolean; override;

    procedure Flush;
    // https://www.freepascal.org/docs-html/rtl/system/read.html
    procedure Read(var c: Char);
    procedure ReadLn(var s: String);
    procedure Reset(); override;
    procedure Rewrite(); override;

    function Write(s: String): ITextFile; overload;
    function Write(s: String; w: Integer): ITextFile; overload;
    function Write(i: Integer; w: Integer): ITextFile; overload;

    procedure WriteLn; overload;
    procedure WriteLn(s: String); overload;
    procedure WriteLn(s1: String; s2: String); overload;
    procedure WriteLn(s1: String; s2: String; s3: String); overload;
  end;

type
  TBinaryFile = class(TFile, IBinaryFile)
{$IFNDEF PAS2JS}
  private
  type TSystemBinaryFile = file of Char;
  private
    f: TSystemBinaryFile;
{$ENDIF}
  public
    constructor Create;
    procedure Assign(filePath: TFilePath); override;
    // https://www.freepascal.org/docs-html/rtl/system/blockread.html
    procedure BlockRead(var Buf; Count: Longint; var Result: Longint);
    procedure Close; override;
    procedure Erase(); override;
    function EOF(): Boolean; override;
    // https://www.freepascal.org/docs-html/rtl/system/filepos.html
    function FilePos(): Int64;
    procedure Read(var c: Char);
    procedure Reset(); override; overload;
    procedure Reset(l: Longint); overload;
    procedure Rewrite(); override;
    procedure Seek2(Pos: Int64);

  end;

{$IFDEF PAS2JS}
//  {$I 'include\pas2js\FileIO-PAS2JS-Implementation.inc'}
{$ENDIF}


constructor TPathList.Create;
begin
  paths := nil;
  SetLength(paths, 0);
end;

procedure TPathList.AddFolder(folderPath: TFilePath);
var
  size: Integer;
begin
  size := GetSize;
  Inc(size);
  SetLength(paths, size);
  paths[size - 1] := IncludeTrailingPathDelimiter(folderPath);
end;

function TPathList.FindFile(filePath: TFilePath): TFilePath;
var
  i: Integer;
begin
  Result := TFileSystem.NormalizePath(filePath);
  if TFileSystem.FileExists_(Result) then Exit;

  for i := Low(paths) to High(paths) do
  begin
    Result := paths[i] + filePath;
    if TFileSystem.FileExists_(Result) then Exit;
  end;
  Result := '';

end;

function TPathList.GetSize: Integer;
begin
  // If the argument is an array type or an array type variable then High returns
  // the highest possible value of it's index. For dynamic arrays, it returns the
  // ame as Length -1, meaning that it reports -1 for empty arrays.
  Result := High(paths) + 1;
end;

function TPathList.ToString: String;
var
  i: Integer;
begin
  Result := '';
  for i := Low(paths) to High(paths) do
  begin
    if Result = '' then Result := paths[i]
    else
      Result := Result + ';' + paths[i];
  end;
end;

// TFile

constructor TFile.Create;
begin
  filePath := '';
end;



// TTextFile

constructor TTextFile.Create;
begin
  inherited;
end;

procedure TTextFile.Assign(filePath: TFilePath);
begin
  Self.filePath := filePath;
{$IFNDEF PAS2JS}
  AssignFile(f, filePath);
{$ENDIF}
end;

procedure TTextFile.Close();
begin
{$IFNDEF PAS2JS}
  CloseFile(f);
{$ENDIF}

end;

procedure TTextFile.Erase();
begin
{$IFNDEF PAS2JS}
  System.Erase(f);
{$ENDIF}

end;

function TTextFile.EOF(): Boolean;
begin
{$IFNDEF PAS2JS}
  Result := System.EOF(f);
{$ENDIF}

end;


procedure TTextFile.Flush();
begin
{$IFNDEF PAS2JS}
  System.Flush(f);
{$ENDIF}

end;

procedure TTextFile.Read(var c: Char);
begin
{$IFNDEF PAS2JS}
  System.Read(f, c);
{$ENDIF}

end;

procedure TTextFile.ReadLn(var s: String);
begin
{$IFNDEF PAS2JS}
  System.ReadLn(f, s);
{$ENDIF}

end;

procedure TTextFile.Reset();
begin
{$IFNDEF PAS2JS}
  System.FileMode := 0;
  System.Reset(f);
{$ENDIF}

end;

procedure TTextFile.Rewrite();
begin
{$IFNDEF PAS2JS}
  System.FileMode := 1;
  System.Rewrite(f);
{$ENDIF}
end;

function TTextFile.Write(s: String): ITextFile;
begin
{$IFNDEF PAS2JS}
  System.Write(f, s);
{$ENDIF}
  Result := Self;
end;

function TTextFile.Write(s: String; w: Integer): ITextFile;
begin
{$IFNDEF PAS2JS}
  System.Write(f, s);
{$ENDIF}
  Result := Self;
end;

function TTextFile.Write(i: Integer; w: Integer): ITextFile;
begin
{$IFNDEF PAS2JS}
  System.Write(f, i);
{$ENDIF}
  Result := Self;
end;

procedure TTextFile.WriteLn();
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, '');
{$ENDIF}

end;

procedure TTextFile.WriteLn(s: String); overload;
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, s);
{$ENDIF}

end;

procedure TTextFile.WriteLn(s1: String; s2: String); overload;
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, s1, s2);
{$ENDIF}

end;

procedure TTextFile.WriteLn(s1: String; s2: String; s3: String); overload;
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, s1, s2, s3);
{$ENDIF}

end;


// TBinaryFile

constructor TBinaryFile.Create;
begin
  inherited;
end;

procedure TBinaryFile.Assign(filePath: TFilePath);
begin
  Self.filePath := filePath;
{$IFNDEF PAS2JS}
  AssignFile(f, filePath);
{$ENDIF}
end;

procedure TBinaryFile.BlockRead(var Buf; Count: Longint; var Result: Longint);
begin
{$IFNDEF PAS2JS}
  System.BlockRead(f, Buf, Count, Result);
{$ENDIF}
end;

procedure TBinaryFile.Close();
begin
{$IFNDEF PAS2JS}
  CloseFile(f);
{$ENDIF}

end;

function TBinaryFile.EOF(): Boolean;
begin
{$IFNDEF PAS2JS}
  Result := System.EOF(f);
{$ENDIF}
end;

procedure TBinaryFile.Erase();
begin
{$IFNDEF PAS2JS}
  System.Erase(f);
{$ENDIF}

end;

function TBinaryFile.FilePos(): Int64;
begin
{$IFNDEF PAS2JS}
  Result := System.FilePos(f);
{$ENDIF}
end;

procedure TBinaryFile.Read(var c: Char);
begin
{$IFNDEF PAS2JS}

  System.Read(f, c);
{$ENDIF}

end;


procedure TBinaryFile.Reset(); overload;
begin
{$IFNDEF PAS2JS}
  System.Reset(f);
{$ENDIF}
end;

procedure TBinaryFile.Reset(l: Longint); overload;
begin
{$IFNDEF PAS2JS}
  System.Reset(f, l);
{$ENDIF}

end;

procedure TBinaryFile.Rewrite();
begin
{$IFNDEF PAS2JS}
  System.Rewrite(f);
{$ENDIF}

end;

procedure TBinaryFile.Seek2(Pos: Int64);
begin
{$IFNDEF PAS2JS}
  System.Seek(f, pos);
{$ENDIF}
end;


class function TFileSystem.CreateBinaryFile: IBinaryFile;
begin
  Result := TBinaryFile.Create;
end;

class function TFileSystem.CreateTextFile: ITextFile;
begin
  Result := TTextFile.Create;
end;

class function TFileSystem.FileExists_(filePath: TFilePath): Boolean;
begin
  Result := False; // TODO FileExists(filePathUnicode);
end;

class function TFileSystem.NormalizePath(filePath: TFilePath): TFilePath;
begin

  Result := filePath;

  {$IFDEF UNIX}
   if Pos('\', filePath) > 0 then
    Result := LowerCase(StringReplace(filePath, '\', '/', [rfReplaceAll]));
  {$ENDIF}

  {$IFDEF LINUX}
    Result := LowerCase(filePath);
  {$ENDIF}

end;

end.
