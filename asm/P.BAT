:
: Fichero: P.BAT
:
: Descripci¢n:
:   Ensamblar m¢dulo fuente principal de un programa y crear m¢dulo
:   objeto.
:
:-----------------------------------------------------------------------
:
  echo off
  if z%1 == z goto error
  goto check
:error
  echo *** error: falta nombre del m¢dulo fuente ***
  goto fin
:check
  if exist %1.asm goto ensam
  echo *** error: fichero %1.asm no existe ***
  goto fin
:ensam
  masm %1 /I. /IC:\ASM\HABLA /Z;
  if exist %1.obj goto mensa
  echo *** error en programa fuente ***
  pause
  if exist %1.com del %1.com
  if exist %1.exe del %1.exe
  goto fin
:mensa
  echo ... creado fichero %1.obj
  link %1;
  exe2bin %1.exe %1.com;
  if exist %1.exe del %1.exe
  if exist %1.OBJ del %1.OBJ
:fin