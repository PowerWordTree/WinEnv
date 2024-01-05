::@author FB
::@version 0.1.0

::遍历子项
::  参数1: 实例名称
::  参数2: 输出格式({0}子项占位符)
::  输出: 格式化后的多行字符串
::  退出码: 0,执行成功; 1,执行失败;

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@SETLOCAL
@SET "@PREFIX=%~1." & SET "@FMT=%~2"
@Powershell.EXE -Command "& { Get-Item Env:${Env:@PREFIX}@CHILD -ErrorAction Ignore | ForEach-Object Value | ForEach-Object {$PSItem.Split(';',[StringSplitOptions]::RemoveEmptyEntries)} | ForEach-Object {${Env:@FMT} -f $PSItem,''}; Exit -Not $? }"
@ENDLOCAL & EXIT /B %ERRORLEVEL%
