Unit Diagnostic;

interface

{$i define.inc}

// ----------------------------------------------------------------------------

	procedure Diagnostics;

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Common, FileIO;

// ----------------------------------------------------------------------------


procedure Diagnostics;
var i, CharIndex, ChildIndex: Integer;
    DiagFile: TTextFile2;
begin

  DiagFile:=TTextFile2.Create;
  DiagFile.Assign2(ChangeFileExt( UnitName[1].Name, '.txt') );
  DiagFile.Rewrite2;

  DiagFile.WriteLn2;
  DiagFile.WriteLn2('Token list: ');
  DiagFile.WriteLn2;
  // DiagFile.WriteLn2('#' : 6, 'Unit': 30, 'Line': 6, 'Token': 30);
  DiagFile.Write2('# ',6).Write2( 'Unit',30).Write2( 'Line',6).Write2('Token',30).WriteLn2;

  DiagFile.WriteLn2;

  for i := 1 to NumTok do
    begin
    // DiagFile.Write(i: 6, UnitName[Tok[i].UnitIndex].Name: 30, Tok[i].Line: 6, GetSpelling(i): 30);
    DiagFile.Write2(i,6).Write2( UnitName[Tok[i].UnitIndex].Name, 30).Write2(Tok[i].Line, 6).Write2(GetSpelling(i), 30).WriteLn2;
    if Tok[i].Kind = INTNUMBERTOK then
      DiagFile.WriteLn2(' = ', IntToStr(Tok[i].Value))
    else if Tok[i].Kind = FRACNUMBERTOK then
//    DiagFile.WriteLn2(' = ', Tok[i].FracValue: 8: 4)
      DiagFile.WriteLn2(' = ', FloatToStr(Tok[i].FracValue))
    else if Tok[i].Kind = IDENTTOK then
      DiagFile.WriteLn2(' = ', Tok[i].Name)
    else if Tok[i].Kind = CHARLITERALTOK then
      DiagFile.WriteLn2(' = ', Chr(Tok[i].Value))
    else if Tok[i].Kind = STRINGLITERALTOK then
      begin
      DiagFile.Write2(' = ');
      for CharIndex := 1 to Tok[i].StrLength do
	DiagFile.Write2( StaticStringData[Tok[i].StrAddress - CODEORIGIN + (CharIndex - 1)],-1);
      DiagFile.WriteLn2;
      end
    else
      DiagFile.WriteLn2;
    end;// for

  DiagFile.WriteLn2;
  DiagFile.WriteLn2( 'Identifier list: ');
  DiagFile.WriteLn2;
  DiagFile.Write2( '#',6).Write2('Block',6).Write2( 'Name',30).Write2('Kind',15).Write2( 'Type', 15).Write2( 'Items/Params', 15).Write2( 'Value/Addr', 15).Write2( 'Dead',5).WriteLn2;
  DiagFile.WriteLn2;

  for i := 1 to NumIdent do
    begin
    DiagFile.Write2( i, 6).Write2( Ident[i].Block, 6).Write2( Ident[i].Name, 30).Write2( Spelling[Ident[i].Kind], 15);
    if Ident[i].DataType <> 0 then DiagFile.Write2( Spelling[Ident[i].DataType], 15) else DiagFile.Write2( 'N/A', 15);
    DiagFile.Write2( Ident[i].NumAllocElements, 15).Write2( IntToHex(Ident[i].Value, 8), 15);
    if (Ident[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and not Ident[i].IsNotDead
    then DiagFile.Write2( 'Yes', 5) else DiagFile.Write2('', 5);
    end;

  DiagFile.WriteLn2;
  DiagFile.WriteLn2;
  DiagFile.WriteLn2( 'Call graph: ');
  DiagFile.WriteLn2;

  for i := 1 to NumBlocks do
    begin
    DiagFile.Write2( i, 6).Write2('  ---> ');
    for ChildIndex := 1 to CallGraph[i].NumChildren do
      DiagFile.Write2( CallGraph[i].ChildBlock[ChildIndex], 5);
    DiagFile.WriteLn2;
    end;

  DiagFile.WriteLn2;
  DiagFile.Close2;
  DiagFile.Free;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


end.
