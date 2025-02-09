# 更新历史

## 1.1.0 / 2024-10-01

- feat: 增加 Ansi 显示支持
- feat: 增加 NoLogo 和 NoWait 和 NoAnsi 功能
- perf: 优化代码结构

## 1.0.2 / 2024-02-07

- fix: 修复合并单文件兼容性
- fix: 修复参数无法处理相对路径问题

## 1.0.1 / 2024-01-07

- feat: 增加需要管理员权限提示
- perf: 升级 Script 工具脚本
- docs: 规定配置文件编码

## 1.0.0 / 2023-12-30

发布 1.0.0 正式版

## 0.3.1 / 2023-12-29

- 切换回 REG.EXE 方式设置环境变量

  PowerShell 的设置环境变量方式存在问题, [Environment]::GetEnvironmentVariable 无法控制变量展开, [Environment]::SetEnvironmentVariable 无法控制 REG_SZ 和 REG_EXPAND_SZ 类型.

- 排除冲突的变量名

  变量名`PATH`和`_*`和`@*`, 可以设置环境变量, 但后续不可作为变量使用.

## 0.3.0 / 2023-12-28

- 支持执行顺序, 环境变量名后续可以作为变量使用

## 0.2.3 / 2023-12-26

- 增加`;`注释符
- 修改 CONFIG 为 MAP 数据结构
- 备份文件与配置文件顺序相同
- 重新整理 Script 脚本调用

## 0.2.0 / 2023-12-24

- 设置工作目录为配置文件所在目录
- 改换为 Powershell 方式设置环境变量
- 变量前加`_`, 避免`FOR /F`变量名冲突
- 修正特殊字符方面 Bug.

## 0.1.0 / 2023-12-22

初始版本.
