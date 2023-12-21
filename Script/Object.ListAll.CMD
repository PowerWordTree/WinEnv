::@author FB
::@version 0.1.0

::遍历全部
::  参数1: 实例名称
::  参数2: 变量(不含""引号)/输出格式({0}键占位符, {1}值占位符)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
SET "@PREFIX=%~1."
IF DEFINED %2 (CALL SET "@CMD=%%%2%%") ELSE (SET "@CMD=%~2")
Powershell.EXE -Command "& { Get-Item Env:${Env:@PREFIX}* | ForEach-Object {$PSItem.Name = $PSItem.Name.Substring(${Env:@PREFIX}.Length); $PSItem} | Where-Object {$PSItem.Name -match '^.+$'} | Sort-Object -Property Name | ForEach-Object {${Env:@CMD} -f $PSItem.Name,$PSItem.Value} }"
ENDLOCAL
EXIT /B
