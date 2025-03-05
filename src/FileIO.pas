unit FileIO;

interface

{$i define.inc}
{$i Types.inc}

type TFilePath = string;
type TFilePosition = LongInt;

type IFile = interface
	procedure Assign(filePath: TFilePath);
	procedure Close;
	procedure Erase(); 
        function EOF():Boolean;
	procedure Free;
	procedure Reset(); // Open for reading
	procedure Rewrite(); // Open for writing
end;

type IBinaryFile = interface(IFile)
  	// https://www.freepascal.org/docs-html/rtl/system/blockread.html
	procedure BlockRead(var Buf; count: LongInt; var Result: LongInt );
	// https://www.freepascal.org/docs-html/rtl/system/filepos.html
	function FilePos( ):Int64;
        procedure Read(var Args: Char); 
	procedure Reset(l: LongInt); overload;
	procedure Seek2(Pos: Int64 );
end;

type ITextFile = interface(IFile)
	procedure Flush;
	// https://www.freepascal.org/docs-html/rtl/system/read.html
	procedure Read( var Args: Char);
	procedure ReadLn( var Args: String);

        function Write(s:string): ITextFile; overload;
        function Write(s:string; w: Integer): ITextFile; overload;
        function Write(i:Integer; w: Integer): ITextFile; overload;

	procedure WriteLn; overload;
        procedure WriteLn(s:string); overload;
        procedure WriteLn(s1:string; s2:string); overload;
        procedure WriteLn(s1:string; s2:string; s3: string); overload;
end;

type TFileSystem = class
  public
        class function CreateBinaryFile: IBinaryFile; static;
        class function CreateTextFile: ITextFile; static;
end;

implementation



type TFile = class(TInterfacedObject, IFile)
  protected filePath: TFilePath;
  public
        constructor Create;
	procedure Assign(filePath: TFilePath); Virtual; Abstract; 
	procedure Close; Virtual; Abstract; 
	procedure Erase(); Virtual; Abstract;
        function EOF():Boolean; Virtual; Abstract;
	procedure Reset(); Virtual; Abstract;  // Open for reading
	procedure Rewrite(); Virtual; Abstract;  // Open for writing
end;

type TTextFile = class(TFile, ITextFile)
{$IFNDEF PAS2JS}
  private
        type TSystemTextFile = System.TextFile;
  private
        f : TSystemTextFile;
{$ENDIF}
  public
        constructor Create;
  	procedure Assign(filePath: TFilePath); override; 
	procedure Close; override; 
	procedure Erase(); override; 
        function EOF():Boolean; override; 

	procedure Flush;
	// https://www.freepascal.org/docs-html/rtl/system/read.html
	procedure Read( var Args: Char);
	procedure ReadLn( var Args: String);
	procedure Reset(); override;
	procedure Rewrite(); override;

        function Write(s:string): ITextFile; overload;
        function Write(s:string; w: Integer): ITextFile; overload;
        function Write(i:Integer; w: Integer): ITextFile; overload;

	procedure WriteLn; overload;
        procedure WriteLn(s:string); overload;
        procedure WriteLn(s1:string; s2:string); overload;
        procedure WriteLn(s1:string; s2:string; s3: string); overload;
end;

type TBinaryFile = class(TFile, IBinaryFile)
{$IFNDEF PAS2JS}
  private
        type TSystemBinaryFile = file of char;
  private
        f : TSystemBinaryFile;
{$ENDIF}
  public
        constructor Create;
  	procedure Assign(filePath: TFilePath); override; 
  	// https://www.freepascal.org/docs-html/rtl/system/blockread.html
	procedure BlockRead(var Buf; count: LongInt; var Result: LongInt );
	procedure Close; override;
	procedure Erase(); override; 
        function EOF():Boolean; override;
	// https://www.freepascal.org/docs-html/rtl/system/filepos.html
	function FilePos( ):Int64;
        procedure Read(var Args: Char); 
	procedure Reset(); override; overload;
	procedure Reset(l: LongInt); overload;
	procedure Rewrite(); override;
	procedure Seek2(Pos: Int64 );
	
end;

{$IFDEF PAS2JS}
//  {$I 'include\pas2js\FileIO-PAS2JS-Implementation.inc'}
{$ENDIF}

//
// TFile
//
constructor TFile.Create;
begin
  filePath:='';
end;


//
// TTextFile
//
constructor TTextFile.Create;
begin
  Inherited;
end;
        
procedure TTextFile.Assign(filePath: TFilePath); 
begin
  Self.filePath:=filePath;
  System.WriteLn('TODO: Assignining TTextFile '+filePath);
{$IFNDEF PAS2JS}
  AssignFile(f, filePath);
{$ENDIF}
end;

procedure TTextFile.Close(); 
begin
  System.WriteLn('TODO: Closing TTextFile '+filePath);
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

function TTextFile.EOF():Boolean;
begin
{$IFNDEF PAS2JS}
  Result:=System.EOF(f);
{$ENDIF}

end;


procedure TTextFile.Flush(); 
begin
{$IFNDEF PAS2JS}
  System.Flush(f);
{$ENDIF}

end;

procedure TTextFile.Read(var Args: Char);
begin
{$IFNDEF PAS2JS}
  System.Read(f, Args);
{$ENDIF}

end;

procedure TTextFile.ReadLn(var Args: String);
begin
{$IFNDEF PAS2JS}
  System.ReadLn(f, Args);
{$ENDIF}

end;

procedure TTextFile.Reset();
begin
{$IFNDEF PAS2JS}
  System.Reset(f);
{$ENDIF}

end;

procedure TTextFile.Rewrite();
begin
{$IFNDEF PAS2JS}
  System.Rewrite(f);
{$ENDIF}

end;

function TTextFile.Write(s:string): ITextFile;
begin
{$IFNDEF PAS2JS}
  System.Write(f, s);
{$ENDIF}
end;

function TTextFile.Write(s:string; w: Integer): ITextFile;
begin
{$IFNDEF PAS2JS}
  System.Write(f, s);
{$ENDIF}
end;

function TTextFile.Write(i:Integer; w: Integer): ITextFile;
begin
{$IFNDEF PAS2JS}
 System.Write(f, i);
{$ENDIF}

end;

procedure TTextFile.WriteLn();
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, '');
{$ENDIF}

end;

procedure TTextFile.WriteLn(s:string); overload;
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, s);
{$ENDIF}

end;

procedure TTextFile.WriteLn( s1:string; s2:string); overload;
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, s1, s2);
{$ENDIF}

end;

procedure TTextFile.WriteLn(s1:string; s2:string; s3: string); overload;
begin
{$IFNDEF PAS2JS}
  System.WriteLn(f, s1, s2, s3);
{$ENDIF}

end;

//
// TBinaryFile
//
constructor TBinaryFile.Create;
begin
  Inherited;
end;

procedure TBinaryFile.Assign(filePath: TFilePath); 
begin
  Self.filePath:=filePath;
{$IFNDEF PAS2JS}

  // WriteLn('TODO: Assignining TBinaryFile '+filePath);
  AssignFile(f, filePath);
{$ENDIF}
end;

procedure TBinaryFile.BlockRead(var Buf; Count: LongInt; var Result: LongInt );
begin
{$IFNDEF PAS2JS}
  System.BlockRead( f, Buf, Count,  Result );
{$ENDIF}
end;

procedure TBinaryFile.Close(); 
begin
{$IFNDEF PAS2JS}

  // WriteLn('TODO: Closing TBinaryFile '+filePath);
  CloseFile(f);
{$ENDIF}

end;

function TBinaryFile.EOF():Boolean; 
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

function TBinaryFile.FilePos( ):Int64;
begin
{$IFNDEF PAS2JS}
  Result := System.FilePos(f);
{$ENDIF}
end;

procedure TBinaryFile.Read(var Args: Char);
begin
{$IFNDEF PAS2JS}

  System.Read(f, Args);
{$ENDIF}

end;


procedure TBinaryFile.Reset(); overload;
begin
{$IFNDEF PAS2JS}
  // WriteLn('TODO: Reset TBinaryFile '+filePath);
  System.Reset(f);
{$ENDIF}
end;

procedure TBinaryFile.Reset(l: LongInt); overload;
begin
{$IFNDEF PAS2JS}
  // WriteLn('TODO: Reset TBinaryFile '+filePath);
  System.Reset(f,l);
{$ENDIF}
 
end;

procedure TBinaryFile.Rewrite();
begin
{$IFNDEF PAS2JS}
  System.Rewrite(f);
{$ENDIF}
 
end;

procedure TBinaryFile.Seek2(Pos: Int64 );
begin
{$IFNDEF PAS2JS}
  System.Seek(f, pos);
{$ENDIF}
end;


class function TFileSystem.CreateBinaryFile: IBinaryFile;
begin
  Result:=TBinaryFile.Create;
end;

class function TFileSystem.CreateTextFile: ITextFile;
begin
  Result:=TTextFile.Create;
end;

        
end.
