module vip_highlight_filter(
    //ʱ��
    input       clk,  //50MHz
    input       rst_n,
    
    //����ǰͼ������
    input       pre_frame_vsync,  //����ǰͼ�����ݳ��ź�
    input       pre_frame_href,   //����ǰͼ���������ź� 
    input       pre_frame_clken,  //����ǰͼ����������ʹ��Ч�ź�
    input [7:0] pre_img_y,        //�Ҷ�����
    input       highlight_flag,       
    
    //�������ͼ������?
    output       pos_frame_vsync, //�������ͼ�����ݳ��ź�?   
    output       pos_frame_href,  //�������ͼ���������ź�?  
    output       pos_frame_clken, //�������ͼ���������ʹ��Ч�ź�
    output [7:0] pos_img_y        //������ĻҶ�����?           
);

//wire define
wire        matrix_frame_vsync;
wire        matrix_frame_href;
wire        matrix_frame_clken;
wire [7:0]  matrix_p11; //3X3 �������?
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
//���ӳٺ�����ź���Ч������ֵ�����Ҷ����ֵ
assign pos_img_y =pos_frame_href&&highlight_flag? mid_value : per_img_y_r[4] ;//
reg [7:0]  per_img_y_r [4:0];
always @(posedge clk) begin
    per_img_y_r[4] <= per_img_y_r[3];
    per_img_y_r[3] <= per_img_y_r[2];
    per_img_y_r[2] <= per_img_y_r[1];
    per_img_y_r[1] <= per_img_y_r[0];
    per_img_y_r[0] <= pre_img_y;
end
VIP_Matrix_Generate_3X3_8Bit #(.IMG_HDISP(1280), .IMG_VDISP(720)) u_vip_matrix_generate_3x3_8bit(
    .clk        (clk), 
    .rst_n      (rst_n),
    
    //����ǰͼ������
    .per_frame_vsync    (pre_frame_vsync),
    .per_frame_href     (pre_frame_href), 
    .per_frame_hsync    (pre_frame_clken),
    .per_img_Y          (pre_img_y),
    
    //�������ͼ������?
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

//3x3���е���ֵ�˲�����Ҫ3��ʱ��
median_filter_3x3 u_median_filter_3x3(
    .clk        (clk),
    .rst_n      (rst_n),
    
    .median_frame_vsync (matrix_frame_vsync),
    .median_frame_href  (matrix_frame_href),
    .median_frame_clken (matrix_frame_clken),
    
    //��һ��
    .data11           (matrix_p11), 
    .data12           (matrix_p12), 
    .data13           (matrix_p13),
    //�ڶ���              
    .data21           (matrix_p21), 
    .data22           (matrix_p22), 
    .data23           (matrix_p23),
    //������              
    .data31           (matrix_p31), 
    .data32           (matrix_p32), 
    .data33           (matrix_p33),
    
    .pos_median_vsync (pos_frame_vsync),
    .pos_median_href  (pos_frame_href),
    .pos_median_clken (pos_frame_clken),
    .target_data      (mid_value)
);

endmodule 