::������������
::@Authors FB
::@Version 1.1.0
::@Description
::  ������� Windows ���������Ĺ���.
::  ���������ļ�, �� Windows ����������������, ��ǰ����Ŀ¼Ϊ�����ļ�����Ŀ¼.
::@Variables
::  @*, _ANSI_*, _EXIT_CODE, _ARG, _NOWAIT, _OPTION, _NOWAIT, _CONFIGFILE,
::  _CONFIGFILE_OLD, _CONFIG, _ENV_LIST, _KEY, _VALUE
::@Syntax
::  WinEnv.cmd [�����ļ�[.ini]] [/o^|-o ^<1^|2^|3^>]
::    [/NoWait^|-NoWait] [/NoLogo^|-NoLogo] [/NoAnsi^|-NoAnsi] [/h^|-h]
::@Arguments
::  %1: �����ļ�
::    ָ�������ļ�·��, ����ʡ��`.ini`.
::    �����ļ�����������ļ�������, ��չ��Ϊ`.old`.
::    Ĭ�������ļ�`%~n0.ini`, Ĭ�ϱ����ļ�`%~n0.old`.
::  o: ָ��Ҫִ�еĲ���
::    ��ѡ����: `1`���û�������, `2`�ָ���������, `3`�˳�.
::    Ĭ�ϲ���Ϊ�ȴ��û�ѡ��.
::  NoWait: ִ�н���ʱ�޵ȴ�.
::  NoLogo: ִ��ǰ����ʾLogo.
::  NoAnsi: ����ת��������ʾ.
::  h: ��ʾ����
::@Outputs
::  FILE:
::    ԭ���õı����ļ�,��Ϊ�ظ�ʱʹ��.
::  STDOUT: ֧��ANSI�Ľ�����Ϣ.
::  STDERR: ����ʹ�����Ϣ.
::@Returns
::  0: ִ�гɹ�.
::  N: ִ��ʧ��.
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

::��ʼ������
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
::��������
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
::ѡ��˵�
CALL :SHOW_MENU
CHOICE /C:123 %_OPTION% /M "��ѡ��:"
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
::�˳�
:EXIT
IF /I NOT "%_NOWAIT%" == "TRUE" (
  CALL :ECHO_LIGHT ���������������
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %_EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::���Logo
::@Outputs
::  STDOUT: ����
:SHOW_LOGO
ECHO.
ECHO ============================================
ECHO =======         ������������          ======
ECHO ============================================
GOTO :EOF

::���Help
::@Outputs
::  STDOUT: ����
:SHOW_HELP
ECHO.
ECHO %~nx0 [�����ļ�[.ini]] [/o^|-o ^<1^|2^|3^>]
ECHO   [/NoWait^|-NoWait] [/NoLogo^|-NoLogo] [/NoAnsi^|-NoAnsi] [/h^|-h]
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
ECHO - /NoWait ^| -NoWait
ECHO   ִ�н���ʱ�޵ȴ�.
ECHO.
ECHO - /NoLogo ^| -NoLogo
ECHO   ִ��ǰ����ʾLogo.
ECHO.
ECHO - /NoAnsi ^| -NoAnsi
ECHO   ����ת��������ʾ.
ECHO.
ECHO - /h ^| -h
ECHO   ��ʾ����
ECHO.
GOTO :EOF

::���Menu
::@Outputs
::  STDOUT: �˵�
::  STDERR: ������Ϣ
:SHOW_MENU
CALL :ECHO_WARNING ***** ע��: ������������ƻ�ϵͳ! *****
ECHO.
ECHO 1:���û�������
ECHO 2:�ָ���������
ECHO 3:�˳�
ECHO.
GOTO :EOF

::��ȡ�����ļ�
::@Variables
::  @*, _CONFIG, _EXIT_CODE
::@Arguments
::  %1: �����ļ�·��
::@Outputs
::  %_CONFIG%: ����ʵ��
::  %_EXIT_CODE%: ������
::  STDOUT: ֧��ANSI�Ľ�����Ϣ
::  STDERR: ������Ϣ
::@Returns
::  0: ִ�гɹ�
::  1: ִ��ʧ��
:READ_CONFIGFILE
CALL :ECHO_LIGHT �����ļ�: %~1
CALL Path.GetPath.CMD "%~1"
CD /D "%@%"
CALL Config.FileRead.CMD "_CONFIG" "%~1" || (
  CALL :ECHO_ERROR ***** ����, �����ļ���ȡ����! *****
  SET "_EXIT_CODE=404"
  EXIT /B 1
)
EXIT /B 0

::���Ȩ��
::@Variables
::  @*, _CONFIG, _EXIT_CODE
::@Arguments
::  %_CONFIG%: ����ʵ��
::@Outputs
::  %_EXIT_CODE%: ����ʱ,���������
::  STDERR: ������Ϣ
::@Returns
::  0: ִ�гɹ�
::  1: ִ��ʧ��
:CHECK_PERMISSIONS
IF "%_CONFIG.SCOPE%" == "MACHINE" (
  CALL Common.IsAdmin.CMD || (
    CALL :ECHO_ERROR ***** ����, ��Ҫ����ԱȨ��! *****
    SET "_EXIT_CODE=401"
    EXIT /B 1
  )
)
EXIT /B 0

::���浱ǰ��������
::@Variables
::  @*, _CONFIG, _CONFIG_OLD, _ENV_LIST, _KEY, _EXIT_CODE
::@Arguments
::  %1: �����ļ�·��
::  %_CONFIG%: ����ʵ��
::@Outputs
::  %_EXIT_CODE%: ����ʱ,���������
::  STDOUT: ֧��ANSI�Ľ�����Ϣ
::  STDERR: ������Ϣ
::@Returns
::  0: ִ�гɹ�
::  1: ִ��ʧ��
:BACKUP_ENVIRONMENT
CALL :ECHO_LIGHT ���浱ǰ��������:
CALL Map.New.CMD "_CONFIG_OLD"
::::�˴�չ������
CALL Map.Put.CMD "_CONFIG_OLD" "SCOPE" "%_CONFIG.SCOPE%"
CALL Map.NewChild.CMD "_CONFIG_OLD" "REPLACE"
CALL Map.List.CMD "_CONFIG.REPLACE"
SET "_ENV_LIST=%@%"
CALL Map.List.CMD "_CONFIG.INSERT"
SET "_ENV_LIST=%_ENV_LIST%%@%"
CALL Map.List.CMD "_CONFIG.APPEND"
SET "_ENV_LIST=%_ENV_LIST%%@%"
FOR %%A IN (%_ENV_LIST%) DO (
  ::::�˴�չ������
  CALL SET "_KEY=%%~A"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" || SET "@=(Removed)"
  CALL ECHO %%_KEY%%=%%@%%
  ::::ת�����
  CALL String.Replace.CMD "%%@%%" "%%%%" "%%%%%%%%"
  CALL Map.Put.CMD "_CONFIG_OLD.REPLACE" "%%_KEY%%" "%%@%%"
)
IF EXIST "%~1" DEL /Q /F "%~1" 1>NUL 2>&1
CALL Config.FileWrite.CMD "_CONFIG_OLD" "%~1"
IF NOT EXIST "%~1" (
  CALL :ECHO_ERROR ***** ����, ���滷����������! *****
  SET "_EXIT_CODE=401"
  EXIT /B 1
)
EXIT /B 0

::���»�������
::@Variables
::  @*, _CONFIG, _KEY, _VALUE, _EXIT_CODE
::@Arguments
::  %_CONFIG%: ����ʵ��
::@Outputs
::  %_EXIT_CODE%: ����ʱ,���������
::  STDOUT: ֧��ANSI�Ľ�����Ϣ
::@Returns
::  0: ִ�гɹ�
::  1: ִ��ʧ��
:UPDATE_ENVIRONMENT
CALL :ECHO_LIGHT ���»�������:
CALL Map.List.CMD "_CONFIG.REPLACE"
FOR %%A IN (%@%) DO (
  ::::�˴�չ������
  CALL SET "_KEY=%%~A" & CALL CALL SET "_VALUE=%%_CONFIG.REPLACE.%%~A%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL Process.Callback.CMD IF /I "%%_VALUE%%" == "(Removed)" SET "_VALUE="
  CALL :SETENV
)
CALL Map.List.CMD "_CONFIG.INSERT"
FOR %%A IN (%@%) DO (
  ::::�˴�չ������
  CALL SET "_KEY=%%~A" & CALL CALL SET "_VALUE=%%_CONFIG.INSERT.%%~A%%"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%"
  CALL SET "_VALUE=%%_VALUE%%%%@%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL :SETENV
)
CALL Map.List.CMD "_CONFIG.APPEND"
FOR %%A IN (%@%) DO (
  ::::�˴�չ������
  CALL SET "_KEY=%%~A" & CALL CALL SET "_VALUE=%%_CONFIG.APPEND.%%~A%%"
  CALL Environment.Get.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%"
  CALL SET "_VALUE=%%@%%%%_VALUE%%"
  CALL ECHO %%_KEY%%=%%_VALUE%%
  CALL :SETENV
)
GOTO :EOF

::��ʱ���ñ���
::@Variables
::  *@, _CONFIG, _KEY, _VALUE
::@Arguments
::  %_CONFIG%: ����ʵ��
::  %_KEY%: ��
::  %_VALUE%: ֵ
::@Outputs
::  %%_KEY%%: ��������ʱ, %_KEY%Ϊ��, %_VALUE%Ϊֵ, ���ñ���.
:SETENV
CALL Environment.Set.CMD "%%_CONFIG.SCOPE%%" "%%_KEY%%" "%%_VALUE%%"
IF "%_KEY%" == "" GOTO :EOF
IF /I "%_KEY%" == "PATH" GOTO :EOF
IF "%_KEY:~,1%" == "_" GOTO :EOF
IF "%_KEY:~,1%" == "@" GOTO :EOF
SET "%_KEY%=%_VALUE%"
GOTO :EOF

::��������ı�
::@Arguments
::  %*: �ı�
::@Outputs
::  STDOUT: �����ı�
:ECHO_LIGHT
ECHO.
ECHO %ANSI_LIGHT%%*%ANSI_RESET%
GOTO :EOF

::����ɹ��ı�
::@Arguments
::  %*: �ı�
::@Outputs
::  STDOUT: �ɹ��ı�
:ECHO_SUCCESS
ECHO.
ECHO %ANSI_FG_BRIGHT_GREEN%%*%ANSI_RESET%
GOTO :EOF

::��������ı�
::@Arguments
::  %*: �ı�
::@Outputs
::  STDERR: �����ı�
:ECHO_WARNING
ECHO.
1>&2 ECHO %ANSI_FG_BRIGHT_YELLOW%%*%ANSI_RESET%
GOTO :EOF

::��������ı�
::@Arguments
::  %*: �ı�
::@Outputs
::  STDERR: �����ı�
:ECHO_ERROR
ECHO.
1>&2 ECHO %ANSI_FG_BRIGHT_YELLOW%%ANSI_BG_RED%%*%ANSI_RESET%
GOTO :EOF
