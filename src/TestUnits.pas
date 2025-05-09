program TestUnits;

{$I Defines.inc}

uses
  Crt,
  Common,
  CommonTypes,
  Console,
  Diagnostic,
  FileIO,
  MathEvaluate,
  Messages,
  Parser,
  Scanner,
  Optimize,
  Types,
  Tokens,
  Utilities,
  SysUtils;

  procedure AssertEquals(actual, expected: String; message: String);
  begin
    Assert(actual = expected, 'The actual string ''' + actual + ''' is not equal to the expected string ''' +
      expected + '''.');
  end;

  procedure StartTest(Name: String);
  begin
    WriteLn('Unit Test ' + Name + ' started.');
  end;

  procedure FailTest(msg: String);
  begin
    WriteLn('ERROR: ' + msg);
  end;


  procedure EndTest(Name: String);
  begin
    WriteLn('Unit Test ' + Name + ' ended.');
  end;


  procedure TestNative(filePath: TFilePath);
  var
    f: TextFile;
    s: String;
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
  var
    binFile: IBinaryFile;
  var
    c: Char;
  begin
    StartTest('TestFileIO');

    binFile := TFileSystem.CreateBinaryFile;
    binFile.Assign(filePath);
    try
      binFile.Reset;

      while not binFile.EOF do
      begin
        c := ' ';
        binFile.Read(c);
        Write(c);
        // WriteLn(IntToStr(Ord(c)));
      end;
      //      binFile.Read(c);
      binFile.Close;
    except
      FailTest('Failed with Exception.');

    end;
    EndTest('TestFileIO');
  end;

  procedure TestUnitFile;
  const
    TEST_MP_FILE_PATH = '..\src\tests\Test-MP.pas';
  var
    pathList: TPathList;

  begin
    StartTest('TestUnitFile');
    TestNative(TEST_MP_FILE_PATH);
    TestFileIO(TEST_MP_FILE_PATH);

    pathList := TPathList.Create;
    pathList.AddFolder('Folder1');
    pathList.AddFolder('Folder2');
    pathList.AddFolder('Folder2' + TFileSystem.PathDelim);
    Assert(pathList.GetSize() = 2);
    Assert(pathList.ToString() = 'Folder1' + TFileSystem.PathDelim + ';Folder2' + TFileSystem.PathDelim);
    pathList.Free;

    EndTest('TestUnitFile');
  end;

  procedure TestUnitCommon;
  var
    filePath: TFilePath;
  begin

    StartTest('TestUnitCommon');

    // Test Enums
    Assert(Ord(TParameterPassingMethod.UNDEFINED) = 0);
    Assert(Ord(TParameterPassingMethod.VALPASSING) = 1);
    Assert(Ord(TParameterPassingMethod.CONSTPASSING) = 2);
    Assert(Ord(TParameterPassingMethod.VARPASSING) = 3);


    // Unit Scanner
    Program_NAME := 'TestProgram';
    NumTok := 0;
    // Kind, UnitIndex, Line, Column, Value
    AddToken(TTokenKind.PROGRAMTOK, 1, 1, 1, 0);

    // Unit Common
    unitPathList := TPathList.Create;
    unitPathList.AddFolder('libnone');
    filePath := '';
    try
      filePath := FindFile('TestUnit', 'unit');
    except
      on  ex: THaltException do
      begin
        Assert(ex.GetExitCode = THaltException.COMPILING_ABORTED);
      end;
    end;
    Assert(filePath = '', 'Non-existing TestUnit found');

    EndTest('TestUnitCommon');
  end;


type
  TTestEvaluationContext = class(TInterfacedObject, IEvaluationContext)
  public
    constructor Create;
    function GetConstantName(const expression: String; var index: Integer): String;
    function GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  end;

  constructor TTestEvaluationContext.Create;
  begin
  end;

  function TTestEvaluationContext.GetConstantName(const expression: String; var index: Integer): String;
  begin
    Result := 'EXAMPLE';
  end;

  function TTestEvaluationContext.GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  begin
    if constantName = 'EXAMPLE' then
    begin
      constantValue := 1;
      Result := True;
    end
    else
    begin
      constantValue := 0;
      Result := False;
    end;
  end;

  // ----------------------------------------------------------------------------
  // Unit MathEvaluate
  // ----------------------------------------------------------------------------
  procedure TestUnitMathEvaluate;

    procedure AssertValue(const expression: String; expectedValue: TEvaluationResult);
    var
      evaluationContext: IEvaluationContext;
      actualValue: TEvaluationResult;
    begin
      evaluationContext := TTestEvaluationContext.Create;
      actualValue := MathEvaluate.Evaluate(expression, evaluationContext);
      Assert(actualValue = expectedValue,
        'Expression ''' + expression + ''' was evaluated to value ' + FloatToStr(actualValue) +
        ' instead of ' + FloatToStr(expectedValue) + '.');
    end;

    procedure AssertException(const expression: String; expectedIndex: Integer; expectedMessage: String);
    var
      evaluationContext: IEvaluationContext;
    begin
      evaluationContext := TTestEvaluationContext.Create;
      try
        MathEvaluate.Evaluate(expression, evaluationContext);
        Assert(False, 'Expected exception ''' + expectedMessage + ''' for expression ''' +
          expression + ''' not raised.');
      except
        on ex: EEvaluationException do
        begin
          Assert(ex.Message = expectedMessage, 'Expected exception ''' + expectedMessage +
            ''' for expression ''' + expression + ''' raised with different text ''' + ex.Message + '''.');
          Assert(ex.Index = expectedIndex, 'Expected exception ''' + expectedMessage +
            ''' for expression ''' + expression + ''' raised with different index ' +
            IntToStr(ex.Index) + ' instead of ' + IntToStr(expectedIndex) + '.');

        end;
      end;

    end;

  begin

    StartTest('TestUnitMathEvaluate');

    AssertValue('', 0);
    AssertValue('(1+2)*3+1+100/10', 20);
    AssertValue('$1234+$2345', $1234 + $2345);
    AssertValue('%111011010', $1da);   // There is no binary in Delphi

    AssertException('(', 2, 'Parenthesis Mismatch');
    EndTest('TestUnitMathEvaluate');
  end;

  // ----------------------------------------------------------------------------
  // Unit Messages
  // ----------------------------------------------------------------------------
  procedure TestUnitMessages;
  var
    message: TMessage;
  begin

    StartTest('TestUnitMessages');
    message := TMessage.Create(TErrorCode.IllegalExpression,
      'A={0} B={1} C={2} D={3} E={4} F={5} G={6} H={7} I={8} J={9}', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J');
    AssertEquals(message.GetText(), 'A=A B=B C=C D=D E=E F=F G=G H=H I=I J=J', 'Formatted message not equal.');
    EndTest('TestUnitMessages');
  end;

begin
  try
    TestUnitFile;
    TestUnitCommon;
    TestUnitMathEvaluate;
    TestUnitMessages;
  except
    on e: Exception do
    begin
      ShowException(e, ExceptAddr);
    end;
  end;

  Writeln('Main completed. Press any key.');
  repeat
  until keypressed;
end.
