// Topic: Error: Incompatible type for arg no. 2: Got "Longint", expected "Boolean". Var param must match exactly.
// https://forum.lazarus.freepascal.org/index.php/topic,70287.0.html

(*
pas2js has its own system.pas and is a little different from fpc.

Reviewing, pas2js has the following options for val: (system.pas)
Code: Pascal  [Select][+]
procedure val(const S: String; out NI : NativeInt; out Code: Integer); overload;
procedure val(const S: String; out NI : NativeUInt; out Code: Integer); overload;
procedure val(const S: String; out SI : ShortInt; out Code: Integer); overload;
procedure val(const S: String; out B : Byte; out Code: Integer); overload;
procedure val(const S: String; out SI : smallint; out Code: Integer); overload;
procedure val(const S: String; out W : word; out Code : Integer); overload;
procedure val(const S: String; out I : integer; out Code : Integer); overload;
procedure val(const S: String; out C : Cardinal; out Code: Integer); overload;
procedure val(const S: String; out d : double; out Code : Integer); overload;
procedure val(const S: String; out b : boolean; out Code: Integer); overload;

In all options, "out Code" is of type integer.

So your code would work if you change the type of variable from word to integer:

var
  n: string;
  v, p: integer;   
*)

program test;

var
     n: string;
     v: integer;     
     p: word;

begin

  n:='$123';
  val(n,v,p);
  
  Writeln("Test-70287.pas completed.");
end.
