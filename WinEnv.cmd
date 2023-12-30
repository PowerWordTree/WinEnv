::������������
::@author FB
::@version 1.0.0

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

::��ʼ������
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
::��������
CALL Argument.Parser.CMD "_ARG" %*
IF "%_ARG.OPTION.O%" == "1" (
  SET "_OPTION=/D 1 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "2" (
  SET "_OPTION=/D 2 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "3" (
  SET "_OPTION=/D 3 /T 0"
) ELSE (
  SET "_OPTION="
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
::�������
ECHO.
ECHO ============================================
ECHO =======         ������������          ======
ECHO ============================================
::�������
IF /I "%_ARG.OPTION.H%" == "TRUE" (
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
  ECHO   ��ѡ����: `1`���û�������, `2`�ָ���������, `3`�˳�.
  ECHO   Ĭ�ϲ���Ϊ�ȴ��û�ѡ��.
  ECHO.
  ECHO - /h ^| -h
  ECHO   ��ʾ����
  ECHO.
  SET "_OPTION=ANY"
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
CHOICE /C:123 %_OPTION% /M "��ѡ��:"
GOTO :OP_%ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OP_1
::��ȡ�����ļ�
ECHO.
ECHO �����ļ�: %_CONFIG%
IF NOT EXIST "%_CONFIG%" (
  ECHO.
  ECHO.***** ����, �����ļ������ڣ�*****
  SET "_EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "_CONFIG" "%%_CONFIG%%"
::���ݻ�������
CALL Map.New.CMD "_CONFIG_OLD"
::::չ������
CALL Map.Put.CMD "_CONFIG_OLD" "SCOPE" "%_CONFIG.SCOPE%"
CALL Map.NewChild.CMD "_CONFIG_OLD" "REPLACE"
FOR %%A IN ("REPLACE","INSERT","APPEND") DO (
  FOR /F "usebackq delims=" %%I IN (
    `CALL Map.List.CMD "_CONFIG.%%~A" "{0}"`
  ) DO (
    ::::չ������
    CALL SET "_KEY=%%~I"
    CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" || SET "@=(Removed)"
    ::::ת�����
    CALL String.Replace.CMD "%%@%%" "%%%%" "%%%%%%%%"
    CALL Map.Put.CMD "_CONFIG_OLD.REPLACE" "%%_KEY%%" "%%@%%"
  )
)
CALL Config.FileWrite.CMD "_CONFIG_OLD" "%%_CONFIG_OLD%%"
::���û�������
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG.REPLACE" "{0}={1}"`
) DO (
  ::::չ������
  CALL :SETENV "%%~A" "%%~B"
  CALL SET "_KEY=%%~A" & CALL SET "_VALUE=%%~B"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  IF /I "%%~B" == "(Removed)" SET "_VALUE="
  CALL Environment.Set.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" "%%_VALUE%%"
)
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG.INSERT" "{0}={1}"`
) DO (
  ::::չ������
  CALL :SETENV "%%~A" "%%~B%%%%~A%%"
  CALL SET "_KEY=%%~A" & CALL SET "_VALUE=%%~B"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%%%@%%
  CALL Environment.Set.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" "%%_VALUE%%%%@%%"
)
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG.APPEND" "{0}={1}"`
) DO (
  ::::չ������
  CALL :SETENV "%%~A" "%%%%~A%%%%~B"
  CALL SET "_KEY=%%~A" & CALL SET "_VALUE=%%~B"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%"
  CALL ECHO %%_KEY%%=%%@%%%%_VALUE%%
  CALL Environment.Set.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" "%%@%%%%_VALUE%%"
)
GOTO :EXIT

:OP_2
::��ȡ�����ļ�
ECHO.
ECHO �����ļ�: %_CONFIG_OLD%
IF NOT EXIST "%_CONFIG_OLD%" (
  ECHO.
  ECHO.***** ����, �����ļ������ڣ�*****
  SET "_EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "_CONFIG_OLD" "%%_CONFIG_OLD%%"
::�ָ���������
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `CALL Map.List.CMD "_CONFIG_OLD.REPLACE" "{0}={1}"`
) DO (
  ::չ������
  CALL :SETENV "%%~A" "%%~B"
  CALL SET "_KEY=%%~A" & CALL SET "_VALUE=%%~B"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  IF /I "%%~B" == "(Removed)" SET "_VALUE="
  CALL Environment.Set.CMD "%%_CONFIG_OLD.SCOPE%%" "%%_KEY%%" "%%_VALUE%%"
)
GOTO :EXIT

:OP_3
:OP_0
:EXIT
IF "%_OPTION%" == "" (
  ECHO.
  ECHO ���������������
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %_EXIT_CODE%

::���ñ���
:SETENV
SET "_KEY=%~1"
IF "%_KEY%" == "" GOTO :EOF
IF /I "%_KEY%" == "PATH" GOTO :EOF
IF "%_KEY:~,1%" == "_" GOTO :EOF
IF "%_KEY:~,1%" == "@" GOTO :EOF
SET "%~1=%~2"
GOTO :EOF
