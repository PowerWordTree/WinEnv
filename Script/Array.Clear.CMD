::@author FB
::@version 0.1.0

::清空
::  参数1: 实例名称

::Script:Array.Destroy.CMD::
::Script:Array.New.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL Array.Destroy.CMD "%~1"
CALL Array.New.CMD "%~1"
EXIT /B
