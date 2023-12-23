::@author FB
::@version 0.1.0

::Powershell设置环境变量
::  参数1: 环境变量名
::  参数2: 环境变量值
::  参数3: 作用域(MACHINE/USER/PROCESS)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
SET "@NAME=%~1" & SET "@VALUE=%~2" & SET "@TARGET=%~3"
Powershell.EXE -Command "& { $ErrorActionPreference='Ignore'; [Environment]::SetEnvironmentVariable(${Env:@NAME},${Env:@VALUE},${Env:@TARGET}); Exit -Not $? }"
ENDLOCAL
EXIT /B
