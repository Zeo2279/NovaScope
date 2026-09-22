# 测试状态

`test.v` 是历史 AE / I²C 仿真激励，包含对 CMOS 更新完成的简化假设，不构成完整的自动回归。原 `i2c_wave.do` 内容是波形文本日志而非可执行 ModelSim 命令，已停止跟踪，原文件仍保留在本地。

其他历史 testbench 位于 `src/axi/axi4_ctrl_tb.v`、`src/dsi/dsi_init_tb.v` 和部分 IP 的 `Testbench/`。厂商 IP 仿真可能需要对应的仿真库及工具授权。

`src/isp/AE/i2c_realtime_integration_example.v` 内同时包含示例和 testbench，依赖仓库缺失的 `i2c_realtime_writer`，不应加入主工程综合或当作已经可运行的示例。

当前可以运行 `python scripts/check_project.py` 做工程文件完整性检查。尚未建立统一的 HDL 仿真命令；本次整理未执行 HDL 仿真或上板测试。
