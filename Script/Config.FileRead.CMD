::@author FB
::@version 0.1.1

::数据结构为Object
::仅支持一级段
::由%包裹的变量不会被展开

::如果KEY是#开头,什么也不做
::如果VALUE不为空,保存到变量
::如果KEY被[]包裹,切换当前段

::读取配置文件
::  参数1: 实例名称
::  参数2: 配置文件

::Script:String.Trim.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@VAR=%~1" & SET "@SECTION=."
FOR /F "eol=# tokens=1,* usebackq delims==" %%A IN (
  `TYPE "%~2" 2^>NUL`
) DO (
  SET "@KEY=%%~A" & SET "@VALUE=%%~B"
  CALL String.Trim.CMD "%%@KEY%%" & CALL SET "@KEY=%%@%%"
  CALL String.Trim.CMD "%%@VALUE%%" & CALL SET "@VALUE=%%@%%"
  CALL :_PARSE_LINE
)
SET "@VALUE=" & SET "@KEY=" & SET "@SECTION=" & SET "@VAR="
EXIT /B

:_PARSE_LINE
IF NOT "%@KEY:~,1%" == "#" IF NOT "%@VALUE%" == "" (
  SET "%@VAR%%@SECTION%%@KEY%=%@VALUE%"
) ELSE IF "%@KEY:~,1%" == "[" IF "%@KEY:~-1%" == "]" (
  SET "@SECTION=.%@KEY:~1,-1%."
)
GOTO :EOF
