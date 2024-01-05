::@author FB
::@version 0.1.0

::设置环境变量
::  参数1: 作用域(MACHINE/USER)
::  参数2: 环境变量名
::  参数3: 环境变量值(空为删除)
::  退出码: 0,执行成功; 1,执行失败;

::Script:Common.Expand.CMD::
::Script:Registry.Add.CMD::
::Script:Registry.Delete.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL
SET "@NAME=%~2" & SET "@VALUE=%~3"
IF "%~1" == "MACHINE" (
  SET "@PATH=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
) ELSE (
  SET "@PATH=HKEY_CURRENT_USER\Environment"
)
CALL Common.Expand.CMD "%%@VALUE%%"
IF "%@VALUE%" == "" (
  CALL Registry.Delete.CMD "%%@PATH%%" "%%@NAME%%"
) ELSE IF "%@VALUE%" == "%@%" (
  CALL Registry.Add.CMD "%%@PATH%%" "%%@NAME%%" "REG_SZ" "%%@VALUE%%"
) ELSE (
  CALL Registry.Add.CMD "%%@PATH%%" "%%@NAME%%" "REG_EXPAND_SZ" "%%@VALUE%%"
)
ENDLOCAL & EXIT /B %ERRORLEVEL%
