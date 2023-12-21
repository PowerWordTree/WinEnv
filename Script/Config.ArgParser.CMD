::@author FB
::@version 0.1.0

::有序参数: 实例.PARAM, 保存为Array
::选项参数: 实例.OPTION, 保存为Map

::解析参数
::  参数1: 实例名称
::  参数N: 参数

::Script:Array.Clear.CMD::
::Script:Array.Push.CMD::
::Script:Map.Clear.CMD::
::Script:Map.Put.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@VAR=%~1"
CALL Array.Clear.CMD "%@VAR%.PARAM"
CALL Map.Clear.CMD "%@VAR%.OPTION"
:_ARG_PARSE_LOOP
SHIFT
IF "%1" == "" (SET "@=" & SET "@VAR=" & EXIT /B)
SET "@=%~1"
ECHO.%@% | FINDSTR "^[-/]" 1>NUL 2>&1 && (
  ECHO.%~2 | FINDSTR /R /C:"^[-/]" /C:"^[ ]*$" 1>NUL 2>&1 && (
    CALL Map.Put.CMD "%@VAR%.OPTION" "%%@:~1%%" "TRUE"
  ) || (
    CALL Map.Put.CMD "%@VAR%.OPTION" "%%@:~1%%" "%~2"
    SHIFT
  )
) || (
  CALL Array.Push.CMD "%@VAR%.PARAM" "%%@%%"
)
GOTO :_ARG_PARSE_LOOP
