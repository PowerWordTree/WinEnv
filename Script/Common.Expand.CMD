::@author FB
::@version 0.1.0

::չ������
::  ����1: �����������ַ���
::  ����@: չ������ַ���

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL
SET "@STR=%~1"
FOR /F "usebackq delims=" %%A IN (
  `Powershell.EXE -Command "& { [Environment]::ExpandEnvironmentVariables(${Env:@STR}) }"`
) DO (
  SET "@=%%~A"
)
ENDLOCAL & SET "@=%@%"
EXIT /B