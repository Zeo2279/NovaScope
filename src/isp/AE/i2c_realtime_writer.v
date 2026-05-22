`timescale 1ns/1ns
// ----------------------------------------------------------------------------
// 实时I2C数据写入模块
// 用于向CMOS传感器实时写入寄存器配置数据
// ----------------------------------------------------------------------------
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
    output                      i2c_sdat_OE,   // I2C数据输出使能
    
    // 调试接口
    output      [1:0]           dbg_state,     // 内部状态机状态
    output                      dbg_afifo_empty, // FIFO空标志
    output                      dbg_afifo_full,  // FIFO满标志
    output      [8:0]           dbg_config_size, // 配置数据大小
    output      [31:0]          dbg_config_data, // 配置数据
    output                      dbg_config_valid, // 配置数据有效
    output                      dbg_config_done,  // 配置完成标志
    output                      dbg_afifo_ren,     // FIFO读使能
    output                      i2c_transfer_complete 
);

// ----------------------------------------------------------------------------
// 内部信号定义
// ----------------------------------------------------------------------------
wire            [23:0]          afifo_rdata;   // FIFO读出数据
wire                            afifo_empty;   // FIFO空标志
wire                            afifo_full;    // FIFO满标志
wire                            config_done;   // I2C配置完成标志
reg                             afifo_ren;     // FIFO读使能
reg             [8:0]           config_size;   // 配置数据大小
reg             [31:0]          config_data;   // 配置数据
reg                             config_valid;  // 配置数据有效

// 状态机变量
reg     [1:0]   state;
reg             write_flag;

// ----------------------------------------------------------------------------
// 状态机定义 - 控制FIFO数据读取和I2C写入
// ----------------------------------------------------------------------------
localparam  IDLE            =   2'd0;
localparam  CHECK_FIFO      =   2'd1;
localparam  START_WRITE     =   2'd2;
localparam  WAIT_DONE       =   2'd3;

// ----------------------------------------------------------------------------
// 调试信号连接
// ----------------------------------------------------------------------------
assign dbg_state = state;
assign dbg_afifo_empty = afifo_empty;
assign dbg_afifo_full = afifo_full;
assign dbg_config_size = config_size;
assign dbg_config_data = config_data;
assign dbg_config_valid = config_valid;
assign dbg_config_done = config_done;
assign dbg_afifo_ren = afifo_ren;

// ----------------------------------------------------------------------------
// 异步FIFO实例化 - 用于跨时钟域数据传输
// ----------------------------------------------------------------------------
afifo_w24d16_r24d16 u_afifo_w24d16_r24d16
(
    .full_o                        (afifo_full   ),
    .empty_o                       (afifo_empty  ),
    .wr_clk_i                      (clk          ),
    .rd_clk_i                      (clk          ),
    .wr_en_i                       (data_valid & ~afifo_full), // 防止FIFO溢出
    .rd_en_i                       (afifo_ren    ),
    .wdata                         (realtime_data),
    .rst_busy                      (             ),
    .rdata                         (afifo_rdata  ),
    .a_rst_i                       (~rst_n       ),
    .wr_datacount_o                (             ),
    .rd_datacount_o                (             )
);

// ----------------------------------------------------------------------------
// I2C时序控制模块实例化
// ----------------------------------------------------------------------------
i2c_timing_ctrl_16bit_sp #(
    .CLK_FREQ    (CLK_FREQ),
    .I2C_FREQ    (I2C_FREQ)
)u_i2c_timing_ctrl_16bit
(
    // 全局时钟
    .clk                           (clk          ),
    .rst_n                         (rst_n        ),
    
    // I2C接口
    .i2c_sclk                      (i2c_sclk     ),
    .i2c_sdat_IN                   (i2c_sdat_IN  ),
    .i2c_sdat_OUT                  (i2c_sdat_OUT ),
    .i2c_sdat_OE                   (i2c_sdat_OE  ),
    
    // 用户接口
    .i2c_config_size               (config_size  ),
    .i2c_config_index              (             ),
    .i2c_config_data               (config_data  ),
    .i2c_config_done               (config_done  ),
    
    .config_clk                    (clk          ),
    .config_data                   (afifo_rdata  ),
    .config_data_valid             (config_valid ),
    .i2c_transfer_complete         (i2c_transfer_complete)
);

// ----------------------------------------------------------------------------
// 状态机实现
// ----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state           <= IDLE;
        afifo_ren       <= 1'b0;
        config_size     <= 9'd0;
        config_data     <= 32'd0;
        config_valid    <= 1'b0;
        write_flag      <= 1'b0;
    end
    else
    begin
        case(state)
            IDLE:
            begin
                afifo_ren       <= 1'b0;
                config_valid    <= 1'b0;
                write_flag      <= 1'b0;
                
                if(!afifo_empty && !write_flag)  // FIFO非空且没有正在写入的操作
                    state <= CHECK_FIFO;
                else
                    state <= IDLE;
            end
            
            CHECK_FIFO:
            begin
                afifo_ren   <= 1'b1;  // 读FIFO数据
                state       <= START_WRITE;
            end
            
            START_WRITE:
            begin
                afifo_ren       <= 1'b0;  // 立即清除读使能信号，防止重复读取
                config_size     <= 9'd1;  // 每次只写入一个寄存器
                config_data     <= {8'd0, afifo_rdata};  // 高8位为0，低24位为寄存器地址和数据
                config_valid    <= 1'b1;  // 使能数据写入
                write_flag      <= 1'b1;  // 标记正在写入
                state           <= WAIT_DONE;
            end
            
            WAIT_DONE:
            begin
                // 一旦config_valid被置高，需要等待I2C控制器接受数据后才能清除
                if(config_valid && i2c_transfer_complete) 
                    config_valid <= 1'b0;  // 在I2C控制器完成处理后清除config_valid
                
                // 等待I2C传输完成
                if(i2c_transfer_complete && !config_valid)  // 写入完成且config_valid已清除
                begin
                    write_flag  <= 1'b0;
                    state       <= IDLE;  // 返回空闲状态，准备下一次写入
                end
                else
                    state <= WAIT_DONE;
            end
            
            default:
                state <= IDLE;
        endcase
    end
end

// ----------------------------------------------------------------------------
// 数据就绪信号生成
// ----------------------------------------------------------------------------
assign data_ready = !afifo_full;  // FIFO不满时表示可以接收新数据

// ----------------------------------------------------------------------------
// 模块结束
// ----------------------------------------------------------------------------
endmodule

// ----------------------------------------------------------------------------
// 实时I2C写入测试模块
// ----------------------------------------------------------------------------
module i2c_realtime_writer_tb;
    
    // 参数定义
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // 信号定义
    reg             clk;
    reg             rst_n;
    reg     [23:0]  test_data;
    reg             test_valid;
    wire            test_ready;
    wire            i2c_sclk;
    reg             i2c_sdat_IN;
    wire            i2c_sdat_OUT;
    wire            i2c_sdat_OE;
    
    // 实例化被测模块
    i2c_realtime_writer uut
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .realtime_data  (test_data),
        .data_valid     (test_valid),
        .data_ready     (test_ready),
        .i2c_sclk       (i2c_sclk),
        .i2c_sdat_IN    (i2c_sdat_IN),
        .i2c_sdat_OUT   (i2c_sdat_OUT),
        .i2c_sdat_OE    (i2c_sdat_OE),
        
        // 调试接口
        .dbg_state      ( ),
        .dbg_afifo_empty( ),
        .dbg_afifo_full ( ),
        .dbg_config_size( ),
        .dbg_config_data( ),
        .dbg_config_valid(),
        .dbg_config_done( ),
        .dbg_afifo_ren  ( )
    );
    
    // 模拟I2C从设备的应答信号
    always @(posedge clk)
    begin
        if(i2c_sdat_OE == 1'b0)  // 当主机释放总线时
            i2c_sdat_IN <= 1'b0;  // 发送ACK
        else
            i2c_sdat_IN <= 1'b1;  // 其他时候保持高阻态（上拉）
    end
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // 测试序列
    initial begin
        // 初始化
        rst_n = 0;
        test_data = 24'h000000;
        test_valid = 0;
        
        // 释放复位
        #100 rst_n = 1;
        
        // 等待系统稳定
        #1000;
        
        // 发送测试数据1: 寄存器地址0x0100, 数据0x55
        wait(test_ready);
        #10 test_data = 24'h010055;
        test_valid = 1;
        #20 test_valid = 0;
        
        // 发送测试数据2: 寄存器地址0x0200, 数据0xAA
        #500000;  // 等待上一次写入完成
        wait(test_ready);
        #10 test_data = 24'h0200AA;
        test_valid = 1;
        #20 test_valid = 0;
        
        // 发送测试数据3: 寄存器地址0x0300, 数据0x33
        #500000;
        wait(test_ready);
        #10 test_data = 24'h030033;
        test_valid = 1;
        #20 test_valid = 0;
        
        // 结束测试
        #1000000 $stop;
    end
    
endmodule