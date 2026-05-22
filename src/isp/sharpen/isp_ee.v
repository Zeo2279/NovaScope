/*************************************************************************
    > File Name: isp_ee.v
    > Author: bxq
    > Mail: 544177215@qq.com
    > Created Time: Thu 21 Jan 2021 21:50:04 GMT
 ************************************************************************/
`timescale 1 ns / 1 ps

/*
 * ISP - Edge Enhancement
 */

module isp_ee
#(
	parameter BITS = 8,
	parameter WIDTH = 1280,
	parameter HEIGHT = 960
)
(
	input clk_sys,
	input rst_sys,

	input in_href,
	input in_vsync,
	input in_hsync,
	input [BITS-1:0] in_y,
	input [BITS-1:0] in_u,
	input [BITS-1:0] in_v,

	output out_href,
	output out_vsync,
	output out_hsync,
	output [BITS-1:0] out_y,
	output [BITS-1:0] out_u,
	output [BITS-1:0] out_v
);

	// 替换 shift_register 为内部行缓冲器
	reg [BITS-1:0] line_buffer [0:WIDTH*2-1]; // 2行缓冲
	integer i;
	
	always @(posedge clk_sys or negedge rst_sys) begin
		if (!rst_sys) begin
			for (i = 0; i < WIDTH*2; i = i + 1) begin
				line_buffer[i] <= 0;
			end
		end else if (in_href) begin
			// 移位操作
			for (i = WIDTH*2-1; i > 0; i = i - 1) begin
				line_buffer[i] <= line_buffer[i-1];
			end
			line_buffer[0] <= in_y;
		end
	end
	
	// 抽头输出
	wire [BITS-1:0] tap1x = line_buffer[WIDTH*2-1];  // 上一行最后一个像素
	wire [BITS-1:0] tap0x = line_buffer[WIDTH-1];    // 当前行最后一个像素
	wire [BITS-1:0] shiftout = line_buffer[0];       // 输出（实际未使用）
	
	reg [BITS-1:0] in_y_1;
	reg [BITS-1:0] p11,p12,p13;
	reg [BITS-1:0] p21,p22,p23;
	reg [BITS-1:0] p31,p32,p33;
	always @ (posedge clk_sys or negedge rst_sys) begin
		if (!rst_sys) begin
			in_y_1 <= 0;
			p11 <= 0;
			p21 <= 0;
			p31 <= 0;
			p12 <= 0;
			p22 <= 0;
			p32 <= 0;
			p13 <= 0;
			p23 <= 0;
			p33 <= 0;
		end
		else begin
			in_y_1 <= in_y;
			p11 <= p12;
			p21 <= p22;
			p31 <= p32;
			p12 <= p13;
			p22 <= p23;
			p32 <= p33;
			p13 <= tap1x;
			p23 <= tap0x;
			p33 <= in_y_1;
		end
	end

	// filter kernel
	// -1, -1, -1
	// -1, 12, -1
	// -1, -1, -1
	reg signed [BITS-1+5:0] y_core, y_edge;
	always @ (posedge clk_sys or negedge rst_sys) begin
		if (!rst_sys) begin
			y_core <= 0;
			y_edge <= 0;
		end
		else begin
			y_core <= {2'd0, p22, 3'd0} + {3'd0, p22, 2'd0}; // x12
			y_edge <= (({5'd0, p11} + {5'd0, p12}) + ({5'd0, p13} + {5'd0, p21})) + (({5'd0, p23} + {5'd0, p31}) + ({5'd0, p32} + {5'd0, p33}));
		end
	end

	reg signed [BITS-1+6:0] y_data;
	always @ (posedge clk_sys or negedge rst_sys) begin
		if (!rst_sys) begin
			y_data <= 0;
		end
		else begin
			y_data <= y_core - y_edge;
		end
	end

	reg [BITS-1:0] y_data_1;
	always @ (posedge clk_sys or negedge rst_sys) begin
		if (!rst_sys) begin
			y_data_1 <= 0;
		end
		else begin
			y_data_1 <= y_data < 6'sd0 ? {BITS{1'b0}} : (y_data > {BITS+2{1'b1}} ? {BITS{1'b1}} : y_data[BITS-1+2:2]);// 1/4
		end
	end


	localparam DLY_CLK = 6;
	reg [DLY_CLK-1:0] href_dly;
	reg [DLY_CLK-1:0] vsync_dly;
	reg [BITS-1:0] u_dly [DLY_CLK-1:0];
	reg [BITS-1:0] v_dly [DLY_CLK-1:0];
	integer j;
	always @ (posedge clk_sys or negedge rst_sys) begin
		if (!rst_sys) begin
			href_dly <= 0;
			vsync_dly <= 0;
			for (j = 0; j < DLY_CLK; j = j + 1) begin
				u_dly[j] <= 0;
				v_dly[j] <= 0;
			end
		end
		else begin
			href_dly <= {href_dly[DLY_CLK-2:0], in_href};
			vsync_dly <= {vsync_dly[DLY_CLK-2:0], in_vsync};
			u_dly[0] <= in_u;
			v_dly[0] <= in_v;
			for (j = 1; j < DLY_CLK; j = j + 1) begin
				u_dly[j] <= u_dly[j-1];
				v_dly[j] <= v_dly[j-1];
			end
		end
	end
	
	assign out_href = href_dly[DLY_CLK-1];
	assign out_vsync = vsync_dly[DLY_CLK-1];
	assign out_y = out_href ? y_data_1 : {BITS{1'b0}};
	assign out_u = out_href ? u_dly[DLY_CLK-1] : {BITS{1'b0}};
	assign out_v = out_href ? v_dly[DLY_CLK-1] : {BITS{1'b0}};
endmodule