module uart_scope
(
    input               sys_rst_n,
    input               sys_clk,
    
    input               uart_rx_flag,
    input [7:0]         uart_rx_data,
    
    output reg          ae_enable,          // AE算法使能
    output reg          color_correction_enable,  // 颜色矫正使能
    output reg          median_filter_enable,     // 中值滤波使能
    output reg          extinction_enable,        // 消光算法使能
    output reg          sharpen_enable,           // 锐化使能
    output reg [1:0]    model_select,             // 滤波模式选择
    output reg [7:0]    scale_level               // 曝光参数调节
);

reg [3:0]   rx_data_cnt;
reg [7:0]   temp_data;
reg [3:0]   prev_state;  // 保存之前的状态

// UART数据解析状态机
always@(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        ae_enable <= 1'b1;
        color_correction_enable <= 1'b1;
        median_filter_enable <= 1'b1;
        extinction_enable <= 1'b1;
        sharpen_enable <= 1'b1;
        model_select <= 2'b00;
        scale_level <= 8'd50;
        rx_data_cnt <= 4'd0;
        temp_data <= 8'd0;
        prev_state <= 4'd0;
    end
    
    // 状态0-1：发送报头检测
    else if (rx_data_cnt == 4'd0 && uart_rx_flag) begin // 报头检测0
        if(uart_rx_data == 8'd170) begin // 0xAA
            rx_data_cnt <= 4'd1;
        end else begin
            rx_data_cnt <= 4'd0;
        end
    end
    
    else if (rx_data_cnt == 4'd1 && uart_rx_flag) begin // 报头检测1
        if(uart_rx_data == 8'd85) begin // 0x55
            rx_data_cnt <= 4'd2;
        end else begin
            rx_data_cnt <= 4'd0;
        end
    end
    
    // 状态2：根据接收的数据决定执行哪种操作
    else if (rx_data_cnt == 4'd2 && uart_rx_flag) begin
        if(uart_rx_data == 8'hCF) begin // AE算法控制
            rx_data_cnt <= 4'd3;
        end else if(uart_rx_data == 8'h3F) begin // 颜色矫正控制
            rx_data_cnt <= 4'd4;
        end else if(uart_rx_data == 8'hAF) begin // 中值滤波控制
            rx_data_cnt <= 4'd6;
        end else if(uart_rx_data == 8'h9F) begin // 消光算法控制
            rx_data_cnt <= 4'd8;
        end else if(uart_rx_data == 8'h5F) begin // 锐化控制
            rx_data_cnt <= 4'd10;
        end else if(uart_rx_data == 8'h6F) begin // 缩放控制
            rx_data_cnt <= 4'd12;
        end else if(uart_rx_data == 8'hDF) begin // 滤波模式控制
            rx_data_cnt <= 4'd13;
        end else if(uart_rx_data == 8'hBF) begin // 结束状态
            rx_data_cnt <= 4'd14;
        end else begin
            rx_data_cnt <= 4'd0; // 无效命令，重新开始
        end
    end
    
    // 状态3：AE算法开关控制
    else if (rx_data_cnt == 4'd3 && uart_rx_flag) begin
        ae_enable <= uart_rx_data[0];
        rx_data_cnt <= 4'd0; // 返回命令接收状态
    end
    
    // 状态4：颜色矫正开关控制
    else if (rx_data_cnt == 4'd4 && uart_rx_flag) begin
        color_correction_enable <= uart_rx_data[0];
        rx_data_cnt <= 4'd0; // 返回命令接收状态
    end
    
    // 状态6：中值滤波开关控制
    else if (rx_data_cnt == 4'd6 && uart_rx_flag) begin
        median_filter_enable <= uart_rx_data[0];
        rx_data_cnt <= 4'd0; // 返回命令接收状态
    end
    
    // 状态8：消光算法开关控制
    else if (rx_data_cnt == 4'd8 && uart_rx_flag) begin
        extinction_enable <= uart_rx_data[0];
        rx_data_cnt <= 4'd0; // 返回命令接收状态
    end
    
    // 状态10：锐化开关控制
    else if (rx_data_cnt == 4'd10 && uart_rx_flag) begin
        sharpen_enable <= uart_rx_data[0];
        rx_data_cnt <= 4'd0; // 返回命令接收状态
    end
    
    // 状态12：缩放开关控制
    else if (rx_data_cnt == 4'd12 && uart_rx_flag) begin
        scale_level <= uart_rx_data[7:0];
        rx_data_cnt <= 4'd0; // 返回命令接收状态
    end

    // 状态13：滤波模式控制
    else if (rx_data_cnt == 4'd13 && uart_rx_flag) begin
        model_select <= uart_rx_data[1:0];
        rx_data_cnt <= 4'd0; // 返回命令接收状态
    end
    
    // 状态14：结束状态，关闭所有算法
    else if (rx_data_cnt == 4'd14 && uart_rx_flag) begin
        ae_enable <= 1'b1;
        color_correction_enable <= 1'b1;
        median_filter_enable <= 1'b1;
        extinction_enable <= 1'b1;
        sharpen_enable <= 1'b1;
        model_select <= 2'b00;
        scale_level <= 8'd50;
        rx_data_cnt <= 4'd0;
        temp_data <= 8'd0;
        prev_state <= 4'd0;
    end
    
    else begin
        // 保持当前状态
    end
    
    
end

endmodule