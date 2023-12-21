::������������
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

::��ʼ������
@ECHO OFF
SETLOCAL
CD /D "%~dp0"
SET "PATH=%CD%\Bin;%CD%\Script;%PATH%"
SET "EXIT_CODE=0"
CALL Object.Destroy.CMD "ARG"
CALL Object.Destroy.CMD "CONFIG"
CALL Object.Destroy.CMD "CONFIG_OLD"
::��������
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
::�������
ECHO.
ECHO ============================================
ECHO =======         ������������          ======
ECHO ============================================
::�������
IF /I "%ARG.OPTION.H%" == "TRUE" (
  ECHO.
  ECHO ������: %~nx0 [�����ļ�[.ini]] [/o^|-o ^<1^|2^|3^>] [/h^|-h]
  ECHO.
  ECHO - �����ļ�
  ECHO   ָ�������ļ�·��, ����ʡ��`.ini`.
  ECHO   �����ļ�����������ļ�������, ��չ��Ϊ`.old`.
  ECHO   Ĭ�������ļ�`%~n0.ini`, Ĭ�ϱ����ļ�`%~n0.old`.
  ECHO.
  ECHO - /o ^| -o
  ECHO   ָ��Ҫִ�еĲ���.
  ECHO   ��ѡ����, `1`���û�������, `2`�ָ���������, `3`�˳�.
  ECHO   Ĭ��Ϊ�ȴ��û�ѡ��.
  ECHO.
  ECHO - /h ^| -h
  ECHO   ��ʾ����
  ECHO.
  SET "OPTION=ANY"
  GOTO :EXIT
)
::ѡ��˵�
ECHO.
ECHO ***** ע��: ����������ܶ�ϵͳ����ƻ� *****
ECHO.
ECHO 1:���û�������
ECHO 2:�ָ���������
ECHO 3:�˳�
ECHO.
CHOICE /C:123 %OPTION% /M "��ѡ��:"
GOTO :OP_%ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OP_1
::��ȡ�����ļ�
ECHO.
ECHO �����ļ�: %CONFIG%
IF NOT EXIST "%CONFIG%" (
  ECHO.
  ECHO.***** ����, �����ļ������ڣ�*****
  SET "EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "CONFIG" "%CONFIG%"
FOR /F "usebackq delims=" %%A IN (`SET "CONFIG." 2^>NUL`) DO (CALL SET "%%~A")
::ע���·��
IF /I "%CONFIG.SCOPE%" == "MACHINE" (
  SET "_REG_PATH=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
) ELSE (
  SET "_REG_PATH=HKEY_CURRENT_USER\Environment"
)
::���ݻ�������
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
::���û�������
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
::��ȡ����
ECHO.
ECHO �����ļ�: %CONFIG_OLD%
IF NOT EXIST "%CONFIG_OLD%" (
  ECHO.
  ECHO.***** ����, �����ļ������ڣ�*****
  SET "EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "CONFIG_OLD" "%CONFIG_OLD%"
FOR /F "usebackq delims=" %%A IN (`SET "CONFIG_OLD." 2^>NUL`) DO (CALL SET "%%~A")
::ע���·��
IF /I "%CONFIG.SCOPE%" == "MACHINE" (
  SET "_REG_PATH=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
) ELSE (
  SET "_REG_PATH=HKEY_CURRENT_USER\Environment"
)
::���û���
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
  ECHO ���������������
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %EXIT_CODE%
