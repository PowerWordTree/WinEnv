# 运行环境设置

批量添加 Windows 环境变量的工具.

根据配置文件, 对 Windows 环境变量进行设置, 当前工作目录为配置文件所在目录.

## 配置文件

配置文件为非标准 INI 格式, 不支持行尾注释.

默认配置文件名与脚本同名但扩展名不同, 配置文件扩展名`.ini`, 备份文件扩展名`.old`.

### 格式

- 注释行(comment)

  以`#`或者`;`开头的行.

- 无效行(invalid)

  不含`=`或者键值为空.

- 段(section)

  以`[]`包裹的行.

- 键(key)

  行第一个`=`左边的字符串.

- 值(value)

  行第一个`=`右边的字符串.

### 内容

- 作用域(SCOPE)

  段外键值, 键`SCOPE`, 可选值`MACHINE`或者`USER`, 默认值`USER`. 明确定义作用域范围, `MACHINE`为全局, `USER`为用户.

- 替换(REPLACE)

  段名`REPLACE`, 段内定义多个键值. 键为环境变量名称, 值为环境变量内容. 值会替换环境变量, 可以使用`(Removed)`占位符表示删除环境变量.

- 插入(INSERT)

  段名`INSERT`, 段内定义多个键值. 键为环境变量名称, 值为环境变量内容. 值会插入到环境变量前.

- 追加(APPEND)

  段名`APPEND`, 段内定义多个键值. 键为环境变量名称, 值为环境变量内容. 值会追加到环境变量后.

- 变量和转义

  配置文件中`%`包裹的变量, 在执行时会被展开. 需要保留`%`时, 用`%%`方式进行转义.

### 执行顺序

段执行顺序为: REPLACE -> INSERT -> APPEND

段内执行顺序为配置文件顺序.

执行过程中, 已经设置的环境变量后续可以作为变量使用.

变量名`PATH`和`_*`和`@*`, 可以设置环境变量, 但后续不可作为变量使用.

### 示例

```ini
SCOPE=USER

[REPLACE]
JAVA_HOME=%CD%\JDK11

[INSERT]
PATH=%%POWERSHELL_HOME%%;
```

```ini
SCOPE=MACHINE

[REPLACE]
POWERSHELL_HOME=%CD%\POWERSHELL7

[APPEND]
PATH=;%%JAVA_HOME%%\Bin
```

## 命令行:

命令行: WinEnv.cmd [配置文件[.ini]] [/o|-o <1|2|3>] [/h|-h]

- 配置文件

  指定配置文件路径, 可以省略`.ini`. 备份文件会根据配置文件名生成, 扩展名为`.old`. 默认配置文件`WinEnv.ini`, 默认备份文件`WinEnv.old`.

- `/o` | `-o`

  指定要执行的操作. 必选参数, `1`设置环境变量, `2`恢复环境变量, `3`退出. 默认为等待用户选择.

- `/h` | `-h`

  显示帮助

### 示例

```bat
Env.cmd
Env.cmd XXX
Env.cmd XXX.ini
Env.cmd XXX /o 1
Env.cmd XXX.ini /o 2
```
