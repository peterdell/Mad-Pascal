type TTextFile =  record
               		filePath: TFilePath;
               		textFlag: boolean;
               	   end;
               	   
type TBinaryFile = record
               		filePath: TFilePath;
               	   end;

// https://www.freepascal.org/docs-html/rtl/system/filemode.html
var FileMode: Byte = 2;

// https://www.freepascal.org/docs-html/rtl/sysutils/fileexists.html
function FileExists( const FileName: TFilePath; FollowLink: Boolean = True ):Boolean;

// https://wiki.freepascal.org/File_Handling_In_Pascal
procedure AssignFile(f: TBinaryFile; fName: TFilePath); overload;
procedure AssignFile(f: TTextFile; fName: TFilePath); overload;
procedure Flush(f: TTextFile);
procedure CloseFile(f: TBinaryFile); overload;
procedure CloseFile(f: TTextFile); overload;

// https://www.freepascal.org/docs-html/rtl/system/blockread.html
procedure BlockRead(var f: TBinaryFile; var Buf; count: LongInt; var Result: LongInt );
procedure WriteLn(s:string); overload;

procedure WriteLn(f: TTextFile); overload;
procedure WriteLn(f: TTextFile; s:string); overload;
procedure WriteLn(f: TTextFile; s1:string; s2:string); overload;
procedure WriteLn(f: TTextFile; s1:string; s2:string; s3: string); overload;

// https://www.freepascal.org/docs-html/rtl/system/reset.html
procedure Reset(f: TTextFile); overload;
procedure Reset(f: TBinaryFile); overload;
procedure Reset(var f: TBinaryFile; l: LongInt); overload;

// https://www.freepascal.org/docs-html/rtl/system/filepos.html
function FilePos( var f: TBinaryFile ):Int64;

// https://www.freepascal.org/docs-html/rtl/system/seek.html
procedure Seek(var f: TBinaryFile; Pos: Int64 );

// https://www.freepascal.org/docs-html/rtl/system/rewrite.html
procedure Rewrite(f: TTextFile); overload;
procedure Rewrite(f: TBinaryFile); overload;

// https://www.freepascal.org/docs-html/rtl/system/erase.html
procedure Erase(var f: TTextFile); overload;
procedure Erase(var f: TBinaryFile); overload;

// https://www.freepascal.org/docs-html/rtl/system/eof.html
function EOF(f: TTextFile):Boolean; overload;
function EOF(f: TBinaryFile):Boolean; overload;

// https://www.freepascal.org/docs-html/rtl/system/read.html
procedure Read( var F: TTextFile; Args: Char); overload;
procedure Read( var F: TBinaryFile; Args: Char); overload;

// https://www.freepascal.org/docs-html/rtl/system/readln.html
procedure ReadLn( var F: TTextFile; Args: String);
