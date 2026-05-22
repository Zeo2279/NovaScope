`timescale 1ns/1ns

module test;

// 时钟和复位信号
reg clk;
reg rst_n;

// 图像输入信号
reg         crop_vsync;
reg         crop_valid;
reg  [7:0]  crop_data;

// AE模块输出信号
wire ae_done;
wire [31:0] ae_cnt;
wire [31:0] ae_sum;
wire [15:0] cmos_exposure;
wire [7:0]  cmos_gain;
wire [7:0]  dgain;
wire cmos_change_start;
wire cmos_change_done = 1'b1; // 假设CMOS变化立即完成

// I2C相关信号
reg start_config; // 启动配置，在系统复位后延时触发
reg update_param;
reg [15:0] param_addr;
reg [7:0] param_data;
wire config_busy;
wire config_done;
wire i2c_transfer_complete; // 新增：I2C单次传输完成信号

// I2C物理接口
wire  i2c_scl;     // I2C时钟应为线网类型，由I2C模块驱动
wire i2c_sda_o;
wire i2c_sda_oe;
reg  i2c_sda_i = 1'b1;  // I2C数据输入，初始化为高电平

// 用于处理I2C总线的非三态逻辑
wire i2c_sda_internal;

// I2C传输完成信号，从模块实例中获取
// 注意：i2c_transfer_complete已经在模块实例连接中声明，此处不需要重复声明

// 时钟生成
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz时钟
end

// 复位生成
initial begin
    rst_n = 0;
    start_config = 0;
    #100 rst_n = 1;
    #1000 start_config = 1;
    #20 start_config = 0;
end

// 模拟图像输入数据
initial begin
    crop_vsync = 0;
    crop_valid = 0;
    crop_data = 0;
    
    #200;
    
    // 模拟多帧图像数据 (符合1280x720分辨率)
    repeat(3) begin
        // 帧开始 - vsync拉高表示帧开始
        crop_vsync = 1;
        #20;
        crop_vsync = 0;
        
        // 帧有效期内传输图像数据（vsync在整个帧有效期内保持低电平）
        repeat(720) begin
            // 行开始 - valid拉高表示行开始
            crop_valid = 1;
            
            // 模拟1280个像素数据
            repeat(1280) begin
                crop_data = $random % 56+200;
                #10;
            end
            
            // 行结束 - valid拉低表示行结束
            crop_valid = 0;
            #10;
        end
        
        // 帧结束后的间隔
        #100;
    end
end

// 模拟I2C从设备ACK响应 - 使用非三态逻辑
reg [3:0] sda_cnt = 0;
reg [3:0] bit_cnt = 0;
reg sda_drive = 0;
reg i2c_prev_scl = 0;
reg sda_data = 1'b1;
reg prev_sda_oe = 0;
reg prev_sda_o = 1'b1;

// 检测SCL的上升沿
always @(posedge clk) begin
    i2c_prev_scl <= i2c_scl;
    prev_sda_oe <= i2c_sda_oe;
    prev_sda_o <= i2c_sda_o;
end

// 改进的I2C SDA总线逻辑 - 确保无冲突驱动
// 使用时序逻辑而非组合逻辑来驱动i2c_sda_i
// 优先级：测试平台ACK驱动 > I2C控制器输出 > 默认高电平
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_sda_i <= 1'b1;
    end else begin
        if (sda_drive) begin
            i2c_sda_i <= sda_data;
        end else if (i2c_sda_oe) begin
            i2c_sda_i <= i2c_sda_o;
        end else begin
            i2c_sda_i <= 1'b1;  // 默认上拉
        end
    end
end

// 修复ACK响应逻辑，确保精确的时序控制
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sda_cnt <= 0;
        bit_cnt <= 0;
        sda_drive <= 0;
        sda_data <= 1'b1;
    end else begin
        // 检测SDA_OE的上升沿，表示开始新的传输
        if (i2c_sda_oe && !prev_sda_oe) begin
            sda_cnt <= 0;
            bit_cnt <= 0;
        end
        
        // 检测SCL的上升沿，确保稳定的时钟检测
        if (i2c_scl && !i2c_prev_scl) begin
            // 在每个字节的第9个时钟周期发送ACK（计数从0开始，所以是第8个时钟）
            if (bit_cnt == 8) begin
                sda_drive <= 1'b1;
                sda_data <= 1'b0; // 发送ACK
                bit_cnt <= bit_cnt + 1;
            end else if (bit_cnt == 9) begin
                sda_drive <= 1'b0; // 停止驱动，释放总线
                sda_data <= 1'b1;
                bit_cnt <= 0;
                sda_cnt <= sda_cnt + 1;
            end else begin
                bit_cnt <= bit_cnt + 1;
            end
        end
        
        // 当SDA_OE变为低电平时，确保释放总线驱动
        if (!i2c_sda_oe && prev_sda_oe) begin
            sda_drive <= 1'b0;
        end
    end
end

// 实例化AE统计模块
isp_stat_ae #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0) // 0:RGGB
) u_isp_stat_ae (
    .pclk(clk),
    .rst_n(rst_n),
    
    // 设置统计区域为整个图像
    .rect_x(12'd0),
    .rect_y(12'd0),
    .rect_w(12'd1280),
    .rect_h(12'd720),
    
    .in_href(crop_valid),
    .in_vsync(crop_vsync),
    .in_raw(crop_data),
    
    .out_done(ae_done),
    .out_cnt(ae_cnt),
    .out_sum(ae_sum),
    
    // 直方图接口(未使用)
    .hist_clk(1'b0),
    .hist_out(1'b0),
    .hist_addr(12'b0),
    .hist_data()
);

// 实例化AE算法模块
alg_ae #(
    .BITS(8)
) u_alg_ae (
    .pclk(clk),
    .rst_n(rst_n),
    
    .in_vsync(crop_vsync),
    .stat_done(ae_done),
    .target_val(8'd128),  // 目标亮度值设为128
    .pix_cnt(ae_cnt),
    .sum(ae_sum),
    
    .dgain(dgain),
    .cmos_change_start(cmos_change_start),
    .cmos_change_done(cmos_change_done),
    .cmos_exposure(cmos_exposure),
    .cmos_gain(cmos_gain)
);

// 曝光值拆分：根据规范，16位曝光值需要分别写入两个寄存器地址
// 低八位地址: 0x3048，高八位地址: 0x3049
// 增益控制寄存器地址: 0x3110
wire [15:0] ae_exposure = cmos_exposure;
wire [7:0] ae_gain = cmos_gain;

// 定义寄存器地址
localparam EXPOSURE_LOW_ADDR  = 16'h3048;  // 曝光值低8位寄存器地址
localparam EXPOSURE_HIGH_ADDR = 16'h3049;  // 曝光值高8位寄存器地址
localparam GAIN_ADDR          = 16'h3110;  // 增益寄存器地址

// 用于存储需要更新的参数信息
reg [15:0] update_addr;
reg [7:0]  update_data;
reg        update_valid;

// 状态机用于依次更新曝光和增益参数
localparam UPDATE_IDLE    = 2'd0;
localparam UPDATE_EXP_LOW = 2'd1;
localparam UPDATE_EXP_HIGH= 2'd2;
localparam UPDATE_GAIN    = 2'd3;

reg [1:0] update_state;
reg cmos_change_start_dly;
reg i2c_transfer_complete_dly;
reg update_state_set_data; // 标记是否已设置地址和数据

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        update_state <= UPDATE_IDLE;
        update_valid <= 1'b0;
        update_addr  <= 16'd0;
        update_data  <= 8'd0;
        cmos_change_start_dly <= 1'b0;
        i2c_transfer_complete_dly <= 1'b0;
        update_state_set_data <= 1'b0;
    end else begin
        cmos_change_start_dly <= cmos_change_start;
        i2c_transfer_complete_dly <= i2c_transfer_complete;
        
        case (update_state)
            UPDATE_IDLE: begin
                update_valid <= 1'b0;
                update_state_set_data <= 1'b0;
                update_data  <= cmos_exposure[7:0];
                update_addr  <= EXPOSURE_LOW_ADDR;
                if (~cmos_change_start & cmos_change_start_dly) begin
                    // 开始更新曝光值低8位
                    update_state <= UPDATE_EXP_LOW;
                end
            end
            
            UPDATE_EXP_LOW: begin
                // 等待配置完成后再进入下一步
                update_valid <= 1'b1;
                update_state_set_data <= 1'b1;
                if ((i2c_transfer_complete && !i2c_transfer_complete_dly)) begin
                    update_valid <= 1'b0; // 清除valid信号
                    update_state <= UPDATE_EXP_HIGH;
                    update_state_set_data <= 1'b0;
                end
            end
            
            UPDATE_EXP_HIGH: begin
                // 在进入此状态时设置地址和数据
                if (!update_state_set_data) begin
                    update_addr  <= EXPOSURE_HIGH_ADDR;
                    update_data  <= cmos_exposure[15:8];
                    update_valid <= 1'b1;
                    update_state_set_data <= 1'b1;
                end 
                // 等待配置完成后再进入下一步
                if ((i2c_transfer_complete && !i2c_transfer_complete_dly)) begin
                    update_valid <= 1'b0; // 清除valid信号
                    update_state <= UPDATE_GAIN;
                    update_state_set_data <= 1'b0;
                end
            end
            
            UPDATE_GAIN: begin
                // 在进入此状态时设置地址和数据
                if (!update_state_set_data) begin
                    update_addr  <= GAIN_ADDR;
                    update_data  <= cmos_gain;
                    update_valid <= 1'b1;
                    update_state_set_data <= 1'b1;
                end else begin
                    update_valid <= 1'b0; // 清除valid信号
                end
                // 等待配置完成后再进入下一步
                if ((i2c_transfer_complete && !i2c_transfer_complete_dly)) begin
                    //update_valid <= 1'b0; // 清除valid信号
                    update_state <= UPDATE_IDLE;
                    update_state_set_data <= 1'b0;
                end
            end
        endcase
    end
end

// 实例化集成的I2C实时更新模块，用于AE参数更新
wire [2:0] dbg_state;
wire dbg_fifo_empty;
wire dbg_fifo_full;
wire dbg_i2c_write_valid;
wire dbg_i2c_write_ready;
wire [23:0] dbg_i2c_write_data;
wire [1:0] dbg_i2c_state;
wire [8:0] dbg_config_size;
wire dbg_config_valid;

// i2c_transfer_complete信号已在文件开头声明，此处无需重复声明

// 添加i2c_timing_ctrl_16bit_sp模块实例
i2c_timing_ctrl_16bit #(
    .CLK_FREQ(100_000_000),  // 系统时钟频率100MHz
    .I2C_FREQ(400_000)       // I2C频率400KHz
) u_i2c_timing_ctrl_16bit_sp (
    .clk(clk),
    .rst_n(rst_n),
    .i2c_sclk(i2c_scl),
    .i2c_sdat_IN(i2c_sda_i),
    .i2c_sdat_OUT(i2c_sda_o),
    .i2c_sdat_OE(i2c_sda_oe),
    .i2c_config_size(9'd1),         // 每次只写入一个寄存器
    .i2c_config_index(),            // 未使用
    .i2c_config_data({8'd0, update_addr, update_data}),  // 32位配置数据: 8位保留 + 16位地址 + 8位数据
    .i2c_config_done(config_done),  // 配置完成信号
    .i2c_transfer_complete(i2c_transfer_complete),
    .config_clk(clk),
    .config_data({8'h6a, update_addr, update_data}),  // 24位配置数据: 8位ID + 16位地址 + 8位数据
    .config_data_valid(update_valid)
);

// 直接连接config_busy到update_valid，表示当update_valid为高时模块处于忙碌状态
assign config_busy = update_valid;

initial begin
    $monitor("Time: %0t, i2c_sda_o: %d, i2c_sda_i: %d, i2c_sda_oe: %b,i2c_scl: %b", 
             $time, i2c_sda_o, i2c_sda_i, i2c_sda_oe,i2c_scl);
end

// I2C数据线的三态行为由I2C控制器和从设备共同驱动
// 从设备在ACK周期驱动i2c_sda_i为低电平
// 注意：此处应确保i2c_sda_i为reg类型且只在特定条件下赋值

// 仿真结束条件
initial begin
    #100000000 $finish;
end

endmodule