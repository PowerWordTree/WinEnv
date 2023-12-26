::@author FB
::@version 0.1.0

::×Ö·û´®Ìæ»»
::  ²ÎÊý1: ×Ö·û´®
::  ²ÎÊý2: ¾É×Ö·û´®
::  ²ÎÊý3: ÐÂ×Ö·û´®
::  ·µ»Ø@: ×Ö·û´®

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
SET "@STR=%~1" & SET "@OLD=%~2" & SET "@NEW=%~3" & SET "@="
FOR /F "usebackq delims=" %%A IN (
  `Powershell.EXE -Command "& { ${Env:@STR} -Replace [regex]::Escape(${Env:@OLD}),${Env:@NEW} }"`
) DO (
  SET "@=%%~A"
)
ENDLOCAL & SET "@=%@%"
EXIT /B
