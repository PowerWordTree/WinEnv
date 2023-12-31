::@author FB
::@version 0.1.0

::展开变量
::  参数1: 包含变量的字符串
::  返回@: 展开后的字符串

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL
SET "@STR=%~1" & SET "@="
FOR /F "usebackq delims=" %%A IN (
  `Powershell.EXE -Command "& { [Environment]::ExpandEnvironmentVariables(${Env:@STR}) }"`
) DO (
  SET "@=%%~A"
)
ENDLOCAL & SET "@=%@%"
EXIT /B
