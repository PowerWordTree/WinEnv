::环境变量管理
::@author FB
::@version 0.2.3

::Script:Argument.Parser.CMD::
::Script:Config.FileRead.CMD::
::Script:Config.FileWrite.CMD::
::Script:Environment.Get.CMD::
::Script:Environment.Set.CMD::
::Script:File.GetPath.CMD::
::Script:Map.New.CMD::
::Script:Map.NewChild.CMD::
::Script:Map.List.CMD::
::Script:Map.Put.CMD::
::Script:String.Replace.CMD::

::初始化环境
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
::解析参数
CALL Argument.Parser.CMD "_ARG" %*
IF "%_ARG.OPTION.O%" == "1" (
  SET "OPTION=/D 1 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "2" (
  SET "OPTION=/D 2 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "3" (
  SET "OPTION=/D 3 /T 0"
) ELSE (
  SET "OPTION="
)
IF "%_ARG.PARAM.0%" == "" (
  SET "_CONFIG=%~n0.ini"
  SET "_CONFIG_OLD=%~n0.old"
) ELSE IF /I "%_ARG.PARAM.0:~-4%" == ".ini" (
  SET "_CONFIG=%_ARG.PARAM.0%"
  SET "_CONFIG_OLD=%_ARG.PARAM.0:~,-4%.old"
) ELSE (
  SET "_CONFIG=%_ARG.PARAM.0%.ini"
  SET "_CONFIG_OLD=%_ARG.PARAM.0%.old"
)
CALL File.GetPath.CMD "%%_CONFIG%%"
CD /D "%@%"
::输出标题
ECHO.
ECHO ============================================
ECHO =======         环境变量管理          ======
ECHO ============================================
::输出帮助
IF /I "%_ARG.OPTION.H%" == "TRUE" (
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
ECHO 配置文件: %_CONFIG%
IF NOT EXIST "%_CONFIG%" (
  ECHO.
  ECHO.***** 错误, 配置文件不存在！*****
  SET "_EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "_CONFIG" "%%_CONFIG%%"
FOR /F "usebackq delims=" %%A IN (`SET "_CONFIG." 2^>NUL`) DO (CALL SET "%%~A")
::备份环境变量
CALL Map.New.CMD "_CONFIG_OLD"
CALL Map.Put.CMD "_CONFIG_OLD" "SCOPE" "%%_CONFIG.SCOPE%%"
CALL Map.NewChild.CMD "_CONFIG_OLD" "REPLACE"
FOR %%A IN ("REPLACE","APPEND","INSERT") DO (
  FOR /F "usebackq delims=" %%I IN (
    `CALL Map.List.CMD "_CONFIG.%%~A" "{0}"`
  ) DO (
    SET "_KEY=%%~I"
    CALL Environment.Get.CMD "%%_KEY%%" "%%_CONFIG.SCOPE%%" || SET "@=(Removed)"
    CALL Map.Put.CMD "_CONFIG_OLD.REPLACE" "%%_KEY%%" "%%@%%"
  )
)
FOR /F "usebackq delims=" %%A IN (`SET "_CONFIG_OLD." 2^>NUL`) DO (
  SET "_STR=%%~A" & CALL String.Replace.CMD "%%_STR%%" "%%%%" "%%%%%%%%"
  CALL SET "%%@%%"
)
CALL Config.FileWrite.CMD "_CONFIG_OLD" "%%_CONFIG_OLD%%"
::设置环境变量
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG.REPLACE" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  IF /I "%%~B" == "(Removed)" SET "_VALUE="
  CALL Environment.Set.CMD "%%_KEY%%" "%%_VALUE%%" "%%_CONFIG.SCOPE%%"
)
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG.APPEND" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL Environment.Get.CMD "%%_KEY%%" "%%_CONFIG.SCOPE%%"
  CALL SET "_VALUE=%%@%%%%_VALUE%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL Environment.Set.CMD "%%_KEY%%" "%%_VALUE%%" "%%_CONFIG.SCOPE%%"
)
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG.INSERT" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL Environment.Get.CMD "%%_KEY%%" "%%_CONFIG.SCOPE%%"
  CALL SET "_VALUE=%%_VALUE%%%%@%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL Environment.Set.CMD "%%_KEY%%" "%%_VALUE%%" "%%_CONFIG.SCOPE%%"
)
GOTO :EXIT

:OP_2
::读取备份文件
ECHO.
ECHO 备份文件: %_CONFIG_OLD%
IF NOT EXIST "%_CONFIG_OLD%" (
  ECHO.
  ECHO.***** 错误, 配置文件不存在！*****
  SET "_EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "_CONFIG_OLD" "%%_CONFIG_OLD%%"
FOR /F "usebackq delims=" %%A IN (`SET "_CONFIG_OLD." 2^>NUL`) DO (CALL SET "%%~A")
::恢复环境变量
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG_OLD.REPLACE" "{0}={1}"`
) DO (
  SET "_KEY=%%~A" & SET "_VALUE=%%~B"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  IF /I "%%~B" == "(Removed)" SET "_VALUE="
  CALL Environment.Set.CMD "%%_KEY%%" "%%_VALUE%%" "%%_CONFIG_OLD.SCOPE%%"
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
ENDLOCAL & EXIT /B %_EXIT_CODE%
