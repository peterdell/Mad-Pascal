program LanguageTests;

uses SysUtils;

// https://en.wikipedia.org/wiki/Single-precision_floating-point_format
procedure TestRound(fl : Single);
var i : LongInt; // 32 bit
var j : LongInt; // 32 bit
begin
  i:=Round(fl*256);  // Round Next Even
    j:=LongInt(fl);

  Writeln(fl,' i=',i:11 ,' ',IntToHex(i,8),' j=',j:11,' ',IntToHex(j,8));
end;


begin

  TestRound(1);
  TestRound(2);
  TestRound(4);
  TestRound(8);

  TestRound(-1);
  TestRound(-2);
  TestRound(-4);
  TestRound(-8);

  TestRound(0.1);
  TestRound(0.5);
  TestRound(1.5);
  TestRound(1.9);

  TestRound(-0.1);
  TestRound(-0.5);
  TestRound(-1.1);
  TestRound(-1.5);
  TestRound(-1.9);

end.

