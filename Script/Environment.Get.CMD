::@author FB
::@version 0.1.0

::设置环境变量获取
::  参数1: 环境变量名
::  参数2: 作用域(MACHINE/USER)
::  返回@: 环境变量值

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
SET "@NAME=%~1" & SET "@TARGET=%~2" & SET "@="
FOR /F "usebackq delims=" %%A IN (
  `Powershell.EXE -Command "& { [Environment]::GetEnvironmentVariable(${Env:@NAME},${Env:@TARGET}) }"`
) DO (
  SET "@=%%~A"
)
ENDLOCAL & SET "@=%@%"
IF "%@%" == "" EXIT /B 1
EXIT /B 0
