::@author FB
::@version 0.1.0

::因为REG命令混乱的转义符代码, 造成很多奇怪的BUG
::脚本IF为了避免`\"`被错误转义

::因为CMD环境变量扩展在变量未定义时, 会继续寻找后续%组成变量,
::所以脚本中IF和SET不能写在一行, 以避免造成未知结果

::注册表添加
::  参数1: 注册表路径
::  参数2: 注册表键
::  参数3: 注册表类型
::  参数4: 注册表值
::  退出码: 0,执行成功; 1,执行失败;

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL
SET "@PATH=%~1" & SET "@KEY=%~2" & SET "@TYPE=%~3" & SET "@VALUE=%~4"
IF "%@PATH:~-1%" == "\" (
  SET "@PATH=%@PATH%\"
)
IF "%@KEY:~-1%" == "\" (
  SET "@KEY=%@KEY%\"
)
IF "%@TYPE:~-1%" == "\" (
  SET "@TYPE=%@TYPE%\"
)
IF "%@VALUE:~-1%" == "\" (
  SET "@VALUE=%@VALUE%\"
)
REG.EXE ADD "%@PATH%" /V "%@KEY%" /T "%@TYPE%" /D "%@VALUE%" /F 1>NUL 2>&1
ENDLOCAL & EXIT /B %ERRORLEVEL%
