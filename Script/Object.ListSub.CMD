::@author FB
::@version 0.1.0

::遍历子项
::  参数1: 实例名称
::  参数2: 变量(不含""引号)/输出格式({0}子项占位符)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
SET "@PREFIX=%~1."
IF DEFINED %2 (CALL SET "@CMD=%%%2%%") ELSE (SET "@CMD=%~2")
Powershell.EXE -Command "& { Get-ChildItem Env:${Env:@PREFIX}* -Name | ForEach-Object {$PSItem.Substring(${Env:@PREFIX}.Length)} | Where-Object {$PSItem -match '^[^.]+\.[^.]+$'} | ForEach-Object {$PSItem.split('.') | Select-Object -First 1} | Sort-Object -Unique | ForEach-Object {${Env:@CMD} -f $PSItem,''} }"
ENDLOCAL
EXIT /B
