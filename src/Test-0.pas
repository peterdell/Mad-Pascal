program test;

{$i define.inc}

uses Console, Common, FileIO
{$IFDEF PAS2JS}
     ,browserconsole
{$ENDIF} 
;

const filePath = 'Test-MP.pas';

procedure TestNative(filePath: TFilePath);
var 
  f: TextFile;
  s: string;
begin
  AssignFile(f, filePath);

  try
    reset(f); // Open the file for reading
    readln(f, s);
    writeln('Text read from file: ', s) 
   
  finally
    CloseFile(f);
  end;
  Writeln('TestFileIO completed.');
end;

procedure TestFileIO(filePath: TFilePath);
var binFile: IBinaryFile;
var c: Char;
begin

  binFile:=TFileSystem.CreateBinaryFile;
  binFile.Assign(filePath);
  try
    binFile.Reset;
    
    while not binFile.EOF do
    begin
      binFile.Read(c);
      Write(c);
      // WriteLn(IntToStr(Ord(c)));
    end;
//      binFile.Read(c);
    binFile.Close;
  except
    Writeln('ERROR: TestFileIO failed with Exception.');
  	
  end;
  binFile.Free;
  Writeln('TestFileIO completed.');
end;

begin
  TestNative(filePath);
  TestFileIO(filePath);
 
  // Unit Common
  SetLength(UnitPath,2);
  UnitPath[0]:='lib';
  // FindFile('TestUnit', 'unit');
end.
