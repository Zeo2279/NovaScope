module AWB_top (
    // 输入图像
    input pclk,
    input rst_n,
    input in_href,
    input in_vsync,
    input [7:0] in_r,
    input [7:0] in_g,
    input [7:0] in_b,

    // 输出图像
    output out_href,
    output out_vsync,
    output [7:0] out_r,
    output [7:0] out_g,
    output [7:0] out_b
);

    // 统计模块输出
    wire stat_done;
    wire [31:0] pix_cnt;
    wire [31:0] sum_r, sum_g, sum_b;

    // 增益计算模块输出
    wire [7:0] r_gain, g_gain, b_gain;

    // 固定 min/max 阈值
    localparam MIN_THRESH = 8'd200;
    localparam MAX_THRESH = 8'd240;

    // 实例化统计模块
    isp_stat_awb #(
        .BITS(8),
        .WIDTH(1280),
        .HEIGHT(720),
        .OUT_BITS(32)
    ) u_stat_awb (
        .pclk(pclk),
        .rst_n(rst_n),
        .min(MIN_THRESH),
        .max(MAX_THRESH),
        .in_href(in_href),
        .in_vsync(in_vsync),
        .in_r(in_r),
        .in_g(in_g),
        .in_b(in_b),
        .out_done(stat_done),
        .out_cnt(pix_cnt),
        .out_sum_r(sum_r),
        .out_sum_g(sum_g),
        .out_sum_b(sum_b),
        .hist_clk(pclk),
        .hist_out(),          // 未使用直方图输出
        .hist_addr(),         // 未使用直方图地址
        .hist_data()          // 未使用直方图数据
    );

    // 实例化增益计算模块
    alg_awb #(
        .BITS(8)
    ) u_alg_awb (
        .pclk(pclk),
        .rst_n(rst_n),
        .stat_done(stat_done),
        .pix_cnt(pix_cnt),
        .sum_r(sum_r),
        .sum_g(sum_g),
        .sum_b(sum_b),
        .r_gain(r_gain),
        .g_gain(g_gain),
        .b_gain(b_gain)
    );

    // 实例化增益应用模块
    isp_wb #(
        .BITS(8),
        .WIDTH(1280),
        .HEIGHT(720)
    ) u_isp_wb (
        .pclk(pclk),
        .rst_n(rst_n),
        .gain_r(r_gain),
        .gain_g(g_gain),
        .gain_b(b_gain),
        .in_href(in_href),
        .in_vsync(in_vsync),
        .in_r(in_r),
        .in_g(in_g),
        .in_b(in_b),
        .out_href(out_href),
        .out_vsync(out_vsync),
        .out_r(out_r),
        .out_g(out_g),
        .out_b(out_b)
    );

endmodule