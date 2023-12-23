::@author FB
::@version 0.1.0

::遍历子项
::  参数1: 实例名称
::  参数2: 输出格式({0}子项占位符)
::  输出: 格式化后的多行字符串

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
SET "@PREFIX=%~1." & SET "@CMD=%~2"
Powershell.EXE -Command "& { $ErrorActionPreference='Ignore'; Get-ChildItem Env:${Env:@PREFIX}* -Name | ForEach-Object {$PSItem.Substring(${Env:@PREFIX}.Length)} | Where-Object {$PSItem -match '^[^.]+\.[^.]+$'} | ForEach-Object {$PSItem.split('.') | Select-Object -First 1} | Sort-Object -Unique | ForEach-Object {${Env:@CMD} -f $PSItem,''}; Exit -Not $? }"
ENDLOCAL
EXIT /B
