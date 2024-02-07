::@author FB
::@version 0.1.0

::转义Powershell命令:
:: ^ ^^  | ^|  & ^&  < ^<  > ^>  % %%  " """  ` ^`  , ^,  ; ^;  = ^=  ( ^(  ) ^)

::展开变量
::  参数1: 包含变量的字符串
::    仅支持能在单个参数传递的字符串.
::  参数2: 变量名(可选)
::    如果参数1为`-`时, 则参数2为保存字符串的变量名.
::  返回@: 展开后的字符串

::Script:Common.Clone.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF "%~1" == "-" (CALL Common.Clone.CMD "%~2" "@") ELSE (SET "@=%~1")
FOR /F "usebackq delims=" %%A IN (
  `Powershell.exe -NonInteractive -Command ^^^& {
    $ErrorActionPreference ^= 'SilentlyContinue'^;
    [Environment]::ExpandEnvironmentVariables^(${Env:@}^)^;
  }`
) DO (
  SET "@=%%A"
)
EXIT /B
