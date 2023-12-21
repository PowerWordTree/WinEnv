::@author FB
::@version 0.1.0

::Powershell字符串替换
::  参数1: 字符串/变量(不含""引号)
::  参数2: 旧字符串/变量(不含""引号)
::  参数3: 新字符串/变量(不含""引号)
::  返回@: 字符串

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
IF DEFINED %1 (CALL SET "@STR=%%%1%%") ELSE (SET "@STR=%~1")
IF DEFINED %2 (CALL SET "@OLD=%%%2%%") ELSE (SET "@OLD=%~2")
IF DEFINED %3 (CALL SET "@NEW=%%%3%%") ELSE (SET "@NEW=%~3")
FOR /F "usebackq delims=" %%A IN (
  `Powershell.EXE -Command "& { ${Env:@STR} -Replace [regex]::Escape(${Env:@OLD}),${Env:@NEW} }"`
) DO (
  SET "@=%%~A"
)
ENDLOCAL & SET "@=%@%"
EXIT /B
