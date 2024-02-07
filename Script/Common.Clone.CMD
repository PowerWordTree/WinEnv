::@author FB
::@version 0.1.0

::展开命令`FOR`的变量时, 会忽略大部分特殊符号.
::例如:
::  C:\>SET VAR=ECHO "a & b | c" ^& ECHO true
::  C:\>FOR /F "usebackq delims=" %A IN (`SET VAR`) DO ECHO %A
::  VAR=ECHO "a & b | c" & ECHO true
::第二个`ECHO`不会被执行, 视为字符串的一部分.
::使用延迟环境变量展开`!var!`时, 有同样效果.

::变量克隆
::  参数1: 来源变量名
::  参数2: 目标变量名

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF /I "%~1" == "%~2" (EXIT /B) ELSE (SET "%~2=")
FOR /F "tokens=1,* usebackq delims==" %%A IN (`SET "%~1"`) DO (
  IF /I "%%A" == "%~1" SET "%~2=%%B"
)
EXIT /B
