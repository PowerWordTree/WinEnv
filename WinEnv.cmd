::环境变量管理
::@Authors FB
::@Version 1.1.0
::@Description
::  批量添加 Windows 环境变量的工具.
::  根据配置文件, 对 Windows 环境变量进行设置, 当前工作目录为配置文件所在目录.
::@Variables
::  @*, _ANSI_*, _EXIT_CODE, _ARG, _NOWAIT, _OPTION, _NOWAIT, _CONFIGFILE,
::  _CONFIGFILE_OLD, _CONFIG, _ENV_LIST, _KEY, _VALUE
::@Syntax
::  WinEnv.cmd [配置文件[.ini]] [/o^|-o ^<1^|2^|3^>]
::    [/NoWait^|-NoWait] [/NoLogo^|-NoLogo] [/NoAnsi^|-NoAnsi] [/h^|-h]
::@Arguments
::  %1: 配置文件
::    指定配置文件路径, 可以省略`.ini`.
::    备份文件会根据配置文件名生成, 扩展名为`.old`.
::    默认配置文件`%~n0.ini`, 默认备份文件`%~n0.old`.
::  o: 指定要执行的操作
::    必选参数: `1`设置环境变量, `2`恢复环境变量, `3`退出.
::    默认操作为等待用户选择.
::  NoWait: 执行结束时无等待.
::  NoLogo: 执行前不显示Logo.
::  NoAnsi: 禁用转义序列显示.
::  h: 显示帮助
::@Outputs
::  FILE:
::    原设置的备份文件,作为回复时使用.
::  STDOUT: 支持ANSI的交互信息.
::  STDERR: 警告和错误信息.
::@Returns
::  0: 执行成功.
::  N: 执行失败.
::@Examples
::  WinEnv.cmd
::  WinEnv.cmd XXX
::  WinEnv.cmd XXX.ini
::  WinEnv.cmd XXX /o 1
::  WinEnv.cmd XXX.ini /o 2

::Script:Argument.Parser.CMD::
::Script:Common.AnsiEscape.CMD::
::Script:Common.IsAdmin.CMD::
::Script:Config.FileRead.CMD::
::Script:Config.FileWrite.CMD::
::Script:Environment.Get.CMD::
::Script:Environment.Set.CMD::
::Script:Map.New.CMD::
::Script:Map.NewChild.CMD::
::Script:Map.List.CMD::
::Script:Map.Put.CMD::
::Script:Path.GetAbsolutePath.CMD::
::Script:Path.GetPath.CMD::
::Script:Process.Callback.CMD::
::Script:String.Replace.CMD::

::初始化环境
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
::解析参数
CALL Argument.Parser.CMD "_ARG" %*
SET "_NOWAIT=%_ARG.OPTION.NoWait%"
IF /I NOT "%_ARG.OPTION.NoAnsi%" == "TRUE" (
  CALL Common.AnsiEscape.CMD "True"
) ELSE (
  CALL Common.AnsiEscape.CMD "False"
)
IF /I NOT "%_ARG.OPTION.NoLogo%" == "TRUE" CALL :SHOW_LOGO
IF /I "%_ARG.OPTION.H%" == "TRUE" (
  CALL :SHOW_HELP
  GOTO :EXIT
)
IF "%_ARG.OPTION.O%" == "1" (
  SET "_OPTION=/D 1 /T 0"
  SET "_NOWAIT=TRUE"
) ELSE IF "%_ARG.OPTION.O%" == "2" (
  SET "_OPTION=/D 2 /T 0"
  SET "_NOWAIT=TRUE"
) ELSE IF "%_ARG.OPTION.O%" == "3" (
  SET "_OPTION=/D 3 /T 0"
  SET "_NOWAIT=TRUE"
) ELSE (
  SET "_OPTION="
)
IF "%_ARG.PARAM.0%" == "" (
  SET "_CONFIGFILE=%~dpn0.ini"
) ELSE IF /I "%_ARG.PARAM.0:~-4%" == ".ini" (
  SET "_CONFIGFILE=%_ARG.PARAM.0%"
) ELSE (
  SET "_CONFIGFILE=%_ARG.PARAM.0%.ini"
)
CALL Path.GetAbsolutePath.CMD "%%_CONFIGFILE%%"
SET "_CONFIGFILE=%@%"
SET "_CONFIGFILE_OLD=%@:~0,-4%.old"
::选择菜单
CALL :SHOW_MENU
CHOICE /C:123 %_OPTION% /M "请选择:"
IF "%ERRORLEVEL%" == "1" (
  CALL :READ_CONFIGFILE "%%_CONFIGFILE%%" ^
    && CALL :CHECK_PERMISSIONS ^
    && CALL :BACKUP_ENVIRONMENT "%%_CONFIGFILE_OLD%%" ^
    && CALL :UPDATE_ENVIRONMENT
) ELSE IF "%ERRORLEVEL%" == "2" (
  CALL :READ_CONFIGFILE "%%_CONFIGFILE_OLD%%" ^
    && CALL :CHECK_PERMISSIONS ^
    && CALL :UPDATE_ENVIRONMENT
)
::退出
:EXIT
IF /I NOT "%_NOWAIT%" == "TRUE" (
  CALL :ECHO_LIGHT 按任意键结束……
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %_EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::输出Logo
::@Outputs
::  STDOUT: 帮助
:SHOW_LOGO
ECHO.
ECHO ============================================
ECHO =======         环境变量管理          ======
ECHO ============================================
GOTO :EOF

::输出Help
::@Outputs
::  STDOUT: 帮助
:SHOW_HELP
ECHO.
ECHO %~nx0 [配置文件[.ini]] [/o^|-o ^<1^|2^|3^>]
ECHO   [/NoWait^|-NoWait] [/NoLogo^|-NoLogo] [/NoAnsi^|-NoAnsi] [/h^|-h]
ECHO.
ECHO - 配置文件
ECHO   指定配置文件路径, 可以省略`.ini`.
ECHO   备份文件会根据配置文件名生成, 扩展名为`.old`.
ECHO   默认配置文件`%~n0.ini`, 默认备份文件`%~n0.old`.
ECHO.
ECHO - /o ^| -o
ECHO   指定要执行的操作.
ECHO   必选参数: `1`设置环境变量, `2`恢复环境变量, `3`退出.
ECHO   默认操作为等待用户选择.
ECHO.
ECHO - /NoWait ^| -NoWait
ECHO   执行结束时无等待.
ECHO.
ECHO - /NoLogo ^| -NoLogo
ECHO   执行前不显示Logo.
ECHO.
ECHO - /NoAnsi ^| -NoAnsi
ECHO   禁用转义序列显示.
ECHO.
ECHO - /h ^| -h
ECHO   显示帮助
ECHO.
GOTO :EOF

::输出Menu
::@Outputs
::  STDOUT: 菜单
::  STDERR: 错误信息
:SHOW_MENU
CALL :ECHO_WARNING ***** 注意: 错误操作可能破坏系统! *****
ECHO.
ECHO 1:设置环境变量
ECHO 2:恢复环境变量
ECHO 3:退出
ECHO.
GOTO :EOF

::读取配置文件
::@Variables
::  @*, _CONFIG, _EXIT_CODE
::@Arguments
::  %1: 配置文件路径
::@Outputs
::  %_CONFIG%: 配置实例
::  %_EXIT_CODE%: 错误码
::  STDOUT: 支持ANSI的交互信息
::  STDERR: 错误信息
::@Returns
::  0: 执行成功
::  1: 执行失败
:READ_CONFIGFILE
CALL :ECHO_LIGHT 配置文件: %~1
CALL Path.GetPath.CMD "%~1"
CD /D "%@%"
CALL Config.FileRead.CMD "_CONFIG" "%~1" || (
  CALL :ECHO_ERROR ***** 错误, 配置文件读取错误! *****
  SET "_EXIT_CODE=404"
  EXIT /B 1
)
EXIT /B 0

::检查权限
::@Variables
::  @*, _CONFIG, _EXIT_CODE
::@Arguments
::  %_CONFIG%: 配置实例
::@Outputs
::  %_EXIT_CODE%: 错误时,输出错误码
::  STDERR: 错误信息
::@Returns
::  0: 执行成功
::  1: 执行失败
:CHECK_PERMISSIONS
IF "%_CONFIG.SCOPE%" == "MACHINE" (
  CALL Common.IsAdmin.CMD || (
    CALL :ECHO_ERROR ***** 错误, 需要管理员权限! *****
    SET "_EXIT_CODE=401"
    EXIT /B 1
  )
)
EXIT /B 0

::保存当前环境变量
::@Variables
::  @*, _CONFIG, _CONFIG_OLD, _ENV_LIST, _KEY, _EXIT_CODE
::@Arguments
::  %1: 备份文件路径
::  %_CONFIG%: 配置实例
::@Outputs
::  %_EXIT_CODE%: 错误时,输出错误码
::  STDOUT: 支持ANSI的交互信息
::  STDERR: 错误信息
::@Returns
::  0: 执行成功
::  1: 执行失败
:BACKUP_ENVIRONMENT
CALL :ECHO_LIGHT 保存当前环境变量:
CALL Map.New.CMD "_CONFIG_OLD"
::::此处展开变量
CALL Map.Put.CMD "_CONFIG_OLD" "SCOPE" "%_CONFIG.SCOPE%"
CALL Map.NewChild.CMD "_CONFIG_OLD" "REPLACE"
CALL Map.List.CMD "_CONFIG.REPLACE"
SET "_ENV_LIST=%@%"
CALL Map.List.CMD "_CONFIG.INSERT"
SET "_ENV_LIST=%_ENV_LIST%%@%"
CALL Map.List.CMD "_CONFIG.APPEND"
SET "_ENV_LIST=%_ENV_LIST%%@%"
FOR %%A IN (%_ENV_LIST%) DO (
  ::::此处展开变量
  CALL SET "_KEY=%%~A"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" || SET "@=(Removed)"
  CALL ECHO %%_KEY%%=%%@%%
  ::::转义变量
  CALL String.Replace.CMD "%%@%%" "%%%%" "%%%%%%%%"
  CALL Map.Put.CMD "_CONFIG_OLD.REPLACE" "%%_KEY%%" "%%@%%"
)
IF EXIST "%~1" DEL /Q /F "%~1" 1>NUL 2>&1
CALL Config.FileWrite.CMD "_CONFIG_OLD" "%~1"
IF NOT EXIST "%~1" (
  CALL :ECHO_ERROR ***** 错误, 保存环境变量错误! *****
  SET "_EXIT_CODE=401"
  EXIT /B 1
)
EXIT /B 0

::更新环境变量
::@Variables
::  @*, _CONFIG, _KEY, _VALUE, _EXIT_CODE
::@Arguments
::  %_CONFIG%: 配置实例
::@Outputs
::  %_EXIT_CODE%: 错误时,输出错误码
::  STDOUT: 支持ANSI的交互信息
::@Returns
::  0: 执行成功
::  1: 执行失败
:UPDATE_ENVIRONMENT
CALL :ECHO_LIGHT 更新环境变量:
CALL Map.List.CMD "_CONFIG.REPLACE"
FOR %%A IN (%@%) DO (
  ::::此处展开变量
  CALL SET "_KEY=%%~A" & CALL CALL SET "_VALUE=%%_CONFIG.REPLACE.%%~A%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL Process.Callback.CMD IF /I "%%_VALUE%%" == "(Removed)" SET "_VALUE="
  CALL :SETENV
)
CALL Map.List.CMD "_CONFIG.INSERT"
FOR %%A IN (%@%) DO (
  ::::此处展开变量
  CALL SET "_KEY=%%~A" & CALL CALL SET "_VALUE=%%_CONFIG.INSERT.%%~A%%"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%"
  CALL SET "_VALUE=%%_VALUE%%%%@%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL :SETENV
)
CALL Map.List.CMD "_CONFIG.APPEND"
FOR %%A IN (%@%) DO (
  ::::此处展开变量
  CALL SET "_KEY=%%~A" & CALL CALL SET "_VALUE=%%_CONFIG.APPEND.%%~A%%"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%"
  CALL SET "_VALUE=%%@%%%%_VALUE%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL :SETENV
)
GOTO :EOF

::临时设置变量
::@Variables
::  *@, _CONFIG, _KEY, _VALUE
::@Arguments
::  %_CONFIG%: 配置实例
::  %_KEY%: 键
::  %_VALUE%: 值
::@Outputs
::  %%_KEY%%: 符合条件时, %_KEY%为键, %_VALUE%为值, 设置变量.
:SETENV
CALL Environment.Set.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" "%%_VALUE%%"
IF "%_KEY%" == "" GOTO :EOF
IF /I "%_KEY%" == "PATH" GOTO :EOF
IF "%_KEY:~,1%" == "_" GOTO :EOF
IF "%_KEY:~,1%" == "@" GOTO :EOF
SET "%_KEY%=%_VALUE%"
GOTO :EOF

::输出高亮文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDOUT: 高亮文本
:ECHO_LIGHT
ECHO.
ECHO %ANSI_LIGHT%%*%ANSI_RESET%
GOTO :EOF

::输出成功文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDOUT: 成功文本
:ECHO_SUCCESS
ECHO.
ECHO %ANSI_FG_BRIGHT_GREEN%%*%ANSI_RESET%
GOTO :EOF

::输出警告文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDERR: 警告文本
:ECHO_WARNING
ECHO.
1>&2 ECHO %ANSI_FG_BRIGHT_YELLOW%%*%ANSI_RESET%
GOTO :EOF

::输出错误文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDERR: 错误文本
:ECHO_ERROR
ECHO.
1>&2 ECHO %ANSI_FG_BRIGHT_YELLOW%%ANSI_BG_RED%%*%ANSI_RESET%
GOTO :EOF
