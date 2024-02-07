::@author FB
::@version 0.1.0

::转义Powershell命令:
:: ^ ^^  | ^|  & ^&  < ^<  > ^>  % %%  " """  ` ^`  , ^,  ; ^;  = ^=  ( ^(  ) ^)

::回调遍历
::  参数1: 实例名称
::  参数2: 回调命令行
::    仅支持能在单个参数传递的命令行.
::    占位符: {0}键; {1}值;
::  参数3: 变量名
::    如果参数2为`-`时, 则参数3为保存回调命令行的变量名.
::  退出码: 0,执行成功; N,失败次数;

::Script:Common.Clone.CMD::
::Script:Process.Callback.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@=0" & SET "@PREFIX=%~1."
IF "%~2" == "-" (CALL Common.Clone.CMD "%~3" "@CMD") ELSE (SET "@CMD=%~2")
FOR /F "usebackq delims=" %%A IN (
  `Powershell.exe -NonInteractive -Command ^^^& {
    $ErrorActionPreference ^= 'SilentlyContinue'^;
    $Keys ^= ^(Get-Item Env:${Env:@PREFIX}@LIST^).Value^;
    $Keys ^= $Keys.Split^('^;'^, [StringSplitOptions]::RemoveEmptyEntries^)^;
    foreach ^($Key in $Keys^) {
      $Item ^= Get-Item Env:${Env:@PREFIX}$Key^;
      ${Env:@CMD} -f $Key^, $Item.Value^;
    }^;
  }`
) DO (
  SET "@CMD=%%A"
  CALL Process.Callback.CMD - "@CMD" || SET /A "@+=1"
)
SET "@PREFIX=" & SET "@CMD="
EXIT /B %@%
