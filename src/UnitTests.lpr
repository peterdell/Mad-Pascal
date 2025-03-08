program test;

{$i define.inc}

uses Console, Common, FileIO
{$IFDEF PAS2JS}
     ,browserconsole
{$ENDIF}
;

procedure StartTest(name: string);
begin
  WriteLn('Unit Test '+name+' started.');
end;

procedure EndTest(name: string);
begin
  WriteLn('Unit Test '+name+' ended.');
end;


procedure TestNative(filePath: TFilePath);
var
  f: TextFile;
  s: string;
begin
  StartTest('TestFileNative');

  AssignFile(f, filePath);

  try
    reset(f); // Open the file for reading
    readln(f, s);
    writeln('Text read from file: ', s)

  finally
    CloseFile(f);
  end;
  EndTest('TestFileNative');
end;

procedure TestFileIO(filePath: TFilePath);
var binFile: IBinaryFile;
var c: Char;
begin
  StartTest('TestFileIO');

  binFile:=TFileSystem.CreateBinaryFile;
  binFile.Assign(filePath);
  try
    binFile.Reset;

    while not binFile.EOF do
    begin
      c:=' ';
      binFile.Read(c);
      Write(c);
      // WriteLn(IntToStr(Ord(c)));
    end;
//      binFile.Read(c);
    binFile.Close;
  except
    Writeln('ERROR: TestFileIO failed with Exception.');

  end;
  EndTest('TestFileIO');
end;

procedure TestUnitFile;
const TEST_MP_FILE_PATH = 'Test-MP.pas';
begin
  StartTest('TestUnitFile');
  TestNative(TEST_MP_FILE_PATH);
  TestFileIO(TEST_MP_FILE_PATH);
  EndTest('TestUnitFile');
end;

procedure TestUnitCommon;
begin;
  StartTest('TestUnitCommon');

  // Unit Common
  UnitPath:=nil;
  SetLength(UnitPath,1);
  UnitPath[0]:='lib';
  FindFile('TestUnit', 'unit');
  EndTest('TestUnitCommon');
end;


begin
  TestUnitFile;
  TestUnitCommon;

  Writeln('Main completed.');
end.

