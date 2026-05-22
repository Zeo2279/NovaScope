`timescale 1ns/1ns
// ----------------------------------------------------------------------------
// I2C实时更新集成示例
// 集成自动曝光(AE)算法与CMOS传感器I2C配置接口
// ----------------------------------------------------------------------------
module i2c_realtime_integration_example
#(
    parameter   SYS_CLK_FREQ    =   100_000000,  // 系统时钟频率
    parameter   I2C_FREQ        =   400_000,     // I2C总线频率
    parameter   CMOS_DEVICE_ID  =   8'h6a        // CMOS传感器设备地址
)
(
    // 系统接口
    input                       sys_clk,       // 系统时钟
    input                       sys_rst_n,     // 系统复位，低电平有效
    
    // 控制接口
    input                       start_config,  // 启动初始配置
    input                       update_param,  // 更新参数使能
    input           [15:0]      param_addr,    // 参数寄存器地址
    input           [7:0]       param_data,    // 参数数据
    output                      config_busy,   // 配置忙信号
    output                      config_done,   // 配置完成信号
    
    // I2C物理接口
    output                      I2C_SCLK,      // I2C时钟
    output                      I2C_SDA_O,     // I2C数据输出
    input                       I2C_SDA_I,     // I2C数据输入
    output                      I2C_SDA_OE,    // I2C数据输出使能
    
    // 调试接口
    output  reg     [2:0]       dbg_state,              // 内部状态机状态
    output          [5:0]       dbg_fifo_empty,         // FIFO空标志 (修正位宽)
    output          [5:0]       dbg_fifo_full,          // FIFO满标志 (修正位宽)
    output                      dbg_i2c_write_valid,    // I2C写入有效
    output                      dbg_i2c_write_ready,    // I2C写入就绪
    output          [23:0]      dbg_i2c_write_data,     // I2C写入数据
    output          [1:0]       dbg_i2c_state,          // I2C状态机状态
    output          [8:0]       dbg_config_size,        // 配置数据大小
    output                      dbg_config_valid,       // 配置数据有效
    output                      i2c_transfer_complete   // 新增：I2C传输完成信号
);

// ----------------------------------------------------------------------------
// 内部信号定义
// ----------------------------------------------------------------------------
wire            i2c_sclk_int;
wire            i2c_sdat_in;
wire            i2c_sdat_out;
wire            i2c_sdat_oe;
wire            i2c_write_ready;
reg     [23:0]  i2c_write_data;
reg             i2c_write_valid;
reg             fifo_wr_en;
reg     [23:0]  fifo_wr_data;
wire            fifo_full;
wire            fifo_empty;

// 新增用于连接I2C写入模块调试信号的内部线网
wire                        dbg_afifo_empty_wire;     // FIFO空标志
wire                        dbg_afifo_full_wire;      // FIFO满标志
wire        [23:0]          dbg_config_data_wire;     // 当前配置数据
wire                        dbg_config_done_wire;     // 配置完成脉冲
wire                        dbg_afifo_ren_wire;       // FIFO读使能
// 注意：i2c_transfer_complete已经在模块端口声明，此处不需要重复声明

// 配置状态机信号
localparam  IDLE            =   3'd0;
localparam  INIT_CONFIG     =   3'd1;
localparam  SEND_INIT_DATA  =   3'd2;
localparam  WAIT_INIT_DONE  =   3'd3;
localparam  NORMAL_OP       =   3'd4;
localparam  SEND_REALTIME_DATA = 3'd5;
localparam  WAIT_REALTIME_DONE = 3'd6;

reg     [2:0]   state;
reg     [7:0]   init_config_index;
reg             init_config_done;
reg             update_flag;
reg     [15:0]  update_addr_buf;
reg     [7:0]   update_data_buf;

// ----------------------------------------------------------------------------
// 调试信号连接
// ----------------------------------------------------------------------------
always@(*)begin
 dbg_state = state;
end
assign dbg_fifo_empty = fifo_empty;  // 使用fifo_empty信号
assign dbg_fifo_full = fifo_full;   // 使用fifo_full信号
assign dbg_i2c_write_valid = i2c_write_valid;
assign dbg_i2c_write_ready = i2c_write_ready;
assign dbg_i2c_write_data = i2c_write_data;

// 连接新增的调试信号
assign dbg_afifo_empty = dbg_afifo_empty_wire;
assign dbg_afifo_full = dbg_afifo_full_wire;
assign dbg_config_data = dbg_config_data_wire;
assign dbg_config_done = dbg_config_done_wire;
assign dbg_afifo_ren = dbg_afifo_ren_wire;

// ----------------------------------------------------------------------------
// I2C三态信号处理
// ----------------------------------------------------------------------------
// 移除tri1声明，直接使用输入和输出信号
assign i2c_sdat_in = I2C_SDA_I;
assign I2C_SDA_O = i2c_sdat_out;
assign I2C_SDA_OE = i2c_sdat_oe;
assign I2C_SCLK = i2c_sclk_int;  // 直接输出I2C时钟

// 连接到物理引脚 (时钟信号现在由模块内部产生)
// assign i2c_sclk_int = I2C_SCLK;  // 删除这行，因为我们现在要输出时钟

// ----------------------------------------------------------------------------
// 初始化配置表
// 这里定义了CMOS传感器需要的初始配置参数
// ----------------------------------------------------------------------------
reg [23:0] init_config_table [0:63];  // 最多64个初始化配置项
integer i;
// 在实际应用中，您需要根据所使用的CMOS传感器的数据手册填写这些配置
initial begin

    
    // 其余配置项初始化为0
    for (i = 0; i < 64; i = i + 1) begin
        init_config_table[i] = 24'h000000;
    end
end

// ----------------------------------------------------------------------------
// 配置状态机
// 负责处理初始化配置和实时参数更新
// ----------------------------------------------------------------------------
always @(posedge sys_clk or negedge sys_rst_n)
begin
    if (!sys_rst_n)
    begin
        state               <= IDLE;
        init_config_index   <= 8'd0;
        init_config_done    <= 1'b1;
        update_flag         <= 1'b0;
        update_addr_buf     <= 16'd0;
        update_data_buf     <= 8'd0;
        fifo_wr_en          <= 1'b0;
        fifo_wr_data        <= 24'd0;
    end
    else
    begin
        case(state)
            IDLE:
            begin
                fifo_wr_en <= 1'b0;
                
                if (start_config && !init_config_done)
                begin
                    init_config_index <= 8'd0;
                    state <= INIT_CONFIG;
                end
                else if (init_config_done)
                begin
                    state <= NORMAL_OP;
                end
            end
            
            INIT_CONFIG:
            begin
                // 检查是否所有初始化配置都已发送完成
                if (init_config_table[init_config_index] == 24'h000000 && init_config_index > 0)
                begin
                    init_config_done <= 1'b1;
                    state <= IDLE;
                end
                else
                begin
                    fifo_wr_data <= init_config_table[init_config_index];
                    state <= SEND_INIT_DATA;
                end
            end
            
            SEND_INIT_DATA:
            begin
                if (!fifo_full)
                begin
                    fifo_wr_en <= 1'b1;
                    state <= WAIT_INIT_DONE;
                end
                // 如果FIFO已满，则等待
            end
            
            WAIT_INIT_DONE:
            begin
                fifo_wr_en <= 1'b0;
                
                // 等待数据写入FIFO和I2C传输完成
                if (!fifo_wr_en && i2c_transfer_complete)
                begin
                    init_config_index <= init_config_index + 1'b1;
                    state <= INIT_CONFIG;
                end
            end
            
            NORMAL_OP:
            begin
                fifo_wr_en <= 1'b0;
                
                // 检查是否有实时参数更新请求
                if (update_param && !update_flag)
                begin
                    update_flag <= 1'b1;
                    update_addr_buf <= param_addr;
                    update_data_buf <= param_data;
                    state <= SEND_REALTIME_DATA;
                end
            end
            
            SEND_REALTIME_DATA:
            begin
                if (!fifo_full)
                begin
                    fifo_wr_data <= {update_addr_buf, update_data_buf};
                    fifo_wr_en <= 1'b1;
                    state <= WAIT_REALTIME_DONE;
                end
                // 如果FIFO已满，则等待
            end
            
            WAIT_REALTIME_DONE:
            begin
                fifo_wr_en <= 1'b0;
                
                // 等待数据写入FIFO和I2C传输完成
                if (!fifo_wr_en && i2c_transfer_complete)
                begin
                    update_flag <= 1'b0;
                    state <= NORMAL_OP;
                end
            end
            
            default:
                state <= IDLE;
        endcase
    end
end

// ----------------------------------------------------------------------------
// 数据缓冲FIFO
// 在配置状态机和I2C写入模块之间提供缓冲
// ----------------------------------------------------------------------------
// 注意：这里使用了一个简单的FIFO实现，实际应用中请使用项目中已有的FIFO模块
// 或者根据需要实现一个适合的FIFO
// ----------------------------------------------------------------------------
reg [23:0] buffer_fifo [0:31];  // 32深度的FIFO
reg [4:0]  wr_ptr;
reg [4:0]  rd_ptr;
reg [5:0]  fifo_count;

// 合并的FIFO逻辑（写入和读取）
always @(posedge sys_clk or negedge sys_rst_n)
begin
    if (!sys_rst_n)
    begin
        wr_ptr <= 5'd0;
        rd_ptr <= 5'd0;
        fifo_count <= 6'd0;
        i2c_write_valid <= 1'b0;
        i2c_write_data <= 24'd0;
    end
    else
    begin
        // FIFO写入逻辑
        if (fifo_wr_en && !fifo_full)
        begin
            buffer_fifo[wr_ptr] <= fifo_wr_data;
            wr_ptr <= wr_ptr + 1'b1;
            fifo_count <= fifo_count + 1'b1;
        end
        
        // FIFO读取逻辑
        if (i2c_write_ready && !i2c_write_valid && !fifo_empty)
        begin
            i2c_write_data <= buffer_fifo[rd_ptr];
            i2c_write_valid <= 1'b1;
        end
        else if (i2c_write_valid && i2c_write_ready)
        begin
            i2c_write_valid <= 1'b0;
            rd_ptr <= rd_ptr + 1'b1;
            fifo_count <= fifo_count - 1'b1;
        end
    end
end

assign fifo_full = (fifo_count == 6'd32);
assign fifo_empty = (fifo_count == 6'd0);

// ----------------------------------------------------------------------------
// I2C实时写入模块实例化
// ----------------------------------------------------------------------------
i2c_realtime_writer #(
    .CLK_FREQ        (SYS_CLK_FREQ),
    .I2C_FREQ        (I2C_FREQ),
    .CMOS_DEVICE_ID  (8'h6a)        // CMOS传感器设备地址
)u_i2c_realtime_writer
(
    .clk             (sys_clk),
    .rst_n           (sys_rst_n),
    .realtime_data   (i2c_write_data),
    .data_valid      (i2c_write_valid),
    .data_ready      (i2c_write_ready),
    .i2c_sclk        (i2c_sclk_int),
    .i2c_sdat_IN     (i2c_sdat_in),
    .i2c_sdat_OUT    (i2c_sdat_out),
    .i2c_sdat_OE     (i2c_sdat_oe),
    
    // 调试接口
    .dbg_state               (dbg_i2c_state),
    .dbg_afifo_empty         (dbg_afifo_empty_wire),
    .dbg_afifo_full          (dbg_afifo_full_wire),
    .dbg_config_size         (dbg_config_size),
    .dbg_config_data         (dbg_config_data_wire),
    .dbg_config_valid        (dbg_config_valid),
    .dbg_config_done         (dbg_config_done_wire),
    .dbg_afifo_ren           (dbg_afifo_ren_wire),
    .i2c_transfer_complete   (i2c_transfer_complete)   // 新增：连接传输完成信号
);

// ----------------------------------------------------------------------------
// 输出信号生成
// ----------------------------------------------------------------------------

// 修复config_busy和config_done的逻辑，确保正确的状态指示

reg config_busy_reg;
reg config_done_reg;

// 修改busy和done信号逻辑，使其更好地与外部状态机配合
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        config_busy_reg <= 1'b0;
        config_done_reg <= 1'b0;
    end else begin
        // config_busy在有配置任务时为高，包括初始化和实时更新
        case (state)
            INIT_CONFIG, SEND_INIT_DATA, WAIT_INIT_DONE: 
                config_busy_reg <= 1'b1;
            SEND_REALTIME_DATA, WAIT_REALTIME_DONE:
                config_busy_reg <= 1'b1;
            default:
                config_busy_reg <= 1'b0;
        endcase
        
        // config_done在每次配置任务完成后脉冲式地变为高电平
        if (((state == WAIT_INIT_DONE) && (!fifo_wr_en)) ||
            ((state == WAIT_REALTIME_DONE) && (!fifo_wr_en))) begin
            config_done_reg <= 1'b1;
        end else begin
            config_done_reg <= 1'b0;
        end
    end
end

assign config_busy = config_busy_reg;
assign config_done = config_done_reg;

// ----------------------------------------------------------------------------
// 模块结束
// ----------------------------------------------------------------------------
endmodule

// ----------------------------------------------------------------------------
// 集成示例测试平台
// ----------------------------------------------------------------------------
module i2c_realtime_integration_example_tb;
    
    // 参数定义
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // 信号定义
    reg             sys_clk;
    reg             sys_rst_n;
    reg             start_config;
    reg             update_param;
    reg     [15:0]  param_addr;
    reg     [7:0]   param_data;
    wire            config_busy;
    wire            config_done;
    reg             I2C_SCLK;
    wire            I2C_SDA_O;
    wire            I2C_SDA_I;
    wire            I2C_SDA_OE;
    
    // 模拟I2C从设备的应答信号
    reg             sda_drive_en;
    reg             sda_data;
    
    // 三态总线处理
    assign I2C_SDA_I = sda_drive_en ? sda_data : 1'bz;
    
    // 实例化被测模块
    i2c_realtime_integration_example uut
    (
        .sys_clk        (sys_clk),
        .sys_rst_n      (sys_rst_n),
        .start_config   (start_config),
        .update_param   (update_param),
        .param_addr     (param_addr),
        .param_data     (param_data),
        .config_busy    (config_busy),
        .config_done    (config_done),
        .I2C_SCLK       (I2C_SCLK),
        .I2C_SDA_O      (I2C_SDA_O),
        .I2C_SDA_I      (I2C_SDA_I),
        .I2C_SDA_OE     (I2C_SDA_OE)
    );
    
    // 模拟I2C从设备的响应
    always @(negedge I2C_SCLK)
    begin
        // 检测ACK位位置（每个字节的第9个时钟周期）
        if (sda_drive_en == 1'b0)
        begin
            // 假设在SCLK下降沿后，在第9个时钟周期时拉低SDA表示ACK
            sda_drive_en <= 1'b1;
            sda_data <= 1'b0;  // 发送ACK
        end
        else
        begin
            sda_drive_en <= 1'b0;
        end
    end
    
    // 时钟生成
    initial begin
        sys_clk = 0;
        forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
    end
    
    // 测试序列
    initial begin
        // 初始化
        sys_rst_n = 0;
        start_config = 0;
        update_param = 0;
        param_addr = 16'd0;
        param_data = 8'd0;
        sda_drive_en = 0;
        sda_data = 1;
        
        // 释放复位
        #100 sys_rst_n = 1;
        
        // 等待系统稳定
        #1000;
        
        // 启动初始化配置
        start_config = 1;
        #20 start_config = 0;
        
        // 等待初始化完成
        wait(config_done);
        #1000;
        
        // 执行实时参数更新 - 更新曝光参数
        #500000;
        param_addr = 16'h0004;
        param_data = 8'h10;
        update_param = 1;
        #20 update_param = 0;
        
        // 执行另一个实时参数更新 - 更新增益参数
        #500000;
        param_addr = 16'h0005;
        param_data = 8'h20;
        update_param = 1;
        #20 update_param = 0;
        
        // 结束测试
        #1000000 $stop;
    end
    
    // 监控I2C信号
    initial begin
        $monitor("Time: %t, SCLK: %b, SDA_O: %b, SDA_I: %b, SDA_OE: %b, Busy: %b, Done: %b", 
                 $time, I2C_SCLK, I2C_SDA_O, I2C_SDA_I, I2C_SDA_OE, config_busy, config_done);
    end
    
endmodule