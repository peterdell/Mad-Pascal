program test;
uses Crt;
var i: Integer;
begin
  i:=1;
  Writeln(i);
  Writeln('Test completed. Press any key');
  repeat
  until KeyPressed;
end.
