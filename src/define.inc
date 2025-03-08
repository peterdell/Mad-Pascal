{$ASSERTIONS ON} 

//{$DEFINE WHILEDO}

//{$DEFINE USEOPTFILE}

{$DEFINE OPTIMIZECODE}

// The Delphi form is not accepted by PAS2JS
{$IFNDEF PAS2JS}
  {$I+}
{$ELSE}
  {$IOCHECKS ON}
{$ENDIF}