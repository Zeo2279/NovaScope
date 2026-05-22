# I2C实时写入功能使用指南

本指南将详细介绍如何使用`i2c_realtime_writer`模块，通过I2C协议实时向CMOS传感器写入数据。

## 1. 功能概述

`i2c_realtime_writer`模块是一个专门设计用于FPGA系统中实时向CMOS图像传感器等I2C从设备写入配置数据的解决方案。它具有以下特点：

- 支持实时数据输入和传输
- 通过异步FIFO实现数据缓冲，提高数据传输的可靠性
- 自动处理I2C协议时序，包括起始信号、数据传输、ACK检测和停止信号
- 支持16位寄存器地址和8位数据的写入操作
- 可配置的I2C总线频率

## 2. 系统架构

整个实时I2C写入系统的架构如下图所示：

```
+------------------+      +-------------------+      +------------------+
|  数据生成模块    | ---> | i2c_realtime_writer | ---> | CMOS传感器(I2C) |
|  (数据源)        |      |                   |      |                  |
+------------------+      +-------------------+      +------------------+
                               |          |
                         +-----+          +----+
                         |                     |
                 +--------------+      +--------------+
                 | 异步FIFO      |      | I2C时序控制  |
                 |(afifo_w24d16) |      |(i2c_timing_  |
                 |              |      | ctrl_16bit)  |
                 +--------------+      +--------------+
```

## 3. 模块接口说明

### 3.1 顶层模块接口

`i2c_realtime_writer`模块提供以下接口：

```verilog
module i2c_realtime_writer
#(
    parameter   CLK_FREQ        =   100_000000,  // 系统时钟频率
    parameter   I2C_FREQ        =   400_000,     // I2C总线频率
    parameter   CMOS_DEVICE_ID  =   8'h6a        // CMOS传感器设备地址
)
(
    // 系统接口
    input                       clk,           // 系统时钟
    input                       rst_n,         // 系统复位
    
    // 数据输入接口
    input       [23:0]          realtime_data, // 实时数据输入 (REG_ADDR[15:0] + DATA[7:0])
    input                       data_valid,    // 数据有效信号
    output                      data_ready,    // 数据接收就绪信号
    
    // I2C接口
    output                      i2c_sclk,      // I2C时钟
    input                       i2c_sdat_IN,   // I2C数据输入
    output                      i2c_sdat_OUT,  // I2C数据输出
    output                      i2c_sdat_OE    // I2C数据输出使能
);
```

### 3.2 数据格式说明

`realtime_data`输入的数据格式为24位，具体分配如下：
- 高16位 (`[23:8]`): 寄存器地址
- 低8位 (`[7:0]`): 要写入的数据

例如，要向地址为`0x1234`的寄存器写入数据`0x56`，`realtime_data`应为`0x123456`。

## 4. 使用步骤

### 4.1 1. 实例化模块

首先，在您的顶层设计中实例化`i2c_realtime_writer`模块：

```verilog
// I2C实时写入模块实例化
i2c_realtime_writer u_i2c_realtime_writer
#(
    .CLK_FREQ        (100_000000),  // 系统时钟频率，根据实际情况调整
    .I2C_FREQ        (400_000),     // I2C总线频率，最大不超过400KHz
    .CMOS_DEVICE_ID  (8'h6a)        // CMOS传感器的I2C设备地址
)
(
    .clk             (sys_clk),     // 系统时钟输入
    .rst_n           (sys_rst_n),   // 系统复位输入
    .realtime_data   (i2c_write_data), // 实时写入数据
    .data_valid      (i2c_write_valid),// 写入数据有效信号
    .data_ready      (i2c_write_ready),// 写入就绪信号
    .i2c_sclk        (i2c_sclk),    // I2C时钟输出到传感器
    .i2c_sdat_IN     (i2c_sdat_in), // I2C数据输入（来自传感器）
    .i2c_sdat_OUT    (i2c_sdat_out),// I2C数据输出（到传感器）
    .i2c_sdat_OE     (i2c_sdat_oe)  // I2C数据输出使能
);
```

### 4.2 2. 连接I2C物理接口

需要将模块的I2C信号连接到FPGA的物理引脚上：

```verilog
// I2C信号缓冲和物理引脚连接
tri1 i2c_sdat_io;  // 使用三态信号

assign i2c_sdat_io = i2c_sdat_oe ? i2c_sdat_out : 1'bz;
assign i2c_sdat_in = i2c_sdat_io;

// 将I2C信号连接到FPGA引脚
assign I2C_SCLK = i2c_sclk;
assign I2C_SDA  = i2c_sdat_io;
```

### 4.3 3. 实现数据发送逻辑

在您的数据生成模块中，需要实现以下逻辑来发送数据：

```verilog
// 数据发送状态机示例
reg [23:0] reg_addr_data;  // 寄存器地址和数据
reg send_request;         // 发送请求
reg sending;              // 正在发送标志

always @(posedge sys_clk or negedge sys_rst_n)
if (!sys_rst_n)
begin
    send_request <= 1'b0;
    sending <= 1'b0;
    reg_addr_data <= 24'd0;
end
else
begin
    // 当有新数据需要发送且I2C写入模块就绪时
    if (new_data_available && !sending)
    begin
        reg_addr_data <= {new_reg_addr, new_data};  // 组合地址和数据
        send_request <= 1'b1;
        sending <= 1'b1;
    end
    
    // 当I2C写入模块接收数据后
    if (send_request && i2c_write_ready)
    begin
        send_request <= 1'b0;
    end
    
    // 当数据发送完成时
    if (sending && !send_request && i2c_write_ready)
    begin
        sending <= 1'b0;
        // 可以触发下一次数据准备
    end
end

// 连接到I2C实时写入模块
always @(*) begin
    i2c_write_data = reg_addr_data;
    i2c_write_valid = send_request;
end
```

## 5. 完整集成示例

以下是一个完整的示例，展示如何将`i2c_realtime_writer`模块集成到您的系统中：

```verilog
`timescale 1ns/1ns
module cmos_camera_system
#(
    parameter   CLK_FREQ    =   100_000000
)
(
    // 系统时钟和复位
    input           clk,
    input           rst_n,
    
    // 用户控制接口
    input           start_config,
    output          config_done,
    
    // I2C物理接口
    output          I2C_SCLK,
    inout           I2C_SDA
);
    
    // 内部信号
    wire            i2c_sclk;
    wire            i2c_sdat_IN;
    wire            i2c_sdat_OUT;
    wire            i2c_sdat_OE;
    wire            i2c_write_ready;
    reg     [23:0]  i2c_write_data;
    reg             i2c_write_valid;
    
    // I2C三态信号处理
    tri1            i2c_sdat_io;
    assign i2c_sdat_io = i2c_sdat_OE ? i2c_sdat_OUT : 1'bz;
    assign i2c_sdat_IN = i2c_sdat_io;
    
    // 连接到物理引脚
    assign I2C_SCLK = i2c_sclk;
    assign I2C_SDA = i2c_sdat_io;
    
    // 配置数据FIFO
    reg [4:0]       config_index;
    reg             config_active;
    wire            config_data_ready;
    
    // 预定义的寄存器配置数据（示例）
    reg [23:0]      config_table [0:15];
    
    // 初始化配置表
    initial begin
        config_table[0]  = 24'h010001;  // 寄存器0x0100 = 0x01
        config_table[1]  = 24'h010102;  // 寄存器0x0101 = 0x02
        config_table[2]  = 24'h010203;  // 寄存器0x0102 = 0x03
        // ... 其他配置数据
        config_table[15] = 24'h010F0F;  // 寄存器0x010F = 0x0F
    end
    
    // 配置状态机
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            config_index <= 5'd0;
            config_active <= 1'b0;
            i2c_write_valid <= 1'b0;
        end
        else
        begin
            if (start_config && !config_active)
            begin
                config_index <= 5'd0;
                config_active <= 1'b1;
            end
            
            if (config_active)
            begin
                if (config_index < 5'd16)
                begin
                    if (i2c_write_ready && !i2c_write_valid)
                    begin
                        i2c_write_data <= config_table[config_index];
                        i2c_write_valid <= 1'b1;
                    end
                    else if (i2c_write_valid && i2c_write_ready)
                    begin
                        i2c_write_valid <= 1'b0;
                        config_index <= config_index + 1'b1;
                    end
                end
                else
                begin
                    config_active <= 1'b0;
                end
            end
        end
    end
    
    // 配置完成信号
    assign config_done = config_active && (config_index >= 5'd16);
    
    // I2C实时写入模块实例化
i2c_realtime_writer u_i2c_realtime_writer
#(
    .CLK_FREQ        (CLK_FREQ),
    .I2C_FREQ        (400_000),
    .CMOS_DEVICE_ID  (8'h6a)
)
(
    .clk             (clk),
    .rst_n           (rst_n),
    .realtime_data   (i2c_write_data),
    .data_valid      (i2c_write_valid),
    .data_ready      (i2c_write_ready),
    .i2c_sclk        (i2c_sclk),
    .i2c_sdat_IN     (i2c_sdat_IN),
    .i2c_sdat_OUT    (i2c_sdat_OUT),
    .i2c_sdat_OE     (i2c_sdat_OE)
);
    
endmodule
```

## 6. 性能考量

1. **数据吞吐量**：
   - I2C协议的最大数据传输速率取决于`I2C_FREQ`参数，最大支持400KHz
   - 在400KHz下，每个字节需要约20μs传输时间
   - 每个完整的寄存器写入操作（地址+数据）约需要100μs

2. **FIFO深度**：
   - 当前设计使用的是16深度的FIFO，可以根据实际需求选择更大容量的FIFO
   - 如果数据生成速率高于I2C写入速率，应选择更大容量的FIFO以避免数据丢失

3. **系统时钟**：
   - 模块支持100MHz系统时钟，也可以根据实际情况调整
   - 系统时钟与I2C时钟的比率会影响时序精度，建议保持足够大的比率

## 7. 调试技巧

1. **使用信号Tap或逻辑分析仪**：
   - 监控`i2c_sclk`和`i2c_sdat`信号，验证I2C时序是否正确
   - 观察`data_valid`和`data_ready`信号，确认数据传输流程正常

2. **检查ACK信号**：
   - 确保每次数据传输后都能收到从设备的ACK信号
   - 如果没有收到ACK，可能是设备地址错误或连接问题

3. **逐步测试**：
   - 先测试单个寄存器写入，确保基本功能正常
   - 再测试连续写入多个寄存器
   - 最后测试高频率的实时写入

通过遵循本指南，您可以轻松地在FPGA系统中实现通过I2C协议实时向CMOS传感器写入数据的功能。