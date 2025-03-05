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
var binFile: TBinaryFile;
begin

  binFile:=TBinaryFile.Create;
  binFile.Assign(filePath);
  try
    binFile.Reset;

  finally
    binFile.Close;
  end;
  binFile.Free;
  Writeln('TestFileIO completed.');
end;

begin
  TestNative(filePath);
  TestFileIO(filePath);
end.
