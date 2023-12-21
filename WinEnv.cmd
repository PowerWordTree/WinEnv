::环境变量管理
::@author FB
::@version 0.1.0

::Script:Config.ArgParser.CMD::
::Script:Config.FileRead.CMD::
::Script:Config.FileWrite.CMD::
::Script:Object.Destroy.CMD::
::Script:Object.ListAll.CMD::
::Script:Registry.Query.CMD::
::Script:Registry.Add.CMD::
::Script:Registry.Delete.CMD::
::Script:Powershell.Replace.CMD::

::初始化环境
@ECHO OFF
SETLOCAL
CD /D "%~dp0"
SET "PATH=%CD%\Bin;%CD%\Script;%PATH%"
SET "EXIT_CODE=0"
CALL Object.Destroy.CMD "ARG"
CALL Object.Destroy.CMD "CONFIG"
CALL Object.Destroy.CMD "CONFIG_OLD"
::解析参数
CALL Config.ArgParser.CMD "ARG" %*
IF "%ARG.OPTION.O%" == "1" (
  SET "OPTION=/D 1 /T 0"
) ELSE IF "%ARG.OPTION.O%" == "2" (
  SET "OPTION=/D 2 /T 0"
) ELSE IF "%ARG.OPTION.O%" == "3" (
  SET "OPTION=/D 3 /T 0"
) ELSE (
  SET "OPTION="
)
IF "%ARG.PARAM.0%" == "" (
  SET "CONFIG=%~n0.ini"
  SET "CONFIG_OLD=%~n0.old"
) ELSE IF /I "%ARG.PARAM.0:~-4%" == ".ini" (
  SET "CONFIG=%ARG.PARAM.0%"
  SET "CONFIG_OLD=%ARG.PARAM.0:~,-4%.old"
) ELSE (
  SET "CONFIG=%ARG.PARAM.0%.ini"
  SET "CONFIG_OLD=%ARG.PARAM.0%.old"
)
::输出标题
ECHO.
ECHO ============================================
ECHO =======         环境变量管理          ======
ECHO ============================================
::输出帮助
IF /I "%ARG.OPTION.H%" == "TRUE" (
  ECHO.
  ECHO 命令行: %~nx0 [配置文件[.ini]] [/o^|-o ^<1^|2^|3^>] [/h^|-h]
  ECHO.
  ECHO - 配置文件
  ECHO   指定配置文件路径, 可以省略`.ini`.
  ECHO   备份文件会根据配置文件名生成, 扩展名为`.old`.
  ECHO   默认配置文件`%~n0.ini`, 默认备份文件`%~n0.old`.
  ECHO.
  ECHO - /o ^| -o
  ECHO   指定要执行的操作.
  ECHO   必选参数, `1`设置环境变量, `2`恢复环境变量, `3`退出.
  ECHO   默认为等待用户选择.
  ECHO.
  ECHO - /h ^| -h
  ECHO   显示帮助
  ECHO.
  SET "OPTION=ANY"
  GOTO :EXIT
)
::选择菜单
ECHO.
ECHO ***** 注意: 错误操作可能对系统造成破坏 *****
ECHO.
ECHO 1:设置环境变量
ECHO 2:恢复环境变量
ECHO 3:退出
ECHO.
CHOICE /C:123 %OPTION% /M "请选择:"
GOTO :OP_%ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OP_1
::读取配置文件
ECHO.
ECHO 配置文件: %CONFIG%
IF NOT EXIST "%CONFIG%" (
  ECHO.
  ECHO.***** 错误, 配置文件不存在！*****
  SET "EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "CONFIG" "%CONFIG%"
FOR /F "usebackq delims=" %%A IN (`SET "CONFIG." 2^>NUL`) DO (CALL SET "%%~A")
::注册表路径
IF /I "%CONFIG.SCOPE%" == "MACHINE" (
  SET "_REG_PATH=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
) ELSE (
  SET "_REG_PATH=HKEY_CURRENT_USER\Environment"
)
::备份环境变量
SET "CONFIG_OLD.SCOPE=%CONFIG.SCOPE%"
FOR %%A IN ("REPLACE","APPEND","INSERT") DO (
  FOR /F "usebackq delims=" %%I IN (
    `CALL Object.ListAll.CMD "CONFIG.%%~A" "{0}"`
  ) DO (
    SET "_KEY=%%~I"
    CALL Registry.Query.CMD "%%_REG_PATH%%" "%%_KEY%%" || SET "@=(Removed)"
    CALL SET "CONFIG_OLD.REPLACE.%%_KEY%%=%%@%%"
  )
)
FOR /F "usebackq delims=" %%A IN (`SET "CONFIG_OLD." 2^>NUL`) DO (
  SET "_STR=%%~A" & CALL Powershell.Replace.CMD _STR "%%%%" "%%%%%%%%"
  CALL SET "%%@%%"
)
CALL Config.FileWrite.CMD "CONFIG_OLD" "%CONFIG_OLD%"
::设置环境变量
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Object.ListAll.CMD "CONFIG.REPLACE" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  IF /I "%%~B" == "(Removed)" (
    CALL Registry.Delete.CMD "%%_REG_PATH%%" "%%_KEY%%"
  ) ELSE (
    CALL Registry.Add.CMD "%%_REG_PATH%%" "%%_KEY%%" "REG_EXPAND_SZ" "%%_VALUE%%"
  )
)
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Object.ListAll.CMD "CONFIG.APPEND" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL Registry.Query.CMD "%_REG_PATH%" "%%_KEY%%"
  CALL ECHO %%_KEY%%=%%@%%%%_VALUE%%
  CALL Registry.Add.CMD "%_REG_PATH%" "%%_KEY%%" "REG_EXPAND_SZ" "%%@%%%%_VALUE%%"
)
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Object.ListAll.CMD "CONFIG.INSERT" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL Registry.Query.CMD "%_REG_PATH%" "%%_KEY%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%%%@%%
  CALL Registry.Add.CMD "%_REG_PATH%" "%%_KEY%%" "REG_EXPAND_SZ" "%%_VALUE%%%%@%%"
)
GOTO :EXIT

:OP_2
::读取备份
ECHO.
ECHO 备份文件: %CONFIG_OLD%
IF NOT EXIST "%CONFIG_OLD%" (
  ECHO.
  ECHO.***** 错误, 配置文件不存在！*****
  SET "EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "CONFIG_OLD" "%CONFIG_OLD%"
FOR /F "usebackq delims=" %%A IN (`SET "CONFIG_OLD." 2^>NUL`) DO (CALL SET "%%~A")
::注册表路径
IF /I "%CONFIG.SCOPE%" == "MACHINE" (
  SET "_REG_PATH=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
) ELSE (
  SET "_REG_PATH=HKEY_CURRENT_USER\Environment"
)
::设置环境
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Object.ListAll.CMD "CONFIG_OLD.REPLACE" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  IF /I "%%~B" == "(Removed)" (
    CALL Registry.Delete.CMD "%%_REG_PATH%%" "%%_KEY%%"
  ) ELSE (
    CALL Registry.Add.CMD "%%_REG_PATH%%" "%%_KEY%%" "REG_EXPAND_SZ" "%%_VALUE%%"
  )
)
GOTO :EXIT

:OP_3
:OP_0
:EXIT
IF "%OPTION%" == "" (
  ECHO.
  ECHO 按任意键结束……
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %EXIT_CODE%
