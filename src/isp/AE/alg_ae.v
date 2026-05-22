`timescale 1ns / 1ps

module alg_ae #(
	parameter BITS = 8
)
(
	input pclk,
	input rst_n,

	input in_vsync,
	input stat_done,
	input [BITS-1:0] target_val,
	input [31:0] pix_cnt,
	input [31:0] sum,

	output reg [7:0] dgain,
	
	output reg       cmos_change_start,
	input            cmos_change_done,
	output reg [15:0] cmos_exposure,
	output reg [7:0] cmos_gain
);

	// 内部寄存器
	reg [15:0] target_exposure;
	reg [7:0]  target_gain;
	reg [15:0] new_exposure;
	reg [7:0]  new_gain;
	
	// 增益计算相关寄存器
	reg [35:0] dividend;
	reg [31:0] divisor;
	reg [31:0] gain0;
	
	// 状态控制信号
	reg calc_done;     // 计算完成标志
	reg update_done;   // 更新完成标志
	reg calc_in_progress;
	reg update_in_progress;
	
	// 等待计数器
	reg [10:0] wait_counter;
	localparam WAIT_FRAMES = 2;  // 等待5帧

	// 同步vsync信号
	reg prev_sync;
	always @ (posedge pclk) prev_sync <= in_vsync;
	wire frame_start = ~in_vsync & prev_sync;
	
	// 曝光控制启动信号
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			cmos_change_start <= 0;
		end
		else if (!cmos_change_done) begin
			cmos_change_start <= 0;
		end
		else if (frame_start) begin
			cmos_change_start <= 1;
		end
		else begin
			cmos_change_start <= 0;
		end
	end
	
	// AE算法核心处理逻辑 - 分阶段处理
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			// 初始化寄存器
			target_exposure <= 16'h03E2;  // 初始值约为中值
			target_gain <= 8'h50;         // 初始值约为中值
			new_exposure <= 16'h03E2;
			new_gain <= 8'h50;
			
			// 增益计算相关初始化
			dividend <= 32'd0;
			divisor <= 32'd0;
			gain0 <= 32'd256;  // 增加位宽，使用16位表示增益，基准值为256(相当于原来的16)
			
			// 输出寄存器初始化
			cmos_exposure <= 16'h03E2;
			cmos_gain <= 8'h50;
			dgain <= 8'h50;
			
			// 状态标志初始化
			calc_done <= 1'b0;
			update_done <= 1'b0;
			calc_in_progress <= 1'b0;
			update_in_progress <= 1'b0;
			
			// 等待计数器初始化
			wait_counter <= 0;
		end
		else begin
			if (wait_counter > 0) begin
				// 正在等待阶段，递减计数器
				if (frame_start) begin
					wait_counter <= wait_counter - 1;
				end
			end
			else if (stat_done) begin
				// 第一阶段：执行计算
				
				// 计算增益 (优化增益调节范围)
				dividend = pix_cnt * target_val * 16;  // 乘以16以增加精度
				divisor = sum[31:4];
				
				// 防止除零错误
				if (divisor != 0) begin
					gain0 = dividend / divisor;
				end else begin
					gain0 = 32'd232;  // 默认值，基准值为256
				end
				
				// 限制增益调节范围在±6.25%以内 (0.9375-1.0625倍)，对应增益调整范围240-272
				// 基准值为256，所以限制在240-272之间（比原来更精细）
				if (gain0 < 32'd232)
					gain0 <= 32'd232;
				else if (gain0 > 32'd280)
					gain0 <= 32'd280;
				
				calc_done <= 1'b1;
				calc_in_progress <= 1'b1;
			end
			else if (calc_done && calc_in_progress) begin
				// 第二阶段：更新目标曝光参数
				calc_in_progress <= 1'b0;
				
				// 根据增益计算新的曝光参数
				// 调整策略：需要减少亮度时优先降低增益，需要增加亮度时优先提高曝光时间
				if (gain0 < 32'd240) begin
					// 需要减少亮度
					if (cmos_gain > 8'h00) begin
						// 优先降低增益
						target_gain <= cmos_gain * (gain0+8) / 256;
						target_exposure <= cmos_exposure;
					end else begin
						// 增益已最低，降低曝光时间
						target_exposure <= cmos_exposure * (gain0+8) / 256;
						target_gain <= cmos_gain;
					end
				end else if(gain0 > 32'd272) begin
					// 需要增加亮度
					if (cmos_exposure < 16'h07B0) begin
						// 优先提高曝光时间（保留一些余量）
						if(cmos_exposure < 16'h0010) begin
							target_exposure <= cmos_exposure + 16'h0001;
							target_gain <= cmos_gain;
						end else begin
							// 曝光时间已较高，提高增益
							target_exposure <= cmos_exposure * (gain0-8) / 256;
							target_gain <= cmos_gain;
						end
					end else begin
						if(cmos_gain < 8'h10) begin
							target_gain<= cmos_gain+1;
							target_exposure <= cmos_exposure;
						end
						else begin
							// 曝光时间已较高，提高增益
							target_gain <= cmos_gain * (gain0-8) / 256;
							target_exposure <= cmos_exposure;
						end
					end
				end else begin
					// 亮度在正常范围，保持不变
					target_exposure <= cmos_exposure;
					target_gain <= cmos_gain;
				end
				
				update_done <= 1'b1;
				update_in_progress <= 1'b1;
			end
			else if (update_done && update_in_progress) begin
				// 第三阶段：限制参数范围并更新输出
				update_in_progress <= 1'b0;
				
				// 限制曝光参数范围 (符合0x0008到0x07C0范围要求)
				// 实际曝光时间 = 0x7C4 - cmos_exposure，所以这里需要转换
				if (target_exposure < 16'h0008) 			
					cmos_exposure <= 16'h0008;
				else if (target_exposure > 16'h07B0) 
					cmos_exposure <= 16'h07B0;
				else 
					cmos_exposure <= target_exposure;
					
				// 限制增益参数范围 (符合0x00到0xB4范围要求)
				if (target_gain < 8'h05) 
					cmos_gain <= 8'h05;
				else if (target_gain > 8'hB4) //
					cmos_gain <= 8'hB4;
				else 
				cmos_gain <= target_gain;

				dgain <= gain0 > 32'd255 ? 8'd255 : gain0[15:8];  // 取高8位作为dgain输出
				
				// 设置等待计数器，等待WAIT_FRAMES帧后再开始下一次调节
				wait_counter <= WAIT_FRAMES;
				
				// 清除状态标志
				calc_done <= 1'b0;
				update_done <= 1'b0;
			end
		end
	end

endmodule