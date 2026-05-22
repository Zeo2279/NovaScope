module vip_highlight_filter_top(
    //时钟
    input       clk,  //50MHz
    input       rst_n,
    
    //处理前图像数�??
    input       pre_frame_vsync,  //处理前图像数据场信号
    input       pre_frame_href,   //处理前图像数据行信号 
    input       pre_frame_clken,  //处理前图像数据输入使能效信号
    input [7:0] pre_img_y,        //灰度数据        
    input [7:0] pre_img_cb,        //色度数据
    input [7:0] pre_img_cr,        //色调数据
    //处理后的图像数据
    output       pos_frame_vsync, //处理后的图像数据场信�??   
    output       pos_frame_href,  //处理后的图像数据行信�??  
    output       pos_frame_clken, //处理后的图像数据输出使能效信�??
    output [7:0] pos_img_y,        //处理后的灰度数据
    output [7:0] pos_img_cb,        //处理后的色度数据
    output [7:0] pos_img_cr        //处理后的色调数据             
);

wire highlight_flag;

assign highlight_flag = (pre_img_y > 180) ? 1'b1 : 1'b0;

//assign pos_img_y = (highlight_flag) ? (((pre_img_y - 8'b11000000)/4 )+ 8'b11000000):pre_img_y ;

// 直接使用与Cb/Cr通道相同的滤波模块处理Y通道
/*
vip_highlight_filter vip_highlight_filter_y(
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //处理前图像数据
    .pre_frame_vsync (pre_frame_vsync),     // vsync信号
    .pre_frame_href  (pre_frame_href),      // href信号
    .pre_frame_clken (pre_frame_clken),     // data enable信号
    .pre_img_y       (pre_img_y),
    .highlight_flag (highlight_flag),

    //处理后的图像数据
    .pos_frame_vsync (),   // vsync信号
    .pos_frame_href  (),    // href信号
    .pos_frame_clken (),   // data enable信号
    .pos_img_y       (processed_y)
    );
*/
// 在滤波后的Y通道上应用高光处理
reg [7:0]  per_img_y_r [4:0] ;
always @(posedge clk) begin
    per_img_y_r[4] <= per_img_y_r[3];
    per_img_y_r[3] <= per_img_y_r[2];
    per_img_y_r[2] <= per_img_y_r[1];
    per_img_y_r[1] <= per_img_y_r[0];
    per_img_y_r[0] <= pre_img_y;
end
//assign pos_img_y = (highlight_flag) ? (((processed_y - 8'b11000000)/4) + 8'b11000000) : processed_y;
assign pos_img_y =(highlight_flag) ? (((per_img_y_r[4] - 180)/8) + 8'b11000000) : per_img_y_r[4];

vip_highlight_filter vip_highlight_filter1(    
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //处理前图像数�??
    .pre_frame_vsync (pre_frame_vsync),     // vsync信号
    .pre_frame_href  (pre_frame_href),      // href信号
    .pre_frame_clken (pre_frame_clken),     // data enable信号
    .pre_img_y       (pre_img_cb),
    .highlight_flag (highlight_flag),

    //处理后的图像数据
    .pos_frame_vsync (),   // vsync信号
    .pos_frame_href  (),    // href信号
    .pos_frame_clken (),   // data enable信号
    .pos_img_y       (pos_img_cb)
    );
    //assign pos_img_cb=pre_img_cb;
vip_highlight_filter vip_highlight_filter2(
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //处理前图像数�??
    .pre_frame_vsync (pre_frame_vsync),     // vsync信号
    .pre_frame_href  (pre_frame_href),      // href信号
    .pre_frame_clken (pre_frame_clken),     // data enable信号
    .pre_img_y       (pre_img_cr),
    .highlight_flag (highlight_flag),

    //处理后的图像数据
    .pos_frame_vsync (pos_frame_vsync),   // vsync信号
    .pos_frame_href  (pos_frame_href),    // href信号
    .pos_frame_clken (pos_frame_clken),   // data enable信号
    .pos_img_y       (pos_img_cr)
);
//assign pos_img_cr=pre_img_cr;

//assign pos_frame_vsync = pre_frame_vsync;
//assign pos_frame_href = pre_frame_href;
//assign pos_frame_clken = pre_frame_clken;

endmodule