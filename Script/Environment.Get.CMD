::@author FB
::@version 0.1.0

::获取环境变量
::  参数1: 作用域(MACHINE/USER)
::  参数2: 环境变量名
::  返回@: 环境变量值
::  错误码: 0,有值; 1,空值;

::Script:Registry.Query.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL
SET "@NAME=%~2"
IF "%~1" == "MACHINE" (
  SET "@PATH=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
) ELSE (
  SET "@PATH=HKEY_CURRENT_USER\Environment"
)
CALL Registry.Query.CMD "%%@PATH%%" "%%@NAME%%"
ENDLOCAL & SET "@=%@%" & EXIT /B %ERRORLEVEL%
