::@author FB
::@version 0.1.0

::使用Powershell方式, 执行非常慢, 但兼容性非常好.

::字符串替换
::  参数1: 字符串
::  参数2: 旧字符串
::  参数3: 新字符串
::  返回@: 字符串

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL
SET "@STR=%~1" & SET "@OLD=%~2" & SET "@NEW=%~3" & SET "@="
FOR /F "usebackq delims=" %%A IN (
  `Powershell.EXE -Command "& { ${Env:@STR} -Replace [Regex]::Escape(${Env:@OLD}),${Env:@NEW} }"`
) DO (
  SET "@=%%~A"
)
ENDLOCAL & SET "@=%@%"
EXIT /B
