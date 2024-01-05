::@author FB
::@version 0.1.0

::遍历
::  参数1: 实例名称
::  参数2: 输出格式({0}键占位符, {1}值占位符)
::  输出: 格式化后的多行字符串
::  退出码: 0,执行成功; 1,执行失败;

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@SETLOCAL
@SET "@PREFIX=%~1." & SET "@FMT=%~2"
@Powershell.EXE -Command "& { Get-Item Env:${Env:@PREFIX}@LIST -ErrorAction Ignore | ForEach-Object Value | ForEach-Object {$PSItem.Split(';',[StringSplitOptions]::RemoveEmptyEntries)} | ForEach-Object {$e=(Get-Item Env:${Env:@PREFIX}$PSItem -ErrorAction Ignore);IF ($e -eq $null) {New-Object System.Collections.DictionaryEntry($PSItem,'')} else {$e.name=$PSItem};$e} | ForEach-Object {${Env:@FMT} -f $PSItem.Name,$PSItem.Value}; Exit -Not $? }"
@ENDLOCAL & EXIT /B %ERRORLEVEL%
