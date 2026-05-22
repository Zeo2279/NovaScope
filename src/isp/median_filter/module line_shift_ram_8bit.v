module line_shift_ram_8bit(
    input          clk_sys,   
    input          clken,
    input          pre_frame_href,
    
    input   [7:0]  shiftin,  
    output  [7:0]  taps0x,   
    output  [7:0]  taps1x    
);

//reg define
reg  [2:0]  clken_dly;
reg  [9:0]  ram_rd_addr;
reg  [9:0]  ram_rd_addr_d0;
reg  [9:0]  ram_rd_addr_d1;
reg  [7:0]  shiftin_d0;
reg  [7:0]  shiftin_d1;
reg  [7:0]  shiftin_d2;
reg  [7:0]  taps0x_d0;

// 分布式 RAM
reg [7:0] ram0 [0:1023];
reg [7:0] ram1 [0:1023];
reg [7:0] taps0x_reg;
reg [7:0] taps1x_reg;

assign taps0x = taps0x_reg;
assign taps1x = taps1x_reg;

//*****************************************************
//**                    main code
//*****************************************************

//在数据来到时，ram地址累加
always@(posedge clk_sys)begin
    if(pre_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//时钟使能信号延迟三拍
always@(posedge clk_sys) begin
    clken_dly <= { clken_dly[1:0] , clken };
end

//将ram地址延迟二拍
always@(posedge clk_sys ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
end

//输入数据延迟三拍
always@(posedge clk_sys)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
end

// RAM0 写操作
always @(posedge clk_sys) begin
    if (clken_dly[2]) begin
        ram0[ram_rd_addr_d1] <= shiftin_d2;
    end
end

// RAM0 读操作
always @(posedge clk_sys) begin
    taps0x_reg <= ram0[ram_rd_addr];
end

// 寄存一次前一行图像的数据
always@(posedge clk_sys ) begin
    taps0x_d0 <= taps0x_reg;
end

// RAM1 写操作
always @(posedge clk_sys) begin
    if (clken_dly[1]) begin
        ram1[ram_rd_addr_d0] <= taps0x_d0;
    end
end

// RAM1 读操作
always @(posedge clk_sys) begin
    taps1x_reg <= ram1[ram_rd_addr];
end

endmodule