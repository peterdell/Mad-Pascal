unit Numbers;

interface

{$i define.inc}
{$i Types.inc}


  // Fixed-point 32-bit real number storage
const
  FRACBITS		= 8;	// Float Fixed Point
  TWOPOWERFRACBITS	= 256;

type  TFloat = array [0..1] of integer; // 2*32 bits

function Zero: TFloat;

procedure Int2Float(var ConstVal: Int64);

function FromSingle(const s: Single): TFloat;

// Low-Level
procedure MoveTFloat(ConstVal: Int64; ftmp: TFloat); overload;
procedure MoveTFloat(ftmp: TFloat; ConstVal: Int64); overload;

implementation

function Zero: TFloat;
begin
  Result:=Default(TFloat);
end;

procedure Int2Float(var ConstVal: Int64);
var fl: single;
    ftmp: TFloat;

begin

   fl := integer(ConstVal);

   ftmp[0] := round(fl * TWOPOWERFRACBITS);
   ftmp[1] := integer(fl);

   move(ftmp, ConstVal, sizeof(ftmp));

end;

function FromSingle(const s: Single): TFloat;
begin
   Result[0] := round(s * TWOPOWERFRACBITS);
   Result[1] := integer(s);
end;

procedure MoveTFloat(ConstVal: Int64; ftmp: TFloat); overload;
begin
{$IFNDEF PAS2JS}
move(ConstVal, ftmp, sizeof(ftmp));
{$ENDIF}
end;

procedure MoveTFloat(ftmp: TFloat; ConstVal: Int64); overload;
begin
{$IFNDEF PAS2JS}
move(ftmp, ConstVal, sizeof(ftmp));
{$ENDIF}

end;

end.
