::@author FB
::@version 0.1.0

::有序参数: 实例.PARAM, 保存为Array
::选项参数: 实例.OPTION, 保存为Map

::脚本中`&&`和`||`结构存在风险
::链式调用可能在某些情况下错误触发, 不能直接替代为`IF ELSE`结构
::如: (true) && (false) || (???)

::解析参数
::  参数1: 实例名称
::  参数N: 参数

::Script:Array.New.CMD::
::Script:Array.Push.CMD::
::Script:Map.New.CMD::
::Script:Map.Put.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@VAR=%~1"
CALL Array.New.CMD "%@VAR%.PARAM"
CALL Map.New.CMD "%@VAR%.OPTION"
:@ARGUMENT_PARSER_LOOP
SHIFT
IF "%1" == "" (SET "@VAR=" & EXIT /B)
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
GOTO :@ARGUMENT_PARSER_LOOP
