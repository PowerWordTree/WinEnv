::������������
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

::��ʼ������
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
::��������
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
ECHO �����ļ�: %_CONFIG%
IF NOT EXIST "%_CONFIG%" (
  ECHO.
  ECHO.***** ����, �����ļ������ڣ�*****
  SET "_EXIT_CODE=404"
  GOTO :EXIT
)
CALL Config.FileRead.CMD "_CONFIG" "%%_CONFIG%%"
FOR /F "usebackq delims=" %%A IN (`SET "_CONFIG." 2^>NUL`) DO (CALL SET "%%~A")
::���ݻ�������
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
::���û�������
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
FOR /F "usebackq delims=" %%A IN (`SET "_CONFIG_OLD." 2^>NUL`) DO (CALL SET "%%~A")
::�ָ���������
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
  ECHO ���������������
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %_EXIT_CODE%
