module vip_gray_median_filter(
    //时钟
    input       clk_sys,  //50MHz
    input       rst_sys,
    
    //处理前图像数据
    input       pre_frame_vsync,  //处理前图像数据场信号
    input       pre_frame_href,   //处理前图像数据行信号 
    input       pre_frame_clken,  //处理前图像数据输入使能效信号
    input [7:0] pre_img_y,        //灰度数据
    input [7:0] pre_img_u,        //U分量
    input [7:0] pre_img_v,        //V分量             
    
    //处理后的图像数据
    output       pos_frame_vsync, //处理后的图像数据场信号   
    output       pos_frame_href,  //处理后的图像数据行信号  
    output       pos_frame_clken, //处理后的图像数据输出使能效信号
    output [7:0] pos_img_y,       //处理后的灰度数据
    output [7:0] pos_img_u,      //处理后的U分量
    output [7:0] pos_img_v       //处理后的V分量           
);

//wire define
wire        matrix_frame_vsync;
wire        matrix_frame_href;
wire        matrix_frame_clken;
wire [7:0]  matrix_p11; //3X3 阵列输出
wire [7:0]  matrix_p12; 
wire [7:0]  matrix_p13;
wire [7:0]  matrix_p21; 
wire [7:0]  matrix_p22; 
wire [7:0]  matrix_p23;
wire [7:0]  matrix_p31; 
wire [7:0]  matrix_p32; 
wire [7:0]  matrix_p33;
wire [7:0]  mid_value;

//*****************************************************
//**                    main code
//*****************************************************
//在延迟后的行信号有效，将中值赋给灰度输出值
assign pos_img_y = pos_frame_href ? mid_value : 8'd0;

VIP_Matrix_Generate_3X3_8Bit#(.IMG_HDISP(1280), .IMG_VDISP(720)) u_vip_matrix_generate_3x3_8bit(
    .clk       (clk_sys), 
    .rst_n      (~rst_sys),
    
    //处理前图像数据
    .per_frame_vsync    (pre_frame_vsync),
    .per_frame_href     (pre_frame_href), 
    .per_frame_hsync    (pre_frame_clken),
    .per_img_Y          (pre_img_y),
    
    //处理后的图像数据
    .matrix_frame_vsync (matrix_frame_vsync),
    .matrix_frame_href  (matrix_frame_href),
    .matrix_frame_hsync (matrix_frame_clken),
    .matrix_p11         (matrix_p11),    
    .matrix_p12         (matrix_p12),    
    .matrix_p13         (matrix_p13),
    .matrix_p21         (matrix_p21),    
    .matrix_p22         (matrix_p22),    
    .matrix_p23         (matrix_p23),
    .matrix_p31         (matrix_p31),    
    .matrix_p32         (matrix_p32),    
    .matrix_p33         (matrix_p33)
);

//3x3阵列的中值滤波，需要3个时钟
median_filter_3x3 u_median_filter_3x3_1(
    .clk        (clk_sys),
    .rst_n      (~rst_sys),
    
    .median_frame_vsync (matrix_frame_vsync),
    .median_frame_href  (matrix_frame_href),
    .median_frame_clken (matrix_frame_clken),
    
    //第一行
    .data11           (matrix_p11), 
    .data12           (matrix_p12), 
    .data13           (matrix_p13),
    //第二行              
    .data21           (matrix_p21), 
    .data22           (matrix_p22), 
    .data23           (matrix_p23),
    //第三行              
    .data31           (matrix_p31), 
    .data32           (matrix_p32), 
    .data33           (matrix_p33),
    
    .pos_median_vsync (pos_frame_vsync),
    .pos_median_href  (pos_frame_href),
    .pos_median_clken (pos_frame_clken),
    .target_data      (mid_value)
);

reg [7:0] pre_frame_img_u [4:0];
reg [7:0] pre_frame_img_v [4:0];

always@(posedge clk_sys) begin
    pre_frame_img_u[4] <= pre_frame_img_u[3];
    pre_frame_img_u[3] <= pre_frame_img_u[2];
    pre_frame_img_u[2] <= pre_frame_img_u[1];
    pre_frame_img_u[1] <= pre_frame_img_u[0];
    pre_frame_img_u[0] <= pre_img_u;

    pre_frame_img_v[4] <= pre_frame_img_v[3];
    pre_frame_img_v[3] <= pre_frame_img_v[2];
    pre_frame_img_v[2] <= pre_frame_img_v[1];
    pre_frame_img_v[1] <= pre_frame_img_v[0];
    pre_frame_img_v[0] <= pre_img_v;
end

assign pos_img_u =pos_frame_href?pre_frame_img_u[4]:8'd0;
assign pos_img_v =pos_frame_href?pre_frame_img_v[4]:8'd0;

endmodule 