unit Numbers;

interface

{$i define.inc}
{$i Types.inc}


// Fixed-point 32-bit real number storage
type
  TFloat = array [0..1] of Integer; // 2*32 bits

function Zero: TFloat;

procedure Int2Float(var ConstVal: Int64);

function FromSingle(const s: Single): TFloat;

// Low-Level
procedure MoveTFloat(const ConstVal: Int64; var ftmp: TFloat); overload;
procedure MoveTFloat(const ftmp: TFloat; var ConstVal: Int64); overload;

function CardToHalf(const ftmp: TFloat): Word; overload;

implementation

const
  TWOPOWERFRACBITS = 256;  // Faktor for 8-bit fractional part

function Zero: TFloat;
begin
  Result := Default(TFloat);
end;

procedure Int2Float(var ConstVal: Int64);
var
  fl: Single;
  ftmp: TFloat;

begin

  fl := Integer(ConstVal);

  ftmp := FromSingle(fl);

  MoveTFloat(ftmp, ConstVal);

end;

function FromSingle(const s: Single): TFloat;
begin
  Result[0] := round(s * TWOPOWERFRACBITS);
  Result[1] := Integer(s);
end;

procedure MoveTFloat(const ConstVal: Int64; var ftmp: TFloat); overload;
begin
{$IFNDEF PAS2JS}
  move(ConstVal, ftmp, sizeof(ftmp));
{$ENDIF}
end;

procedure MoveTFloat(const ftmp: TFloat; var ConstVal: Int64); overload;
begin
{$IFNDEF PAS2JS}
  move(ftmp, ConstVal, sizeof(ftmp));
{$ENDIF}

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function CardToHalf32(const src: Uint32): Word; overload;
var
  Sign, Exp, Mantissa: Longint;
  s: Single;


  function f32Tof16(fltInt32: Uint32): Word;
    //https://stackoverflow.com/questions/3026441/float32-to-float16/3026505
  var
    //  fltInt32: uint32;
    fltInt16, tmp: Uint16;

  begin
    //  fltInt32 := PLongWord(@Float)^;
    fltInt16 := (fltInt32 shr 31) shl 5;
    tmp := (fltInt32 shr 23) and $ff;
    tmp := (tmp - $70) and (Longword(SarLongint(($70 - tmp), 4)) shr 27);
    fltInt16 := (fltInt16 or tmp) shl 10;
    Result := fltInt16 or ((fltInt32 shr 13) and $3ff) + 1;
  end;

begin

{$IFNDEF PAS2JS}// TODO

  s := PSingle(@Src)^;

  if (frac(s) <> 0) and (abs(s) >= 0.000060975552) then

    Result := f32Tof16(Src)

  else
  begin

    // Extract sign, exponent, and mantissa from Single number
    Sign := Src shr 31;
    Exp := Longint((Src and $7F800000) shr 23) - 127 + 15;
    Mantissa := Src and $007FFFFF;

    if (Exp > 0) and (Exp < 30) then
    begin
      // Simple case - round the significand and combine it with the sign and exponent
      Result := (Sign shl 15) or (Exp shl 10) or ((Mantissa + $00001000) shr 13);
    end
    else if Src = 0 then
    begin
      // Input float is zero - return zero
      Result := 0;
    end
    else
    begin
      // Difficult case - lengthy conversion
      if Exp <= 0 then
      begin
        if Exp < -10 then
        begin
          // Input float's value is less than HalfMin, return zero
          Result := 0;
        end
        else
        begin
          // Float is a normalized Single whose magnitude is less than HalfNormMin.
          // We convert it to denormalized half.
          Mantissa := (Mantissa or $00800000) shr (1 - Exp);
          // Round to nearest
          if (Mantissa and $00001000) > 0 then
            Mantissa := Mantissa + $00002000;
          // Assemble Sign and Mantissa (Exp is zero to get denormalized number)
          Result := (Sign shl 15) or (Mantissa shr 13);
        end;
      end
      else if Exp = 255 - 127 + 15 then
      begin
        if Mantissa = 0 then
        begin
          // Input float is infinity, create infinity half with original sign
          Result := (Sign shl 15) or $7C00;
        end
        else
        begin
          // Input float is NaN, create half NaN with original sign and mantissa
          Result := (Sign shl 15) or $7C00 or (Mantissa shr 13);
        end;
      end
      else
      begin
        // Exp is > 0 so input float is normalized Single

        // Round to nearest
        if (Mantissa and $00001000) > 0 then
        begin
          Mantissa := Mantissa + $00002000;
          if (Mantissa and $00800000) > 0 then
          begin
            Mantissa := 0;
            Exp := Exp + 1;
          end;
        end;

        if Exp > 30 then
        begin
          // Exponent overflow - return infinity half
          Result := (Sign shl 15) or $7C00;
        end
        else
          // Assemble normalized half
          Result := (Sign shl 15) or (Exp shl 10) or (Mantissa shr 13);
      end;
    end;

  end;

{$ENDIF}

end;  // CardToHalf32


function CardToHalf(const ftmp: TFloat): Word; overload;
var
  value: Uint32;
begin
  value := ftmp[1];
  Result := CardToHalf32(value);
end;

end.
