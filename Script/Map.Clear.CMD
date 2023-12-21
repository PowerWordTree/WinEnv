::@author FB
::@version 0.1.0

::清空
::  参数1: 实例名称

::Script:Map.Destroy.CMD::
::Script:Map.New.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL Map.Destroy.CMD "%~1"
CALL Map.New.CMD "%~1"
EXIT /B
