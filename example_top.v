`timescale 1ns/1ps

//`include "ddr3_controller.vh"


module example_top 
(
	////////////////////////////////////////////////////////////////
	//	External Clock & Reset
	//input 			nrst, 			//	Button K2
	input 			clk_24m,			//	24MHz Crystal
	input 			clk_25m,			//	25MHz Crystal 
	
	
	////////////////////////////////////////////////////////////////
	//	System Clock
	output 			sys_pll_rstn_o, 		
	
	input 			clk_sys,			//	Sys PLL 96MHz 
	input 			clk_pixel,			//	Sys PLL 74.25MHz
	input 			clk_pixel_2x,		//	Sys PLL 148.5MHz
	input 			clk_pixel_10x,		//	Sys PLL 742.5MHz
	
	input 			sys_pll_lock,		//	Sys PLL Lock
	
	////////////////////////////////////////////////////////////////
	//	MIPI-DSI Clock & Reset
	output 			dsi_pll_rstn_o,
	
	input 			dsi_refclk_i,		//	48MHz Reference Clock (for DSI PLL)
	input 			dsi_byteclk_i,		//	DSI Byte Clock (1X)
	input 			dsi_serclk_i,		//	DSI Serial Clock (4X 45)
	input 			dsi_txcclk_i,		//	DSI Serial Clock (4X 135)
	
	input 			dsi_pll_lock,
	
	////////////////////////////////////////////////////////////////
	//	DDR Clock
	output 			ddr_pll_rstn_o, 
	
	input 			tdqss_clk,			
	input 			core_clk,			//	DDR PLL 200MHz
	input 			tac_clk,			
	input 			twd_clk,			
	
	input 			ddr_pll_lock,		//	DDR PLL Lock
	
	////////////////////////////////////////////////////////////////
	//	DDR PLL Phase Shift Interface
	output 	[2:0] 	shift,
	output 	[4:0] 	shift_sel,
	output 			shift_ena,
	
	
	
	////////////////////////////////////////////////////////////////
	//	LVDS Clock
	output 			lvds_pll_rstn_o, 
	
	input 			clk_lvds_1x, 
	input 			clk_lvds_7x, 
	input 			clk_27m, 			//	RGB 1X Clock (16MHz)
	input 			clk_54m, 			//	RGB 2X Clock (32MHz, for export control)
	
	input 			lvds_pll_lock, 
	
	
	
	////////////////////////////////////////////////////////////////
	//	DDR Interface Ports
	output 	[15:0] 	addr,
	output 	[2:0] 	ba,
	output 			we,
	output 			reset,
	output 			ras,
	output 			cas,
	output 			odt,
	output 			cke,
	output 			cs,
	
	//	DQ I/O
	input 	[15:0] 	i_dq_hi,
	input 	[15:0] 	i_dq_lo,
	
	output 	[15:0] 	o_dq_hi,
	output 	[15:0] 	o_dq_lo,
	output 	[15:0] 	o_dq_oe,
	
	//	DM O
	output 	[1:0] 	o_dm_hi,
	output 	[1:0] 	o_dm_lo,
	
	//	DQS I/O
	input 	[1:0] 	i_dqs_hi,
	input 	[1:0] 	i_dqs_lo,
	
	input 	[1:0] 	i_dqs_n_hi,
	input 	[1:0] 	i_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_hi,
	output 	[1:0] 	o_dqs_lo,
	
	output 	[1:0] 	o_dqs_n_hi,
	output 	[1:0] 	o_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_oe,
	output 	[1:0] 	o_dqs_n_oe,
	
	//	CK
	output 			clk_p_hi, 
	output 			clk_p_lo, 
	output 			clk_n_hi, 
	output 			clk_n_lo, 
	
	
	
	////////////////////////////////////////////////////////////////
	//	MIPI-CSI Ctl / I2C
	output 			csi_ctl0_o,
	output 			csi_ctl0_oe,
	input 			csi_ctl0_i,
	
	output 			csi_ctl1_o,
	output 			csi_ctl1_oe,
	input 			csi_ctl1_i,
	
	output 			csi_scl_o,
	output 			csi_scl_oe,
	input 			csi_scl_i,
	
	output 			csi_sda_o,
	output 			csi_sda_oe,
	input 			csi_sda_i,
	
	//	MIPI-CSI RXC 
	input 			csi_rxc_lp_p_i,
	input 			csi_rxc_lp_n_i,
	output 			csi_rxc_hs_en_o,
	output 			csi_rxc_hs_term_en_o,
	input 			csi_rxc_i,
	
	//	MIPI-CSI RXD0
	output 			csi_rxd0_rst_o,
	output 			csi_rxd0_hs_en_o,
	output 			csi_rxd0_hs_term_en_o,
	
	input 			csi_rxd0_lp_p_i,
	input 			csi_rxd0_lp_n_i,
	input 	[7:0] 	csi_rxd0_hs_i,
	
	//	MIPI-CSI RXD1
	output 			csi_rxd1_rst_o,
	output 			csi_rxd1_hs_en_o,
	output 			csi_rxd1_hs_term_en_o,
	
	input 			csi_rxd1_lp_n_i,
	input 			csi_rxd1_lp_p_i,
	input 	[7:0] 	csi_rxd1_hs_i,
	
	//	MIPI-CSI RXD2
	output 			csi_rxd2_rst_o,
	output 			csi_rxd2_hs_en_o,
	output 			csi_rxd2_hs_term_en_o,
	
	input 			csi_rxd2_lp_p_i,
	input 			csi_rxd2_lp_n_i,
	input 	[7:0] 	csi_rxd2_hs_i,
	
	//	MIPI-CSI RXD3
	output 			csi_rxd3_rst_o,
	output 			csi_rxd3_hs_en_o,
	output 			csi_rxd3_hs_term_en_o,
	
	input 			csi_rxd3_lp_p_i,
	input 			csi_rxd3_lp_n_i,
	input 	[7:0] 	csi_rxd3_hs_i,
	
	//output 			csi_rxd0_fifo_rd_o, 
	//input 			csi_rxd0_fifo_empty_i, 
	//output 			csi_rxd1_fifo_rd_o, 
	//input 			csi_rxd1_fifo_empty_i, 
	//output 			csi_rxd2_fifo_rd_o, 
	//input 			csi_rxd2_fifo_empty_i, 
	//output 			csi_rxd3_fifo_rd_o, 
	//input 			csi_rxd3_fifo_empty_i, 
	
	
	
	////////////////////////////////////////////////////////////////
	//	DSI PWM & Reset Control 
	output 			dsi_pwm_o,			//	MIPI-DSI LCD PWM
	output 			dsi_resetn_o,		//	MIPI-DSI LCD Reset
	
	//	MIPI-DSI TXC / TXD
	output 			dsi_txc_rst_o,
	output 			dsi_txc_lp_p_oe,
	output 			dsi_txc_lp_p_o,
	output 			dsi_txc_lp_n_oe,
	output 			dsi_txc_lp_n_o,
	output 			dsi_txc_hs_oe,
	output 	[7:0] 	dsi_txc_hs_o,
	
	output 			dsi_txd0_rst_o,
	output 			dsi_txd0_hs_oe,
	output 	[7:0] 	dsi_txd0_hs_o,
	output 			dsi_txd0_lp_p_oe,
	output 			dsi_txd0_lp_p_o,
	output 			dsi_txd0_lp_n_oe,
	output 			dsi_txd0_lp_n_o,
	
	output 			dsi_txd1_rst_o,
	output 			dsi_txd1_lp_p_oe,
	output 			dsi_txd1_lp_p_o,
	output 			dsi_txd1_lp_n_oe,
	output 			dsi_txd1_lp_n_o,
	output 			dsi_txd1_hs_oe,
	output 	[7:0] 	dsi_txd1_hs_o,
	
	output 			dsi_txd2_rst_o,
	output 			dsi_txd2_lp_p_oe,
	output 			dsi_txd2_lp_p_o,
	output 			dsi_txd2_lp_n_oe,
	output 			dsi_txd2_lp_n_o,
	output 			dsi_txd2_hs_oe,
	output 	[7:0] 	dsi_txd2_hs_o,
	
	output 			dsi_txd3_rst_o,
	output 			dsi_txd3_lp_p_oe,
	output 			dsi_txd3_lp_p_o,
	output 			dsi_txd3_lp_n_oe,
	output 			dsi_txd3_lp_n_o,
	output 			dsi_txd3_hs_oe,
	output 	[7:0] 	dsi_txd3_hs_o,
	
	input 			dsi_txd0_lp_p_i,
	input 			dsi_txd0_lp_n_i,
	input 			dsi_txd1_lp_p_i,
	input 			dsi_txd1_lp_n_i,
	input 			dsi_txd2_lp_p_i,
	input 			dsi_txd2_lp_n_i,
	input 			dsi_txd3_lp_p_i,
	input 			dsi_txd3_lp_n_i,
	
	
	////////////////////////////////////////////////////////////////
	//	UART Interface
	// input 		 	uart_rx_i,			//	Support 460800-8-N-1. 
	// output 		 	uart_tx_o, 
	input           fpga_rxd,
	// input           fpga_rxd_1,
	output          fpga_txd,
	// output          fpga_txd_1,
	
	
	output 	[5:0] 	led_o,			//	
	
	
	////////////////////////////////////////////////////////////////
	//	CMOS Sensor
	output 			cmos_sclk,
	input 			cmos_sdat_IN,
	output 			cmos_sdat_OUT,
	output 			cmos_sdat_OE,
	
	//	CMOS Interface
	input 			cmos_pclk,
	input 			cmos_vsync,
	input 			cmos_href,
	input 	[7:0] 	cmos_data,
	input 			cmos_ctl1,
	output 			cmos_ctl2,
	output 			cmos_ctl3,
	
	
	////////////////////////////////////////////////////////////////
	//	HDMI Interface
	output 			hdmi_txc_oe,
	output 			hdmi_txd0_oe,
	output 			hdmi_txd1_oe,
	output 			hdmi_txd2_oe,
	
	output 			hdmi_txc_rst_o,
	output 			hdmi_txd0_rst_o,
	output 			hdmi_txd1_rst_o,
	output 			hdmi_txd2_rst_o,
	
	output 	[9:0] 	hdmi_txc_o,
	output 	[9:0] 	hdmi_txd0_o,
	output 	[9:0] 	hdmi_txd1_o,
	output 	[9:0] 	hdmi_txd2_o,
	
	
	////////////////////////////////////////////////////////////////
	//	LVDS Interface
	output 			lvds_txc_oe,
	output 	[6:0] 	lvds_txc_o,
	output 			lvds_txc_rst_o,
	
	output 			lvds_txd0_oe,
	output 	[6:0] 	lvds_txd0_o,
	output 			lvds_txd0_rst_o,
	
	output 			lvds_txd1_oe,
	output 	[6:0] 	lvds_txd1_o,
	output 			lvds_txd1_rst_o,
	
	output 			lvds_txd2_oe,
	output 	[6:0] 	lvds_txd2_o,
	output 			lvds_txd2_rst_o,
	
	output 			lvds_txd3_oe,
	output 	[6:0] 	lvds_txd3_o,
	output 			lvds_txd3_rst_o,
	
	
	////////////////////////////////////////////////////////////////
	//	RGB LCD 5Inch 800x480
	output 			lcd_tp_sda_o,		//	TP SDA
	output 			lcd_tp_sda_oe,
	input 			lcd_tp_sda_i,
	
	output 			lcd_tp_scl_o,		//	TP SCL
	output 			lcd_tp_scl_oe,
	input 			lcd_tp_scl_i,
	
	output 			lcd_tp_int_o,		//	TP INT
	output 			lcd_tp_int_oe,
	input 			lcd_tp_int_i,
	
	output 			lcd_tp_rst_o,		//	TP RST
	
	output 			lcd_pwm_o,			//	Backlight
	output 			lcd_blen_o,
	
	//output 			lcd_pclk_o,			//	PCLK & SCK Mux
	output 			lcd_vs_o,			//	VS & SSN Mux. Fixed to 1. Use DE-Only mode. 
	output 			lcd_hs_o,			//	HS. Fixed to 1. Use DE-Only mode. 
	output 			lcd_de_o,			//	DE. 

	output 	[7:0] 	lcd_b7_0_o,			//	B7:B0. 
	output 	[7:0] 	lcd_g7_0_o,			//	G7:G0. Must output 8'hFF when access SPI. 
	output 	[7:0] 	lcd_r7_0_o,			//	R7:R0. 
	
	output 	[7:0] 	lcd_b7_0_oe,		//	B7:B0. 
	output 	[7:0] 	lcd_g7_0_oe,		//	G7:G0. Must output 8'hFF when access SPI. 
	output 	[7:0] 	lcd_r7_0_oe,		//	R7:R0. 

	input 	[7:0] 	lcd_b7_0_i,			//	B7:B0. 
	input 	[7:0] 	lcd_g7_0_i,			//	G7:G0. Must output 8'hFF when access SPI. 
	input 	[7:0] 	lcd_r7_0_i,			//	R7:R0. 
	
	//	SPI Pins
	output 			spi_sck_o, 
	output 			spi_ssn_o 			
);
	
	wire 			csi_rxd0_fifo_rd_o; 
	wire 			csi_rxd0_fifo_empty_i = 0;  
	wire 			csi_rxd1_fifo_rd_o;  
	wire 			csi_rxd1_fifo_empty_i = 0;  
	wire 			csi_rxd2_fifo_rd_o;  
	wire 			csi_rxd2_fifo_empty_i = 0;  
	wire 			csi_rxd3_fifo_rd_o;  
	wire 			csi_rxd3_fifo_empty_i = 0;  
	
	
	parameter 	SIM_DATA 	= 0; 
	
	//	Hardware Configuration
	assign clk_p_hi = 1'b0;	//	DDR3 Clock requires 180 degree shifted. 
	assign clk_p_lo = 1'b1;
	assign clk_n_hi = 1'b1;
	assign clk_n_lo = 1'b0; 
	
	//	System Clock Tree Control
	assign sys_pll_rstn_o = 1'b1; 	//	nrst; 	//	Reset whole system when nrst (K2) is pressed. 
	
	assign dsi_pll_rstn_o = sys_pll_lock; 
	assign ddr_pll_rstn_o = sys_pll_lock; 
	assign lvds_pll_rstn_o = sys_pll_lock; 
	
	wire 			w_pll_lock = sys_pll_lock && dsi_pll_lock && ddr_pll_lock && lvds_pll_lock; 
	
	//	Synchronize System Resets. 
	reg 			rstn_sys = 0, rstn_pixel = 0; 
	wire 			rst_sys = ~rstn_sys, rst_pixel = ~rstn_pixel; 
	
	reg 			rstn_dsi_refclk = 0, rstn_dsi_byteclk = 0; 
	wire 			rst_dsi_refclk = ~rstn_dsi_refclk, rst_dsi_byteclk = ~rstn_dsi_byteclk; 
	
	reg 			rstn_lvds_1x = 0; 
	wire 			rst_lvds_1x = ~rstn_lvds_1x; 
	
	reg 			rstn_27m = 0, rstn_54m = 0; 
	wire 			rst_27m = ~rstn_27m, rst_54m = ~rstn_54m; 
	
	//	Clock Gen
	always @(posedge clk_27m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_27m <= 0; else rstn_27m <= 1; end
	always @(posedge clk_54m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_54m <= 0; else rstn_54m <= 1; end
	always @(posedge clk_sys or negedge w_pll_lock) begin if(~w_pll_lock) rstn_sys <= 0; else rstn_sys <= 1; end
	always @(posedge clk_pixel or negedge w_pll_lock) begin if(~w_pll_lock) rstn_pixel <= 0; else rstn_pixel <= 1; end
	always @(posedge dsi_refclk_i or negedge w_pll_lock) begin if(~w_pll_lock) rstn_dsi_refclk <= 0; else rstn_dsi_refclk <= 1; end
	always @(posedge dsi_byteclk_i or negedge w_pll_lock) begin if(~w_pll_lock) rstn_dsi_byteclk <= 0; else rstn_dsi_byteclk <= 1; end
	always @(posedge clk_lvds_1x or negedge w_pll_lock) begin if(~w_pll_lock) rstn_lvds_1x <= 0; else rstn_lvds_1x <= 1; end
	
	
	localparam 	CLOCK_MAIN 	= 96000000; 	//	System clock using 96MHz. 
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	Flash Burner Control
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire 			w_ustick, w_mstick; 
	
	wire  [7:0] 	w_dev_index_o;  
	wire  [7:0] 	w_dev_cmd_o;  
	wire  [31:0] 	w_dev_wdata_o;  
	wire  		w_dev_wvalid_o;  
	wire  		w_dev_rvalid_o;  
	wire 	[31:0] 	w_dev_rdata_i;  
	
	wire 			w_spi_ssn_o, w_spi_sck_o; 
	wire 	[3:0] 	w_spi_data_o, w_spi_data_oe; 
	wire 	[3:0] 	w_spi_data_i; 
	
	//	Flash Control
	reg 			r_flash_en = 0; 		//	0x00:0x00 Enable Flash
	
	always @(posedge clk_sys) begin
		r_flash_en <= (w_dev_wvalid_o && (w_dev_index_o == 8'h00) && (w_dev_cmd_o == 8'h00)) ? w_dev_wdata_o : r_flash_en; 
	end
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	LCD Data Mux
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire 	[7:0] 	w_lcd_b_o, w_lcd_g_o, w_lcd_r_o; 
	
	assign lcd_b7_0_o = r_flash_en ? {4'b0, w_spi_data_o[3:2], 2'b0} : w_lcd_b_o; 
	assign lcd_g7_0_o = r_flash_en ? {6'h0, w_spi_data_o[1:0]} : w_lcd_g_o; 
	assign lcd_r7_0_o = r_flash_en ? {8'h00} : w_lcd_r_o; 
	
	assign lcd_b7_0_oe = r_flash_en ? {4'b0, w_spi_data_oe[3:2], 2'b0} : 8'hFF; 
	assign lcd_g7_0_oe = r_flash_en ? {6'h0, w_spi_data_oe[1:0]} : 8'hFF; 
	assign lcd_r7_0_oe = r_flash_en ? {8'h00} : 8'hFF; 
	
	assign spi_sck_o = w_spi_sck_o; 
	assign spi_ssn_o = w_spi_ssn_o; 
	assign w_spi_data_i = {lcd_b7_0_i[3:2], lcd_g7_0_i[1:0]}; 
	
	
	
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DDR3 Controller
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	wire			w_ddr3_ui_clk = clk_sys;
	wire			w_ddr3_ui_rst = rst_sys;
	wire			w_ddr3_ui_areset = rst_sys;
	wire			w_ddr3_ui_aresetn = rstn_sys;
	

	//	General AXI Interface 
	wire	[3:0] 	w_ddr3_awid;
	wire	[31:0]	w_ddr3_awaddr;
	wire	[7:0]		w_ddr3_awlen;
	wire			w_ddr3_awvalid;
	wire			w_ddr3_awready;
	
	wire 	[3:0]  	w_ddr3_wid;
	wire 	[127:0] 	w_ddr3_wdata;
	wire 	[15:0]	w_ddr3_wstrb;
	wire			w_ddr3_wlast;
	wire			w_ddr3_wvalid;
	wire			w_ddr3_wready;
	
	wire 	[3:0] 	w_ddr3_bid;
	wire 	[1:0] 	w_ddr3_bresp;
	wire			w_ddr3_bvalid;
	wire			w_ddr3_bready;
	
	wire	[3:0] 	w_ddr3_arid;
	wire	[31:0]	w_ddr3_araddr;
	wire	[7:0]		w_ddr3_arlen;
	wire			w_ddr3_arvalid;
	wire			w_ddr3_arready;
	
	wire 	[3:0] 	w_ddr3_rid;
	wire 	[127:0] 	w_ddr3_rdata;
	wire			w_ddr3_rlast;
	wire			w_ddr3_rvalid;
	wire			w_ddr3_rready;
	wire 	[1:0] 	w_ddr3_rresp;
	
	
	//	AXI Interface Request
	wire 	[3:0] 	w_ddr3_aid;
	wire 	[31:0] 	w_ddr3_aaddr;
	wire 	[7:0]  	w_ddr3_alen;
	wire 	[2:0]  	w_ddr3_asize;
	wire 	[1:0]  	w_ddr3_aburst;
	wire 	[1:0]  	w_ddr3_alock;
	wire			w_ddr3_avalid;
	wire			w_ddr3_aready;
	wire			w_ddr3_atype;
	
	wire 			w_ddr3_cal_done, w_ddr3_cal_pass; 
	
	//	Do not issue DDR read / write when ~cal_done. 
	reg 			r_ddr_unlock = 0; 
	always @(posedge w_ddr3_ui_clk or negedge w_ddr3_ui_aresetn) begin
		if(~w_ddr3_ui_aresetn)
			r_ddr_unlock <= 0; 
		else
			r_ddr_unlock <= w_ddr3_cal_done; 
	end
	
	DdrCtrl ddr3_ctl_axi (	
		.core_clk		(core_clk),
		.tac_clk		(tac_clk),
		.twd_clk		(twd_clk),	
		.tdqss_clk		(tdqss_clk),
		
		.reset		(reset),
		.cs			(cs),
		.ras			(ras),
		.cas			(cas),
		.we			(we),
		.cke			(cke),    
		.addr			(addr),
		.ba			(ba),
		.odt			(odt),
		
		.o_dm_hi		(o_dm_hi),
		.o_dm_lo		(o_dm_lo),
		
		.i_dq_hi		(i_dq_hi),
		.i_dq_lo		(i_dq_lo),
		.o_dq_hi		(o_dq_hi),
		.o_dq_lo		(o_dq_lo),
		.o_dq_oe		(o_dq_oe),
		
		.i_dqs_hi		(i_dqs_hi),
		.i_dqs_lo		(i_dqs_lo),
		.i_dqs_n_hi		(i_dqs_n_hi),
		.i_dqs_n_lo		(i_dqs_n_lo),
		.o_dqs_hi		(o_dqs_hi),
		.o_dqs_lo		(o_dqs_lo),
		.o_dqs_n_hi		(o_dqs_n_hi),
		.o_dqs_n_lo		(o_dqs_n_lo),
		.o_dqs_oe		(o_dqs_oe),
		.o_dqs_n_oe		(o_dqs_n_oe),
		
		.clk			(w_ddr3_ui_clk),
		.reset_n		(w_ddr3_ui_aresetn),
		
		.axi_avalid		(w_ddr3_avalid && r_ddr_unlock),	//	Enable command only when unlocked. 
		.axi_aready		(w_ddr3_aready),
		.axi_aaddr		(w_ddr3_aaddr),
		.axi_aid		(w_ddr3_aid),
		.axi_alen		(w_ddr3_alen),
		.axi_asize		(w_ddr3_asize),
		.axi_aburst		(w_ddr3_aburst),
		.axi_alock		(w_ddr3_alock),
		.axi_atype		(w_ddr3_atype),
		
		.axi_wid		(w_ddr3_wid),
		.axi_wvalid		(w_ddr3_wvalid),
		.axi_wready		(w_ddr3_wready),
		.axi_wdata		(w_ddr3_wdata),
		.axi_wstrb		(w_ddr3_wstrb),
		.axi_wlast		(w_ddr3_wlast),
		
		.axi_bvalid		(w_ddr3_bvalid),
		.axi_bready		(w_ddr3_bready),
		.axi_bid		(w_ddr3_bid),
		.axi_bresp		(w_ddr3_bresp),
		
		.axi_rvalid		(w_ddr3_rvalid),
		.axi_rready		(w_ddr3_rready),
		.axi_rdata		(w_ddr3_rdata),
		.axi_rid		(w_ddr3_rid),
		.axi_rresp		(w_ddr3_rresp),
		.axi_rlast		(w_ddr3_rlast),
		
		.shift		(shift),
		.shift_sel		(),
		.shift_ena		(shift_ena),
		
		.cal_ena		(1'b1),
		.cal_done		(w_ddr3_cal_done),
		.cal_pass		(w_ddr3_cal_pass)
	);
	
	assign w_ddr3_bready = 1'b1; 
	assign shift_sel = 5'b00100; 		//	ddr_tac_clk always use PLLOUT[2]. 
	
	
	AXI4_AWARMux #(.AID_LEN(4), .AADDR_LEN(32)) axi4_awar_mux (
		.aclk_i			(w_ddr3_ui_clk), 
		.arst_i			(w_ddr3_ui_rst), 
		
		.awid_i			(w_ddr3_awid),
		.awaddr_i			(w_ddr3_awaddr),
		.awlen_i			(w_ddr3_awlen),
		.awvalid_i			(w_ddr3_awvalid),
		.awready_o			(w_ddr3_awready),
		
		.arid_i			(w_ddr3_arid),
		.araddr_i			(w_ddr3_araddr),
		.arlen_i			(w_ddr3_arlen),
		.arvalid_i			(w_ddr3_arvalid),
		.arready_o			(w_ddr3_arready),
		
		.aid_o			(w_ddr3_aid),
		.aaddr_o			(w_ddr3_aaddr),
		.alen_o			(w_ddr3_alen),
		.atype_o			(w_ddr3_atype),
		.avalid_o			(w_ddr3_avalid),
		.aready_i			(w_ddr3_aready)
	);
	
	assign w_ddr3_asize = 4; 		//	Fixed 128 bits (16 bytes, size = 4)
	assign w_ddr3_aburst = 1; 
	assign w_ddr3_alock = 0; 
	
	//assign led_o[1:0] = {w_ddr3_cal_pass, w_ddr3_cal_done}; 
	
	
	
	
	
	
	
	
	
	////////////////////////////////////////////////////////////////
	//	I2C Config (SC130GS)
	
	//  i2c timing controller module of 16Bit
	wire            [ 7:0]          sc130_i2c_config_index;
	wire            [23:0]          sc130_i2c_config_data;
	wire            [ 7:0]          sc130_i2c_config_size;
	wire                            sc130_i2c_config_done;
	
	// I2C总线合并逻辑信号
	wire                            sc130_i2c_sda_o;     // SC130模块的SDA输出
	wire                            sc130_i2c_sda_oe;    // SC130模块的SDA输出使能
	wire                            sc130_i2c_scl_o;     // SC130模块的SCL输出 (如果模块支持)
	i2c_timing_ctrl_16bit
	#(
	    .CLK_FREQ           (CLOCK_MAIN),                              //  100 MHz
	    .I2C_FREQ           (100_000    )                               //  10 KHz(<= 400KHz)
	) u_i2c_timing_ctrl_16bit (
	    //  global clock
	    .clk                (clk_sys                 ),                          //  96MHz
	    .rst_n              (rstn_sys                ),                          //  system reset

	    //  i2c interface
	    .i2c_sclk           (sc130_i2c_scl_o         ),                          //  i2c clock
	    .i2c_sdat_IN        (csi_sda_i               ),
	    .i2c_sdat_OUT       (sc130_i2c_sda_o         ),  // 连接到内部信号
	    .i2c_sdat_OE        (sc130_i2c_sda_oe        ),  // 连接到内部信号

	    //  i2c config data
	    .i2c_config_index   (sc130_i2c_config_index        ),                          //  i2c config reg index, read 2 reg and write xx reg
	    .i2c_config_data    ({8'h6a, sc130_i2c_config_data}),                     //  i2c config data
	    .i2c_config_size    (sc130_i2c_config_size         ),                          //  i2c config data counte
	    .i2c_config_done    (sc130_i2c_config_done         ),                          //  i2c config timing complete


		.config_clk                        (w_csi_rx_clk                ),
		.config_data                       (config_data               ),
		.config_data_valid                 (config_data_valid         ) 
	
		);
	assign csi_scl_oe = 1; 

	//  I2C Configure Data of SC130GS
	I2C_AD2020_1280960_FPS60_1Lane_Config u_I2C_AD2020_1280960_FPS60_1Lane_Config 
	(
	    .LUT_INDEX  (sc130_i2c_config_index   ),
	    .LUT_DATA   (sc130_i2c_config_data    ),
	    .LUT_SIZE   (sc130_i2c_config_size    )
	);
	

	reg 	[3:0] 	r_dsi_lp_p_ovr = 0; 	
	reg 	[3:0] 	r_dsi_lp_n_ovr = 0; 	
	
		////////////////////////////////////////////////////////////////
	//	System Control. Can be removed for public. 
	
	localparam 	CLK_FREQ 	= 96_000_000; 	//	clk_sys is 96MHz. 
	localparam 	BAUD_RATE 	= 460_800; 		//	Use 460800-8-N-1. 
	
	
	//	SFR I/O Interface
	wire 	[7:0] 	w_sfr_addr_o; 	//	SFR Address (0xFF00 ~ 0xFFFF). 00:Power; 40~5F:Stream0; 60~7F:Stream1. 
	wire 	[7:0] 	w_sfr_wdata_o; 	//	SFR Write Data. 
	wire 			w_sfr_we_o; 		//	SFR WE. 
	reg 	[7:0] 	w_sfr_rdata_i; 	//	Must be valid after sfr_rd_o. 
	wire 			w_sfr_rd_o; 		//	SFR RD. 
	
	
	//	System Control Registers
	reg 			r_dsi_tx_rstn = 0; 	//	DSI TX Reset
	reg 	[7:0] 	r_dsi_pwm = 64; 		//	[6:0]PWM, [7]Pol
	reg 			r_dsi_resetn_o = 0; 	//	DSI Panel Reset
	reg 			r_dsi_data_rstn = 0; 	//	DSI TX Reset
	
	
	//	AXI-Lite Interface Bridge
	localparam 	CSI_AXILITE_ID 	= 0; 				//	Select DSI_TX when r_axi_sel = DSI_AXILITE_ID. 
	localparam 	DSI_AXILITE_ID 	= 1; 				//	Select DSI_TX when r_axi_sel = DSI_AXILITE_ID. 
	
	reg 	[7:0] 	r_axi_addr = 8'h18; 		//	0xE0 (RW)
	reg 	[31:0] 	r_axi_wdata = 32'h0000000A; 	//	0xE1~0xE4 (RW)
	wire 	[31:0] 	w_axi_rdata; 			//	0xE5~0xE8 (RO)
	reg 	[0:0] 	r_axi_sel = 1; 			//	0xE9[7:2] (RW)
	reg 			r_axi_r1w0 = 0; 			//	0xE9[1] (RW)
	reg 			r_axi_req = 0; 			//	0xE9[0] (WO, Single Cycle)
	reg 			r_axi_req_o = 0; 			//	Delayed of r_axi_req. 
	
	
	//	Buffered AXI Read Data
	reg 	[31:0] 	r_axi_rdata = 0; 		//	Use state machine
	reg 			r_axi_idle = 0; 		//	AXI Idle 
	
	reg 	[3:0] 	rs_axilite = 0; 		//	AXI Access
	wire 	[3:0] 	ws_axilite_idle = 0; 		
	wire 	[3:0] 	ws_axilite_write = 1; 
	wire 	[3:0] 	ws_axilite_read = 2; 
	wire 	[3:0] 	ws_axilite_endread = 3; 
	
	reg 			r_axi_awvalid = 0, r_axi_wvalid = 0, r_axi_arvalid = 0; 
	wire 			w_axi_awready, w_axi_wready, w_axi_arready, w_axi_rvalid; 
	
	
	reg 	[3:0] 	rc_axi_init = 0; 

	always @(posedge clk_sys or posedge rst_sys) begin
		if(rst_sys) begin
			r_dsi_tx_rstn <= 0; 
			r_dsi_pwm <= 64; 
			r_axi_req <= 0; 
			r_dsi_resetn_o <= 0; 
			r_dsi_data_rstn <= 0; 
			
			rs_axilite <= 0; 
			r_axi_awvalid <= 0; 
			r_axi_wvalid <= 0;
			r_axi_arvalid <= 0; 
			
			r_dsi_lp_p_ovr <= 0; 
			r_dsi_lp_n_ovr <= 0; 
			
			rc_axi_init <= 0; 
			r_axi_idle <= 0; 
			
		end else begin
			r_dsi_tx_rstn <= 1; 
			r_dsi_resetn_o <= 1; 
			r_dsi_data_rstn <= 1; 
			
		end
	end
	
	assign dsi_resetn_o = r_dsi_resetn_o; 
	
	assign csi_ctl0_oe = 0; 
	assign csi_ctl1_oe = 0; 
	
	
	PWMLite dsi_pwm (		//	#(.ENABLE_TICK(0), .PWM_BITS(7)) 
		.clk_i			(clk_sys),
		.rst_i			(rst_sys),
		.pwm_i			(r_dsi_pwm[6:0]),
		.pol_i			(r_dsi_pwm[7]), 
		.pwm_o			(dsi_pwm_o)
	);






	////////////////////////////////////////////////////////////////
	//	MIPI CSI RX
	wire                                    empty_o                    ;
wire                                    wr_en                      ;
wire                   [  31:0]         wr_data                    ;
wire                   [   7:0]         rd_data                    ;
wire                                    prepare_vsync              ;
wire                                    prepare_valid              ;
wire                   [   7:0]         prepare_data               ;
wire                   [  10:0]         rd_count                   ;
reg                                     rd_en                      ;
reg                    [  10:0]         pixel_cnt                  ;
	
	//	The CSI RXC shall not be inverted. Data can be inverted with swapped LP data and flipped HS data. 
	// localparam 	CSI_RXD_INV 	= 4'b1111; 
	// localparam 	CSI_RXD_INV 	= 4'b0000; 
	localparam 	CSI_RXD_INV 	= 4'b0000; 
	// localparam 	CSI_RXD_INV 	= 4'b0001; 
	localparam 	CSI_DATA_WIDTH 	= 8; 			
	localparam 	CSI_STRB_WIDTH 	= CSI_DATA_WIDTH / 8; 

	//	Current implementation supports RAW8 only. 
	wire 			w_csi_rx_clk; 

	wire 			w_csi_rx_vsync0, w_csi_rx_hsync0, w_csi_rx_dvalid; 
	wire 	[63:0] 	w_csi_rx_data; 
	wire 	[47:0] 	w_csi_rx_data_rel_raw; 
	
	//	AXI Interface
	wire 	[31:0] 	w_csi_axi_rdata; 
	wire 			w_csi_axi_awready, w_csi_axi_wready, w_csi_axi_arready, w_csi_axi_rvalid; 
	
	
	
	
	
	wire [7:0] data_typer;
	//	Reset pixel 16 cycles after ~vsync. 
	reg 			r_reset_pixen_n = 0; 
	reg 	[1:0] 	r_csi_rx_vsync0_i = 0; 
	reg 	[3:0] 	rc_csi_rx_vsync0_f = 0; 
	always @(posedge w_csi_rx_clk or negedge rstn_sys) begin
		if(~rstn_sys) begin
			r_reset_pixen_n <= 0; 
			r_csi_rx_vsync0_i <= 0; 
			rc_csi_rx_vsync0_f <= 0; 
		end else begin
			r_csi_rx_vsync0_i <= {r_csi_rx_vsync0_i, w_csi_rx_vsync0}; 
			if(r_csi_rx_vsync0_i == 2'b10) 
				rc_csi_rx_vsync0_f <= 1; 
			else
				rc_csi_rx_vsync0_f <= rc_csi_rx_vsync0_f + (|rc_csi_rx_vsync0_f); 
			r_reset_pixen_n <= (&rc_csi_rx_vsync0_f) ? 0 : 1; 
		end
	end

	// `define PRI_IP
	`ifdef PRI_IP
	wire 	[7:0] 	w_mipi_d0 = (CSI_RXD_INV[0] ? 8'hFF : 8'h00) ^ csi_rxd0_hs_i; 
	wire 	[7:0] 	w_mipi_d1 = (CSI_RXD_INV[1] ? 8'hFF : 8'h00) ^ csi_rxd1_hs_i; 
	wire 	[7:0] 	w_mipi_d2 = (CSI_RXD_INV[2] ? 8'hFF : 8'h00) ^ csi_rxd2_hs_i; 
	wire 	[7:0] 	w_mipi_d3 = (CSI_RXD_INV[3] ? 8'hFF : 8'h00) ^ csi_rxd3_hs_i; 
	MIPIRx1LaneFre mipi0_rx (
		.sclk_i			(clk_sys), 
		.srst_i			(rst_sys), 
		
		.mipi_rx_byteclk_i	(csi_rxc_i), 
		.mipi_rx_d0_i		({w_mipi_d0[0], w_mipi_d0[1], w_mipi_d0[2], w_mipi_d0[3], w_mipi_d0[4], w_mipi_d0[5], w_mipi_d0[6], w_mipi_d0[7]}), 
		.mipi_rx_d1_i		({w_mipi_d1[0], w_mipi_d1[1], w_mipi_d1[2], w_mipi_d1[3], w_mipi_d1[4], w_mipi_d1[5], w_mipi_d1[6], w_mipi_d1[7]}), 
		.mipi_rx_d2_i		({w_mipi_d2[0], w_mipi_d2[1], w_mipi_d2[2], w_mipi_d2[3], w_mipi_d2[4], w_mipi_d2[5], w_mipi_d2[6], w_mipi_d2[7]}), 
		.mipi_rx_d3_i		({w_mipi_d3[0], w_mipi_d3[1], w_mipi_d3[2], w_mipi_d3[3], w_mipi_d3[4], w_mipi_d3[5], w_mipi_d3[6], w_mipi_d3[7]}), 
		.mipi_rx_clk_lp_p_i	(csi_rxc_lp_p_i), 
		.mipi_rx_clk_lp_n_i	(csi_rxc_lp_n_i), 
		.mipi_rx_d0_lp_p_i	(CSI_RXD_INV[0] ? csi_rxd0_lp_n_i : csi_rxd0_lp_p_i), 
		.mipi_rx_d0_lp_n_i	(CSI_RXD_INV[0] ? csi_rxd0_lp_p_i : csi_rxd0_lp_n_i), 
		.mipi_rx_rst_o		(), 
		.mipi_rx_rst_n_o		(), 
		.mipi_rx_clk_hs_en_o	(csi_rxc_hs_en_o), 
		.mipi_rx_dat_hs_en_o	(csi_rxd0_hs_en_o), 
		.mipi_rx_clk_term_en_o	(csi_rxc_hs_term_en_o), 
		.mipi_rx_dat_term_en_o	(csi_rxd0_hs_term_en_o), 
		
		.CLK				(w_csi_rx_clk), 
		.VSYNC			(w_csi_rx_vsync0), 
		.HSYNC			(w_csi_rx_hsync0), 
		.DE				(w_csi_rx_dvalid), 
		.DAT				(w_csi_rx_data_rel_raw)
	);
	assign w_csi_rx_data = {2{w_csi_rx_data_rel_raw[47:40], w_csi_rx_data_rel_raw[35:28], w_csi_rx_data_rel_raw[23:16], w_csi_rx_data_rel_raw[11:4]}}; 
	assign {csi_rxd3_hs_en_o, csi_rxd2_hs_en_o, csi_rxd1_hs_en_o} = {3{csi_rxd0_hs_en_o}}; 
	assign {csi_rxd3_hs_term_en_o, csi_rxd2_hs_term_en_o, csi_rxd1_hs_term_en_o} = {3{csi_rxd0_hs_term_en_o}}; 
assign wr_data = {w_csi_rx_data_rel_raw[39:32], w_csi_rx_data_rel_raw[29:22],w_csi_rx_data_rel_raw[19:12], w_csi_rx_data_rel_raw[9:2]} ;

`else
	
	assign w_csi_rx_clk = clk_sys; 
    csi_rx mipi_rx_0(
    .reset_n                           (rstn_sys                  ),
    .clk                               (w_csi_rx_clk              ),
    .reset_byte_HS_n                   (rstn_sys                  ),
    .clk_byte_HS                       (csi_rxc_i                 ),
    .reset_pixel_n                     (r_reset_pixen_n           ),//rstn_sys), 
    .clk_pixel                         (w_csi_rx_clk              ),
    // .Rx_LP_CLK_P                       (    csi_rxc_lp_n_i        ),
    // .Rx_LP_CLK_N                       (    csi_rxc_lp_p_i        ),
    .Rx_LP_CLK_P                       (csi_rxc_lp_p_i         ),
    .Rx_LP_CLK_N                       (csi_rxc_lp_n_i         ),

    .Rx_HS_enable_C                    (csi_rxc_hs_en_o           ),
    .LVDS_termen_C                     (csi_rxc_hs_term_en_o      ),
		
		//	Lane inversion affects HS & LP data only. 
    .Rx_LP_D_P                         ({CSI_RXD_INV[3] ? csi_rxd3_lp_n_i : csi_rxd3_lp_p_i, CSI_RXD_INV[2] ? csi_rxd2_lp_n_i : csi_rxd2_lp_p_i, CSI_RXD_INV[1] ? csi_rxd1_lp_n_i : csi_rxd1_lp_p_i, CSI_RXD_INV[0] ? csi_rxd0_lp_n_i : csi_rxd0_lp_p_i}),
    .Rx_LP_D_N                         ({CSI_RXD_INV[3] ? csi_rxd3_lp_p_i : csi_rxd3_lp_n_i, CSI_RXD_INV[2] ? csi_rxd2_lp_p_i : csi_rxd2_lp_n_i, CSI_RXD_INV[1] ? csi_rxd1_lp_p_i : csi_rxd1_lp_n_i, CSI_RXD_INV[0] ? csi_rxd0_lp_p_i : csi_rxd0_lp_n_i}),
    .Rx_HS_D_0                         ((CSI_RXD_INV[0] ? 8'hFF : 8'h00) ^ csi_rxd0_hs_i),
    .Rx_HS_D_1                         ((CSI_RXD_INV[1] ? 8'hFF : 8'h00) ^ csi_rxd1_hs_i),
    .Rx_HS_D_2                         ((CSI_RXD_INV[2] ? 8'hFF : 8'h00) ^ csi_rxd2_hs_i),
    .Rx_HS_D_3                         ((CSI_RXD_INV[3] ? 8'hFF : 8'h00) ^ csi_rxd3_hs_i),
    .Rx_HS_D_4                         (                          ),
    .Rx_HS_D_5                         (                          ),
    .Rx_HS_D_6                         (                          ),
    .Rx_HS_D_7                         (                          ),
		
    .Rx_HS_enable_D                    ({csi_rxd3_hs_en_o, csi_rxd2_hs_en_o, csi_rxd1_hs_en_o, csi_rxd0_hs_en_o}),
    .LVDS_termen_D                     ({csi_rxd3_hs_term_en_o, csi_rxd2_hs_term_en_o, csi_rxd1_hs_term_en_o, csi_rxd0_hs_term_en_o}),
    .fifo_rd_enable                    ({csi_rxd3_fifo_rd_o, csi_rxd2_fifo_rd_o, csi_rxd1_fifo_rd_o, csi_rxd0_fifo_rd_o}),
    .fifo_rd_empty                     ({csi_rxd3_fifo_empty_i, csi_rxd2_fifo_empty_i, csi_rxd1_fifo_empty_i, csi_rxd0_fifo_empty_i}),
    .DLY_enable_D                      (                          ),
    .DLY_inc_D                         (                          ),
    .u_dly_enable_D                    (0                         ),
    .u_dly_inc_D                       (                          ),
		
    .vsync_vc1                         (                          ),
    .vsync_vc15                        (                          ),
    .vsync_vc12                        (                          ),
    .vsync_vc9                         (                          ),
    .vsync_vc7                         (                          ),
    .vsync_vc14                        (                          ),
    .vsync_vc13                        (                          ),
    .vsync_vc11                        (                          ),
    .vsync_vc10                        (                          ),
    .vsync_vc8                         (                          ),
    .vsync_vc6                         (                          ),
    .vsync_vc4                         (                          ),
    .vsync_vc0                         (w_csi_rx_vsync0           ),
    .vsync_vc5                         (                          ),
    .vsync_vc3                         (                          ),
    .vsync_vc2                         (                          ),
	
    .irq                               (                          ),
		
    .pixel_data_valid                  (w_csi_rx_dvalid           ),
    .pixel_data                        (w_csi_rx_data             ),
    .pixel_per_clk                     (                          ),
    .datatype                          (data_typer                ),
    .shortpkt_data_field               (                          ),
    .word_count                        (                          ),
    .vcx                               (                          ),
    .vc                                (                          ),
    .hsync_vc3                         (                          ),
    .hsync_vc2                         (                          ),
    .hsync_vc8                         (                          ),
    .hsync_vc12                        (                          ),
    .hsync_vc7                         (                          ),
    .hsync_vc10                        (                          ),
    .hsync_vc1                         (                          ),
    .hsync_vc0                         (w_csi_rx_hsync0           ),
    .hsync_vc13                        (                          ),
    .hsync_vc4                         (                          ),
    .hsync_vc11                        (                          ),
    .hsync_vc6                         (                          ),
    .hsync_vc9                         (                          ),
    .hsync_vc15                        (                          ),
    .hsync_vc14                        (                          ),
    .hsync_vc5                         (                          ),
		
    .axi_clk                           (clk_sys                   ),
    .axi_reset_n                       (rstn_sys                  ),
		
    .axi_awaddr                        (r_axi_addr                ),
    .axi_awvalid                       ((r_axi_sel == CSI_AXILITE_ID) && r_axi_awvalid),
    .axi_awready                       (w_csi_axi_awready         ),
	
    .axi_wvalid                        ((r_axi_sel == CSI_AXILITE_ID) && r_axi_wvalid),
    .axi_wdata                         (r_axi_wdata               ),
    .axi_wready                        (w_csi_axi_wready          ),
	
    .axi_bvalid                        (                          ),
    .axi_bready                        (1                         ),
		
    .axi_araddr                        (r_axi_addr                ),
    .axi_arvalid                       ((r_axi_sel == CSI_AXILITE_ID) && r_axi_arvalid),
    .axi_arready                       (w_csi_axi_arready         ),
		
    .axi_rready                        (1                         ),
    .axi_rvalid                        (w_csi_axi_rvalid          ),
    .axi_rdata                         (w_csi_axi_rdata           ) 
		
    );
assign wr_data = {w_csi_rx_data[39:32], w_csi_rx_data[29:22],w_csi_rx_data[19:12], w_csi_rx_data[9:2]} ;

`endif 
	assign csi_rxd0_rst_o = rst_sys; 
	assign csi_rxd1_rst_o = rst_sys; 
	assign csi_rxd2_rst_o = rst_sys; 
	assign csi_rxd3_rst_o = rst_sys; 
	
	
	//	Output LED
	reg 	[5:0]		r_csi_fv_o = 0; 
	reg 	[1:0] 	r_csi_rx_vsync0_in = 0; 
	always @(posedge w_csi_rx_clk) begin
		r_csi_rx_vsync0_in <= {r_csi_rx_vsync0_in, w_csi_rx_vsync0}; 
		r_csi_fv_o <= r_csi_fv_o + ((r_csi_rx_vsync0_in == 2'b01) ? 1 : 0); 
	end
	// assign led_o[4] = r_csi_fv_o[5]; 

	// 使用LED显示AE I2C状态机状态
	// LED0-4对应五种状态，LED5显示i2c_transfer_complete信号
	reg [5:0] ae_state_leds;
	always @(*) begin
		case (update_state)
			UPDATE_IDLE:     ae_state_leds <= 6'b000001;
			UPDATE_EXP_LOW:  ae_state_leds <= 6'b000010;
			UPDATE_EXP_HIGH: ae_state_leds <= 6'b000100;
			UPDATE_GAIN:     ae_state_leds <= 6'b001000;
			default:         ae_state_leds <= 6'b000000;
		endcase
	end

	// assign led_o[5] = ~i2c_transfer_complete; // LED5显示i2c_transfer_complete信号
	// assign led_o[4:0] = ~ae_state_leds[4:0]; // LED4-0显示状态

	// 添加LED显示各种算法使能状态
	// LED0: AE算法使能
	// LED1: 颜色矫正使能
	// LED2: 中值滤波使能
	// LED3: 消光算法使能
	// LED4: 锐化使能
	// LED5: I2C传输完成信号
	assign led_o[0] = ae_enable;              // AE算法使能，高电平时LED亮
	assign led_o[1] = median_filter_enable?model_select[0]:1'b0;           // 
	assign led_o[2] = median_filter_enable?model_select[1]:1'b1;   //
	assign led_o[3] = color_correction_enable;  // 颜色矫正使能，高电平时LED亮
	assign led_o[4] = extinction_enable;        // 消光算法使能，高电平时LED亮
	assign led_o[5] = sharpen_enable;     // 锐化使能，高电平时LED亮
	
	

wire [10:0] cnt_pixel;
wire [10:0] cnt_row;

Row_Line_Counter  u_Row_Line_Counter (
    .Data_clk                          (w_csi_rx_clk               ),
    .Data_rst_n                        (rstn_sys             ),
    .Data_vsync                        (w_csi_rx_vsync0         ),
    .Data_hsync                        (w_csi_rx_hsync0         ),//用于统计行
    .Data_valid                        (w_csi_rx_dvalid         ),//用于统计每一行的像素

    .cnt_pixel                         (cnt_pixel   [10:0]),
    .cnt_row                           (cnt_row     [10:0]) 
);
// =========================================================================================================================================
// data 32 to 8
// ========================================================================================================================================= 

//c1
// assign wr_data = {w_csi_rx_data[9:2], w_csi_rx_data[19:12], w_csi_rx_data[29:22], w_csi_rx_data[39:32]} ;
assign wr_en = w_csi_rx_hsync0 && w_csi_rx_dvalid;

always@(posedge w_csi_rx_clk or negedge rstn_sys)
begin
	if(!rstn_sys)
		begin
			rd_en   <=  'd0 ;
		end
	else if(pixel_cnt == 1279)
		begin
			rd_en   <=  'd0 ;
		end
	else if(rd_count >=1280)
		begin
			rd_en   <=  1;
		end
	else
		begin
			rd_en   <=  rd_en ;
		end
end
always@(posedge w_csi_rx_clk or negedge rstn_sys)
begin
	if(!rstn_sys)
		begin
			pixel_cnt   <=  'd0 ;
		end
	else if(pixel_cnt == 1279)
		begin
			pixel_cnt   <=  'd0 ;
		end
	else if(rd_en)
		begin
			pixel_cnt   <=  pixel_cnt + 1 ;
		end
	else
		begin
			pixel_cnt   <=  'd0 ;
		end
end
//c2
afifo_w32r8_reshape u_afifo_w32r8_reshape
(
	.full_o                            (                          ),
    .rst_busy                          (                          ),
	.empty_o                           (empty_o                   ),
    .a_rst_i                           (~rstn_sys              ),
   
    .wr_clk_i                          (w_csi_rx_clk                ),
    .wdata                             (wr_data                   ),
    .wr_en_i                           (wr_en                     ),
    .wr_datacount_o                    (                          ),
    
    .rd_clk_i                          (w_csi_rx_clk                ),
    .rd_en_i                           (rd_en                     ),
    .rdata                             (rd_data                   ),
    .rd_datacount_o                    (rd_count                  ) 
);
//c3
wire                                    delay_vsync                ;
delay_reg #(.delay_level(1280),.reg_width(1)) DR0(
    .clk                               (w_csi_rx_clk                ),
    .rst                               (~rstn_sys              ),
    .din                               (w_csi_rx_vsync0      ),

    .dout                              (delay_vsync               ) 
);
assign prepare_vsync = delay_vsync;
assign prepare_valid = rd_en;
assign prepare_data = rd_data;
// =========================================================================================================================================
// DPC
// ========================================================================================================================================= 
// wire                                    post_frame_vsync           ;
// wire                                    post_frame_href            ;
// wire                                    post_frame_hsync           ;
// wire                   [   7:0]         final_data                 ;
// bad_dot_improve #(
//     .IMG_HDISP                         (1280                      ),
//     .IMG_VDISP                         (960 )                     ) 
//  u_bad_dot_improve (
//     .clk                               (w_csi_rx_clk                ),
//     .rst_n                             (rstn_sys               ),
//     .per_frame_vsync                   (prepare_vsync             ),
//     .per_frame_href                    (prepare_valid             ),
//     .per_frame_hsync                   (prepare_valid             ),
//     .per_img_RAW                       (prepare_data       [   7:0]),

//     .post_frame_vsync                  (post_frame_vsync          ),
//     .post_frame_href                   (post_frame_href           ),
//     .post_frame_hsync                  (post_frame_hsync          ),
//     .final_data                        (final_data        [   7:0]) 
// );
// =========================================================================================================================================
// XYCrop
// ========================================================================================================================================= 
	wire			XYCrop_frame_vsync; 
	wire			XYCrop_frame_href;
	wire			XYCrop_frame_de;
	wire	[7:0]	XYCrop_frame_Gray;

    Sensor_Image_XYCrop
    #(
    .IMAGE_HSIZE_SOURCE                (1280 / CSI_STRB_WIDTH     ),
    .IMAGE_VSIZE_SOURCE                (960                       ),
    .IMAGE_HSIZE_TARGET                (1280 / CSI_STRB_WIDTH     ),
    .IMAGE_YSIZE_TARGET                (720                       ),
    .PIXEL_DATA_WIDTH                  (8                        ) //	32		 )
    )
    u_Sensor_Image_XYCrop
    (
		//	globel clock
    .clk                               (w_csi_rx_clk              ),//	image pixel clock
    .rst_n                             (rstn_sys                  ),//	system reset
		
		//CMOS Sensor interface
    .image_in_vsync                    (prepare_vsync           ),//H : Data Valid; L : Frame Sync(Set it by register)
    .image_in_href                     (prepare_valid       ),//H : Data vaild, L : Line Sync
    .image_in_de                       (prepare_valid            ),//H : Data Enable, L : Line Sync
    .image_in_data                     (prepare_data),//8 bits cmos data input
    // .image_in_vsync                    (post_frame_vsync           ),//H : Data Valid; L : Frame Sync(Set it by register)
    // .image_in_href                     (post_frame_href &&    post_frame_hsync        ),//H : Data vaild, L : Line Sync
    // .image_in_de                       (post_frame_href &&    post_frame_hsync             ),//H : Data Enable, L : Line Sync
    // .image_in_data                     (final_data),//8 bits cmos data input
		
    .image_out_vsync                   (XYCrop_frame_vsync        ),//H : Data Valid; L : Frame Sync(Set it by register)
    .image_out_href                    (XYCrop_frame_href         ),//H : Data vaild, L : Line Sync
    .image_out_de                      (XYCrop_frame_de           ),//H : Data Enable, L : Line Sync
    .image_out_data                    (XYCrop_frame_Gray         ) //8 bits cmos data input	
    );

	reg			r_XYCrop_frame_vsync = 0; 
	reg			r_XYCrop_frame_href = 0;
	reg			r_XYCrop_frame_de = 0;
	reg	[63:0]	r_XYCrop_frame_Gray = 0;
	
	always @(posedge w_csi_rx_clk) begin
		r_XYCrop_frame_vsync <= XYCrop_frame_vsync; 
		r_XYCrop_frame_href <= XYCrop_frame_href;
		r_XYCrop_frame_de <= XYCrop_frame_de;
		r_XYCrop_frame_Gray <= XYCrop_frame_Gray;
	end
	
	//	Data Write Assignment
	wire			cmos_frame_vsync = r_XYCrop_frame_vsync;                     //  cmos frame data vsync valid signal
	wire			cmos_frame_href = r_XYCrop_frame_href && r_XYCrop_frame_de;	 //  cmos frame data href vaild  signal
	wire	[7:0]	cmos_frame_Gray = r_XYCrop_frame_Gray; 

	//c1 crop data
wire                                    crop_vsync                 ;
wire                                    crop_valid                 ;
wire                   [   7:0]         crop_data                  ;
assign crop_vsync = r_XYCrop_frame_vsync;
assign crop_valid = cmos_frame_href ;
assign crop_data = cmos_frame_Gray;

// =========================================================================================================================================
// AE Module
// =========================================================================================================================================
wire ae_done;
wire [31:0] ae_cnt;
wire [31:0] ae_sum;
wire [31:0] ae_avg;
wire [16:0] cmos_exposure;
wire [7:0] cmos_gain;
wire [7:0] dgain;
wire cmos_change_start;
wire cmos_change_done = 1'b1; // 假设CMOS变化立即完成

isp_stat_ae #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0) // 0:RGGB
) u_isp_stat_ae (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    
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

// 添加AE算法模块
alg_ae #(
    .BITS(8)
) u_alg_ae (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    
    .in_vsync(crop_vsync),
    .stat_done(ae_done),
    .target_val(8'd30+scale_level),  // 目标亮度值设为80
    .pix_cnt(ae_cnt),
    .sum(ae_sum),
    
    .dgain(dgain),
    .cmos_change_start(cmos_change_start),
    .cmos_change_done(cmos_change_done),
    .cmos_exposure(cmos_exposure),
    .cmos_gain(cmos_gain)
);

// 实例化集成的I2C实时更新模块，用于AE参数更新
reg cmos_change_start_dly;

always @(posedge clk_sys or negedge rstn_sys) begin
    if (!rstn_sys) 
        cmos_change_start_dly <= 1'b0;
    else
        cmos_change_start_dly <= cmos_change_start;
end

// 曝光值拆分：根据规范，16位曝光值需要分别写入两个寄存器地址
// 低八位地址: 0x3048，高八位地址: 0x3049
// 增益控制寄存器地址: 0x3110
wire [15:0] ae_exposure = cmos_exposure;
wire [7:0] ae_gain = cmos_gain;

// I2C总线共享逻辑
// 当多个I2C主控制器共享同一物理总线时，必须通过逻辑合并实现正确连接
wire ae_i2c_sda_o;     // AE模块的SDA输出
wire ae_i2c_sda_oe;    // AE模块的SDA输出使能

// 定义寄存器地址
localparam EXPOSURE_LOW_ADDR  = 16'h3048;  // 曝光值低8位寄存器地址
localparam EXPOSURE_HIGH_ADDR = 16'h3049;  // 曝光值高8位寄存器地址
localparam GAIN_ADDR          = 16'h3110;  // 增益寄存器地址

// 用于存储需要更新的参数信息
reg [15:0] update_addr;
reg [7:0]  update_data;
reg        update_valid;
wire       config_busy;
wire       config_done;
wire       i2c_transfer_complete; // 新增：I2C单次传输完成信号

// 状态机用于依次更新曝光和增益参数
localparam UPDATE_IDLE    = 2'd0;
localparam UPDATE_EXP_LOW = 2'd1;
localparam UPDATE_EXP_HIGH= 2'd2;
localparam UPDATE_GAIN    = 2'd3;

// 超时计数器，1ms超时（96MHz时钟下约96000个周期）
localparam TIMEOUT_COUNT = 32'd192000;

reg [1:0] update_state;
reg i2c_transfer_complete_dly;
reg update_state_set_data; // 标记是否已设置地址和数据

// 超时计数器
reg [32:0] timeout_counter;
reg timeout_enabled;

always @(posedge clk_sys or negedge rstn_sys) begin
    if (!rstn_sys) begin
        update_state <= UPDATE_IDLE;
        update_valid <= 1'b0;
        update_addr  <= 16'd0;
        update_data  <= 8'd0;
        i2c_transfer_complete_dly <= 1'b0;
        update_state_set_data <= 1'b0;
        timeout_counter <= 32'd0;
        timeout_enabled <= 1'b0;
    end else begin
        i2c_transfer_complete_dly <= i2c_transfer_complete;
        
        // 超时计数器处理
        if (timeout_enabled) begin
            if (timeout_counter < TIMEOUT_COUNT) begin
                timeout_counter <= timeout_counter + 1;
            end
        end else begin
            timeout_counter <= 32'd0;
        end
        
        case (update_state)
            UPDATE_IDLE: begin
                update_valid <= 1'b0;
                update_state_set_data <= 1'b0;
                timeout_enabled <= 1'b0;
                update_data  <= ae_exposure[7:0];
                update_addr  <= EXPOSURE_LOW_ADDR;
                if (~cmos_change_start & cmos_change_start_dly) begin
                    // 开始更新曝光值低8位
                    update_state <= UPDATE_EXP_LOW;
                    timeout_enabled <= 1'b1; // 启用超时计数器
                end
            end
            
            UPDATE_EXP_LOW: begin
                // 等待配置完成后再进入下一步
				update_valid <= 1'b1;
                update_state_set_data <= 1'b1;
                if ((i2c_transfer_complete && !i2c_transfer_complete_dly) || (timeout_counter >= TIMEOUT_COUNT)) begin
                    update_valid <= 1'b0; // 清除valid信号
                    update_state <= UPDATE_EXP_HIGH;
                    update_state_set_data <= 1'b0;
                    timeout_enabled <= 1'b0; // 禁用超时计数器
                end
            end
            
            UPDATE_EXP_HIGH: begin
                // 在进入此状态时设置地址和数据
                if (!update_state_set_data) begin
                    update_addr  <= EXPOSURE_HIGH_ADDR;
                    update_data  <= ae_exposure[15:8];
                    update_valid <= 1'b1;
                    update_state_set_data <= 1'b1;
                    timeout_enabled <= 1'b1; // 启用超时计数器
                end 
                // 等待配置完成后再进入下一步
                if ((i2c_transfer_complete && !i2c_transfer_complete_dly) || (timeout_counter >= TIMEOUT_COUNT)) begin
                    update_valid <= 1'b0; // 清除valid信号
                    update_state <= UPDATE_GAIN;
                    update_state_set_data <= 1'b0;
                    timeout_enabled <= 1'b0; // 禁用超时计数器
                end
            end
            
            UPDATE_GAIN: begin
                // 在进入此状态时设置地址和数据
                if (!update_state_set_data) begin
                    update_addr  <= GAIN_ADDR;
                    update_data  <= ae_gain;
                    update_valid <= 1'b1;
                    update_state_set_data <= 1'b1;
                    timeout_enabled <= 1'b1; // 启用超时计数器
                end else begin
                    update_valid <= 1'b0; // 清除valid信号
                end
                // 等待配置完成后再进入下一步
                if ((i2c_transfer_complete && !i2c_transfer_complete_dly) || (timeout_counter >= TIMEOUT_COUNT)) begin
                    update_state <= UPDATE_IDLE;
                    update_state_set_data <= 1'b0;
                    timeout_enabled <= 1'b0; // 禁用超时计数器
                end
            end
        endcase
    end
end

// I2C总线共享逻辑
// 当多个I2C主控制器共享同一物理总线时，必须通过逻辑合并实现正确连接：
// I2C总线共享逻辑
// 当多个I2C主控制器共享同一物理总线时，必须通过逻辑合并实现正确连接：
// SDA输出数据采用"线与"逻辑（&运算）
// SDA输出使能采用"或"逻辑（|运算）
// SCL输出数据采用"线与"逻辑（&运算）
// SCL输出使能采用"或"逻辑（|运算）
assign csi_sda_o = ae_enable?(sc130_i2c_sda_o & ae_i2c_sda_o):sc130_i2c_sda_o;      // SDA输出"线与"逻辑
assign csi_sda_oe = ae_enable?(sc130_i2c_sda_oe | ae_i2c_sda_oe):sc130_i2c_sda_oe;   // SDA输出使能"或"逻辑
assign csi_scl_o = ae_enable?(sc130_i2c_scl_o & ae_i2c_scl_o):sc130_i2c_scl_o;      // SCL输出"线与"逻辑 (如果AE模块支持SCL输出)

i2c_timing_ctrl_16bit #(
    .CLK_FREQ(96_000_000),  // 系统时钟频率96MHz
    .I2C_FREQ(400_000)      // I2C频率100KHz
) u1_i2c_timing_ctrl_16bit (
    .clk(clk_sys),
    .rst_n(rstn_sys),
    .i2c_sclk(ae_i2c_scl_o),     // AE模块的SCL输出
    .i2c_sdat_IN(csi_sda_i),     // 共享的SDA输入信号
    .i2c_sdat_OUT(ae_i2c_sda_o), // AE模块的SDA输出
    .i2c_sdat_OE(ae_i2c_sda_oe), // AE模块的SDA输出使能
    .i2c_config_size(9'd1),      // 每次只写入一个寄存器
    .i2c_config_index(),         // 未使用
    .i2c_config_data({8'd0, update_addr, update_data}),  // 32位配置数据: 8位保留 + 16位地址 + 8位数据
    .i2c_config_done(config_done),  // 配置完成信号
    .i2c_transfer_complete(i2c_transfer_complete),
    .config_clk(clk_sys),
    .config_data({8'h6a, update_addr, update_data}),  // 24位配置数据: 8位ID + 16位地址 + 8位数据
    .config_data_valid(update_valid)

);

// 直接连接config_busy到update_valid，表示当update_valid为高时模块处于忙碌状态
assign config_busy = update_valid;

// =========================================================================================================================================
// P1_Bayer2rgb
// ========================================================================================================================================= 
wire 			w_rgb_vsync, w_rgb_hsync, w_rgb_href; 
wire 	[7:0] 	w_rgb_r, w_rgb_g, w_rgb_b; 
wire [11:0] cnt_bayer_pixel;
wire [11:0] cnt_bayer_row  ;
VIP_RAW8_RGB888 #(.IMG_HDISP(1280), .IMG_VDISP(720)) ori_bayer2rgb (
    .clk                               (w_csi_rx_clk                ),//cmos video pixel clock
    .rst_n                             (rstn_sys               ),//global reset
	
    .mirror                            (2'b11                     ),

		//CMOS YCbCr444 data output
    .per_frame_vsync                   (crop_vsync                ),//Prepared Image data vsync valid signal. Reset on falling edge. 
    .per_frame_hsync                   (crop_valid                ),//Prepared Image data href vaild  signal
    .per_frame_href                    (crop_valid                ),//Prepared Image data href vaild  signal
    .per_img_RAW                       (crop_data                 ),//Prepared Image data 8 Bit RAW Data

    .post_frame_vsync                  (w_rgb_vsync               ),//Processed Image data vsync valid signal
    .post_frame_hsync                  (w_rgb_hsync               ),//Processed Image data href vaild  signal
    .post_frame_href                   (w_rgb_href                ),//Processed Image data href vaild  signal
    .post_img_red                      (w_rgb_r                   ),//Prepared Image green data to be processed 
    .post_img_green                    (w_rgb_g                   ),//Prepared Image green data to be processed
    .post_img_blue                     (w_rgb_b                   ) //Prepared Image blue data to be processed
);

// =========================================================================================================================================
//RGB2YUV
// ========================================================================================================================================= 
wire									pre_yuv_vsync				   ;
wire									pre_yuv_hsync				   ;
wire									pre_yuv_href				   ;
wire                   [   7:0]         pre_yuv_rgb_r                ;
wire                   [   7:0]         pre_yuv_rgb_g                ;
wire                   [   7:0]         pre_yuv_rgb_b                ;
assign pre_yuv_vsync = w_rgb_vsync;
assign pre_yuv_hsync = w_rgb_hsync;
assign pre_yuv_href = w_rgb_href;
assign pre_yuv_rgb_r = w_rgb_r;
assign pre_yuv_rgb_g = w_rgb_g;
assign pre_yuv_rgb_b = w_rgb_b;

wire									pos_yuv_vsync					;
wire									pos_yuv_hsync					;
wire									pos_yuv_href					;
wire 					[	7:0]		pos_yuv_y						;
wire 					[	7:0]		pos_yuv_u						;
wire 					[	7:0]		pos_yuv_v						;

rgb2ycbcr u_rgb2cbcr (
    .clk                               (w_csi_rx_clk                ),//cmos video pixel clock
    .rst_n                             (rstn_sys               ),//global reset

    .pre_frame_vsync                   (pre_yuv_vsync               ),//Prepared Image data vsync valid signal
    .pre_frame_href                    (pre_yuv_href                ),//Prepared Image data href
	.pre_frame_de                      (pre_yuv_hsync               ),//Prepared Image data href vaild  signal
	.img_red                           (pre_yuv_rgb_r                ),//Prepared Image red data to be processed
	.img_green                         (pre_yuv_rgb_g                ),//Prepared Image green data to be processed
	.img_blue                          (pre_yuv_rgb_b                ),//Prepared Image blue data to be processed

	.post_frame_vsync                  (pos_yuv_vsync               ),//Processed Image data vsync valid signal
	.post_frame_href                   (pos_yuv_href                ),//Processed Image data href vaild  signal
	.post_frame_de                     (pos_yuv_hsync               ),//Processed Image data href vaild  signal
	.img_y                        	   (pos_yuv_y                   ),//Processed Image Y data
	.img_cb                            (pos_yuv_u                   ),//Processed Image U data
	.img_cr                            (pos_yuv_v                   )//Processed Image V data
);

// =========================================================================================================================================
//Median_filter
// ========================================================================================================================================= 
wire									pre_mf_vsync				   ;
wire									pre_mf_hsync				   ;
wire									pre_mf_href				   ;
wire                   [   7:0]         pre_mf_y                ;
wire                   [   7:0]         pre_mf_u                ;
wire                   [   7:0]         pre_mf_v                ;
assign pre_mf_vsync = pos_yuv_vsync;
assign pre_mf_hsync = pos_yuv_hsync;
assign pre_mf_href = pos_yuv_href;
assign pre_mf_y  = pos_yuv_y;
assign pre_mf_u  = pos_yuv_u;
assign pre_mf_v = pos_yuv_v;

wire									pos_mf_vsync					;
wire									pos_mf_hsync					;
wire									pos_mf_href					;
wire 					[	7:0]		pos_mf_y						;
wire 					[	7:0]		pos_mf_u						;
wire 					[	7:0]		pos_mf_v						;

vip_gray_median_filter u_vip_gray_median_filter (
	.clk_sys                               (w_csi_rx_clk                ),//cmos video pixel clock
	.rst_sys                             (~rstn_sys               ),//global reset

	//处理前图像数??
	.pre_frame_vsync (pre_mf_vsync),     // vsync信号
	.pre_frame_href (pre_mf_href),		 // href信号
	.pre_frame_clken (pre_mf_hsync),	 // data enable信号
	.pre_img_y (pre_mf_y),				 // 灰度数据
	.pre_img_u (pre_mf_u),				 // 色度数据
	.pre_img_v (pre_mf_v),			 	 // 色调数据
	//处理后的图像数据
	.pos_frame_vsync (pos_mf_vsync),     // vsync信号
	.pos_frame_href (pos_mf_href),		 // href信号
	.pos_frame_clken (pos_mf_hsync),	 // data enable信号
	.pos_img_y (pos_mf_y),				 // 灰度数据
	.pos_img_u (pos_mf_u),				 // 色度数据
	.pos_img_v (pos_mf_v)				 // 色调数据
);

// =========================================================================================================================================
//2D Noise Reduction Filter (Bilateral Filter)
// ========================================================================================================================================= 
wire									pre_2dnr_vsync				   ;
wire									pre_2dnr_hsync				   ;
wire									pre_2dnr_href				   ;
wire                   [   7:0]         pre_2dnr_y                ;
wire                   [   7:0]         pre_2dnr_u                ;
wire                   [   7:0]         pre_2dnr_v                ;
assign pre_2dnr_vsync = pos_yuv_vsync;
assign pre_2dnr_hsync = pos_yuv_hsync;
assign pre_2dnr_href = pos_yuv_href;
assign pre_2dnr_y  = pos_yuv_y;
assign pre_2dnr_u  = pos_yuv_u;
assign pre_2dnr_v = pos_yuv_v;

wire									pos_2dnr_vsync					;
wire									pos_2dnr_hsync					;
wire									pos_2dnr_href					;
wire 					[	7:0]		pos_2dnr_y						;
wire 					[	7:0]		pos_2dnr_u						;
wire 					[	7:0]		pos_2dnr_v						;

// Y通道2D降噪
isp_2dnr #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .WEIGHT_BITS(5)
) u_isp_2dnr_y (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    
    // 空域卷积核(7x7)参数，这里使用默认值
    .space_kernel(7*7*5'd1),
    // 值域卷积核拟合曲线横坐标(9个坐标点)
    .color_curve_x({8'd0, 8'd32, 8'd64, 8'd96, 8'd128, 8'd160, 8'd192, 8'd224, 8'd255}),
    // 值域卷积核拟合曲线纵坐标(9个坐标点)
    .color_curve_y({5'd31, 5'd28, 5'd24, 5'd20, 5'd16, 5'd12, 5'd8, 5'd4, 5'd0}),
    
    .in_href(pre_2dnr_href),
    .in_vsync(pre_2dnr_vsync),
    .in_data(pre_2dnr_y),
	.in_u(pre_2dnr_u),
	.in_v(pre_2dnr_v),
    
    .out_href(pos_2dnr_href),
    .out_vsync(pos_2dnr_vsync),
    .out_data(pos_2dnr_y),
	.out_u(pos_2dnr_u),
	.out_v(pos_2dnr_v)
);

// // U通道2D降噪
// isp_2dnr #(
//     .BITS(8),
//     .WIDTH(1280),
//     .HEIGHT(720),
//     .WEIGHT_BITS(5)
// ) u_isp_2dnr_u (
//     .pclk(w_csi_rx_clk),
//     .rst_n(rstn_sys),
    
//     // 空域卷积核(7x7)参数，这里使用默认值
//     .space_kernel(7*7*5'd1),
//     // 值域卷积核拟合曲线横坐标(9个坐标点)
//     .color_curve_x({8'd0, 8'd32, 8'd64, 8'd96, 8'd128, 8'd160, 8'd192, 8'd224, 8'd255}),
//     // 值域卷积核拟合曲线纵坐标(9个坐标点)
//     .color_curve_y({5'd31, 5'd28, 5'd24, 5'd20, 5'd16, 5'd12, 5'd8, 5'd4, 5'd0}),
    
//     .in_href(pre_2dnr_href),
//     .in_vsync(pre_2dnr_vsync),
//     .in_data(pre_2dnr_u),
    
//     .out_href(),
//     .out_vsync(),
//     .out_data(pos_2dnr_u)
// );

// // V通道2D降噪
// isp_2dnr #(
//     .BITS(8),
//     .WIDTH(1280),
//     .HEIGHT(720),
//     .WEIGHT_BITS(5)
// ) u_isp_2dnr_v (
//     .pclk(w_csi_rx_clk),
//     .rst_n(rstn_sys),
    
//     // 空域卷积核(7x7)参数，这里使用默认值
//     .space_kernel(7*7*5'd1),
//     // 值域卷积核拟合曲线横坐标(9个坐标点)
//     .color_curve_x({8'd0, 8'd32, 8'd64, 8'd96, 8'd128, 8'd160, 8'd192, 8'd224, 8'd255}),
//     // 值域卷积核拟合曲线纵坐标(9个坐标点)
//     .color_curve_y({5'd31, 5'd28, 5'd24, 5'd20, 5'd16, 5'd12, 5'd8, 5'd4, 5'd0}),
    
//     .in_href(pre_2dnr_href),
//     .in_vsync(pre_2dnr_vsync),
//     .in_data(pre_2dnr_v),
    
//     .out_href(),
//     .out_vsync(),
//     .out_data(pos_2dnr_v)
// );

// =========================================================================================================================================
//坏点矫正
// ========================================================================================================================================= 
wire									pre_dpc_vsync				   ;
wire									pre_dpc_href				   ;
wire									pre_dpc_hsync				   ;
wire                   [   7:0]         pre_dpc_y                ;
wire                   [   7:0]         pre_dpc_u                ;
wire                   [   7:0]         pre_dpc_v                ;
assign pre_dpc_vsync = pos_yuv_vsync;
assign pre_dpc_href = pos_yuv_href;
assign pre_dpc_hsync = pos_yuv_hsync;
assign pre_dpc_y  = pos_yuv_y;
assign pre_dpc_u  = pos_yuv_u;
assign pre_dpc_v = pos_yuv_v;

wire									pos_dpc_vsync					;
wire									pos_dpc_href					;
wire									pos_dpc_hsync					;  // 添加缺失的hsync信号
wire 					[	7:0]		pos_dpc_y						;
wire 					[	7:0]		pos_dpc_u						;
wire 					[	7:0]		pos_dpc_v						;

// Y通道DPC
isp_dpc #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0)
) u_isp_dpc_y (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    .threshold(8'd30),            // 坏点检测阈值，可根据需要调整

    .in_href(pre_dpc_href),
    .in_vsync(pre_dpc_vsync),
    .in_raw(pre_dpc_y),

    .out_href(pos_dpc_href),
    .out_vsync(pos_dpc_vsync),
    .out_raw(pos_dpc_y)
);

// U通道DPC
isp_dpc #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0)
) u_isp_dpc_u (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    .threshold(8'd30),            // 坏点检测阈值，可根据需要调整

    .in_href(pre_dpc_href),
    .in_vsync(pre_dpc_vsync),
    .in_raw(pre_dpc_u),

    .out_href(),
    .out_vsync(),     // U通道使用独立的vsync信号
    .out_raw(pos_dpc_u)
);

// V通道DPC
isp_dpc #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0)
) u_isp_dpc_v (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    .threshold(8'd30),            // 坏点检测阈值，可根据需要调整

    .in_href(pre_dpc_href),
    .in_vsync(pre_dpc_vsync),
    .in_raw(pre_dpc_v),

    .out_href(),
    .out_vsync(),     // V通道使用独立的vsync信号
    .out_raw(pos_dpc_v)
);

// 由于DPC模块没有单独的hsync输出，我们使用href信号作为hsync
assign pos_dpc_hsync = pos_dpc_href;

// =========================================================================================================================================
//BNR Filter (Gaussian Noise Reduction)
// ========================================================================================================================================= 
wire									pre_bnr_vsync				   ;
wire									pre_bnr_hsync				   ;
wire									pre_bnr_href				   ;
wire                   [   7:0]         pre_bnr_y                ;
wire                   [   7:0]         pre_bnr_u                ;
wire                   [   7:0]         pre_bnr_v                ;
assign pre_bnr_vsync = pos_yuv_vsync;
assign pre_bnr_hsync = pos_yuv_hsync;
assign pre_bnr_href = pos_yuv_href;
assign pre_bnr_y  = pos_yuv_y;
assign pre_bnr_u  = pos_yuv_u;
assign pre_bnr_v = pos_yuv_v;

wire									pos_bnr_vsync					;
wire									pos_bnr_hsync					;
wire									pos_bnr_href					;
wire 					[	7:0]		pos_bnr_y						;
wire 					[	7:0]		pos_bnr_u						;
wire 					[	7:0]		pos_bnr_v						;

// 对Y通道进行高斯降噪
isp_bnr #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0)
) u_isp_bnr_y (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    .nr_level(4'd1), // 设置NR级别为1，可根据需要调整(0-4)
    
    .in_href(pre_bnr_href),
    .in_vsync(pre_bnr_vsync),
    .in_raw(pre_bnr_y),
    
    .out_href(pos_bnr_href),
    .out_vsync(pos_bnr_vsync),
    .out_raw(pos_bnr_y)
);

// 对U通道进行高斯降噪
isp_bnr #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0)
) u_isp_bnr_u (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    .nr_level(4'd1), // 设置NR级别为1，可根据需要调整(0-4)
    
    .in_href(pre_bnr_href),
    .in_vsync(pre_bnr_vsync),
    .in_raw(pre_bnr_u),
    
    .out_href(),
    .out_vsync(),
    .out_raw(pos_bnr_u)
);

// 对V通道进行高斯降噪
isp_bnr #(
    .BITS(8),
    .WIDTH(1280),
    .HEIGHT(720),
    .BAYER(0)
) u_isp_bnr_v (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    .nr_level(4'd1), // 设置NR级别为1，可根据需要调整(0-4)
    
    .in_href(pre_bnr_href),
    .in_vsync(pre_bnr_vsync),
    .in_raw(pre_bnr_v),
    
    .out_href(),
    .out_vsync(),
    .out_raw(pos_bnr_v)
);

// 为了与Median_filter输出端口保持一致，增加以下信号定义
// assign pos_mf_vsync = pos_bnr_vsync;
// assign pos_mf_hsync = pos_bnr_hsync;
// assign pos_mf_href = pos_bnr_href;
reg                                     pos_filter_vsync              ;
reg                                     pos_filter_hsync              ;
reg                                     pos_filter_href               ;
reg                    [   7:0]         pos_filter_y                  ;
reg                    [   7:0]         pos_filter_u                  ;
reg                    [   7:0]         pos_filter_v                  ;
always @(*) begin
        case (model_select)
            2'b00: begin  // 中值滤波
                pos_filter_v     = pos_mf_v;
                pos_filter_u     = pos_mf_u;
                pos_filter_y     = pos_mf_y;
                pos_filter_href  = pos_mf_href;
                pos_filter_vsync = pos_mf_vsync;
                pos_filter_hsync = pos_mf_hsync;
            end
            2'b01: begin  // 高斯滤波
                pos_filter_v     = pos_bnr_v;
                pos_filter_u     = pos_bnr_u;
                pos_filter_y     = pos_bnr_y;
                pos_filter_href  = pos_bnr_href;
                pos_filter_vsync = pos_bnr_vsync;
                pos_filter_hsync = pos_bnr_hsync;
            end
            2'b11: begin  // 坏点矫正
                // pos_filter_v     = pos_2dnr_v;
                // pos_filter_u     = pos_2dnr_u;
                // pos_filter_y     = pos_2dnr_y;
                // pos_filter_href  = pos_2dnr_href;
                // pos_filter_vsync = pos_2dnr_vsync;
                // pos_filter_hsync = pos_2dnr_hsync;
				pos_filter_v     = pos_dpc_v;
                pos_filter_u     = pos_dpc_u;
                pos_filter_y     = pos_dpc_y;
                pos_filter_href  = pos_dpc_href;
                pos_filter_vsync = pos_dpc_vsync;
                pos_filter_hsync = pos_dpc_hsync;
				
            end
            default: begin
                pos_filter_v     = 8'd0;
                pos_filter_u     = 8'd0;
                pos_filter_y     = 8'd0;
                pos_filter_href  = 1'b0;
                pos_filter_vsync = 1'b0;
                pos_filter_hsync = 1'b0;
            end
        endcase
    end

   
// =========================================================================================================================================
//Reduce_Highlight
// ========================================================================================================================================= 


wire									pre_RH_vsync				   ;
wire									pre_RH_hsync				   ;
wire									pre_RH_href					   ;
wire                   [   7:0]         pre_RH_y                	   ;
wire                   [   7:0]         pre_RH_u                	   ;
wire                   [   7:0]         pre_RH_v               		   ;



assign pre_RH_vsync = median_filter_enable?pos_filter_vsync:pre_mf_vsync;
assign pre_RH_hsync = median_filter_enable?pos_filter_hsync:pre_mf_hsync;
assign pre_RH_href = median_filter_enable?pos_filter_href:pre_mf_href;
assign pre_RH_y = median_filter_enable?pos_filter_y:pre_mf_y;
assign pre_RH_u = median_filter_enable?pos_filter_u:pre_mf_u;
assign pre_RH_v = median_filter_enable?pos_filter_v:pre_mf_v;

wire									pos_RH_vsync					;
wire									pos_RH_hsync					;
wire									pos_RH_href					;
wire 					[	7:0]		pos_RH_y						;
wire 					[	7:0]		pos_RH_u						;
wire 					[	7:0]		pos_RH_v						;

vip_highlight_filter_top u_highlight_filter_top (
    .clk                               (w_csi_rx_clk                ),//cmos video pixel clock
    .rst_n                             (rstn_sys               ),//global reset

    //处理前图像数??
    .pre_frame_vsync (pre_RH_vsync),     // vsync信号
	.pre_frame_href (pre_RH_href),		 // href信号
	.pre_frame_clken (pre_RH_hsync),	 // data enable信号
	.pre_img_y (pre_RH_y),				 // 灰度数据
	.pre_img_cb (pre_RH_u),				 // 色度数据
	.pre_img_cr (pre_RH_v),			 	 // 色调数据
	//处理后的图像数据
	.pos_frame_vsync (pos_RH_vsync),     // vsync信号
	.pos_frame_href (pos_RH_href),		 // href信号
	.pos_frame_clken (pos_RH_hsync),	 // data enable信号
	.pos_img_y (pos_RH_y),				 // 灰度数据
	.pos_img_cb (pos_RH_u),				 // 色度数据
	.pos_img_cr (pos_RH_v)				 // 色调数据

);
// =========================================================================================================================================
//Sharpen
// ========================================================================================================================================= 
wire									pre_ee_vsync				   ;
wire									pre_ee_hsync				   ;
wire									pre_ee_href					   ;
wire                   [   7:0]         pre_ee_y                	   ;
wire                   [   7:0]         pre_ee_u                	   ;
wire                   [   7:0]         pre_ee_v               		   ;
assign pre_ee_vsync = extinction_enable?pos_RH_vsync:pre_RH_vsync;
assign pre_ee_hsync = extinction_enable?pos_RH_hsync:pre_RH_hsync;
assign pre_ee_href =extinction_enable?pos_RH_href:pre_RH_href;
assign pre_ee_y = extinction_enable?pos_RH_y:pre_RH_y;
assign pre_ee_u = extinction_enable?pos_RH_u:pre_RH_u;
assign pre_ee_v =extinction_enable?pos_RH_v:pre_RH_v;

wire									pos_ee_vsync				   ;
wire									pos_ee_hsync				   ;
wire									pos_ee_href				   	   ;
wire                   [   7:0]         pos_ee_y                	   ;
wire                   [   7:0]         pos_ee_u                	   ;
wire                   [   7:0]         pos_ee_v               		   ;

isp_ee u_isp_ee (
    .clk_sys                            (w_csi_rx_clk                ),//cmos video pixel clock
    .rst_sys                            (rstn_sys               ),//global reset

    //处理前图像数??
    .in_href (pre_ee_href),     // vsync信号
	.in_vsync (pre_ee_vsync),		 // href信号
	.in_hsync (pre_ee_hsync),	 // data enable信号
	.in_y (pre_ee_y),				 // 灰度数据
	.in_u (pre_ee_u),				 // 色度数据
	.in_v (pre_ee_v),			 	 // 色调数据
	//处理后的图像数据
	.out_href (pos_ee_href),     // vsync信号
	.out_vsync (pos_ee_vsync),		 // href信号
	.out_hsync (pos_ee_hsync),	 // data enable信号
	.out_y (pos_ee_y),				 // 灰度数据
	.out_u (pos_ee_u),				 // 色度数据
	.out_v (pos_ee_v)				 // 色调数据

);


// =========================================================================================================================================
//Gamma
// ========================================================================================================================================= 
reg [7:0] gamma_lut [0:255];

initial begin
    gamma_lut[0] = 8'h00;  gamma_lut[1] = 8'h00;  gamma_lut[2] = 8'h00;  gamma_lut[3] = 8'h00;
    gamma_lut[4] = 8'h00;  gamma_lut[5] = 8'h00;  gamma_lut[6] = 8'h00;  gamma_lut[7] = 8'h00;
    gamma_lut[8] = 8'h00;  gamma_lut[9] = 8'h00;  gamma_lut[10] = 8'h00; gamma_lut[11] = 8'h00;
    gamma_lut[12] = 8'h00; gamma_lut[13] = 8'h00; gamma_lut[14] = 8'h00; gamma_lut[15] = 8'h00;
    gamma_lut[16] = 8'h00; gamma_lut[17] = 8'h01; gamma_lut[18] = 8'h01; gamma_lut[19] = 8'h01;
    gamma_lut[20] = 8'h01; gamma_lut[21] = 8'h01; gamma_lut[22] = 8'h01; gamma_lut[23] = 8'h01;
    gamma_lut[24] = 8'h01; gamma_lut[25] = 8'h01; gamma_lut[26] = 8'h01; gamma_lut[27] = 8'h01;
    gamma_lut[28] = 8'h02; gamma_lut[29] = 8'h02; gamma_lut[30] = 8'h02; gamma_lut[31] = 8'h02;
    gamma_lut[32] = 8'h02; gamma_lut[33] = 8'h02; gamma_lut[34] = 8'h02; gamma_lut[35] = 8'h03;
    gamma_lut[36] = 8'h03; gamma_lut[37] = 8'h03; gamma_lut[38] = 8'h03; gamma_lut[39] = 8'h03;
    gamma_lut[40] = 8'h04; gamma_lut[41] = 8'h04; gamma_lut[42] = 8'h04; gamma_lut[43] = 8'h04;
    gamma_lut[44] = 8'h04; gamma_lut[45] = 8'h05; gamma_lut[46] = 8'h05; gamma_lut[47] = 8'h05;
    gamma_lut[48] = 8'h05; gamma_lut[49] = 8'h06; gamma_lut[50] = 8'h06; gamma_lut[51] = 8'h06;
    gamma_lut[52] = 8'h07; gamma_lut[53] = 8'h07; gamma_lut[54] = 8'h07; gamma_lut[55] = 8'h07;
    gamma_lut[56] = 8'h08; gamma_lut[57] = 8'h08; gamma_lut[58] = 8'h08; gamma_lut[59] = 8'h09;
    gamma_lut[60] = 8'h09; gamma_lut[61] = 8'h0a; gamma_lut[62] = 8'h0a; gamma_lut[63] = 8'h0a;
    gamma_lut[64] = 8'h0b; gamma_lut[65] = 8'h0b; gamma_lut[66] = 8'h0b; gamma_lut[67] = 8'h0c;
    gamma_lut[68] = 8'h0c; gamma_lut[69] = 8'h0d; gamma_lut[70] = 8'h0d; gamma_lut[71] = 8'h0d;
    gamma_lut[72] = 8'h0e; gamma_lut[73] = 8'h0e; gamma_lut[74] = 8'h0f; gamma_lut[75] = 8'h0f;
    gamma_lut[76] = 8'h10; gamma_lut[77] = 8'h10; gamma_lut[78] = 8'h11; gamma_lut[79] = 8'h11;
    gamma_lut[80] = 8'h12; gamma_lut[81] = 8'h12; gamma_lut[82] = 8'h13; gamma_lut[83] = 8'h13;
    gamma_lut[84] = 8'h14; gamma_lut[85] = 8'h14; gamma_lut[86] = 8'h15; gamma_lut[87] = 8'h15;
    gamma_lut[88] = 8'h16; gamma_lut[89] = 8'h16; gamma_lut[90] = 8'h17; gamma_lut[91] = 8'h17;
    gamma_lut[92] = 8'h18; gamma_lut[93] = 8'h18; gamma_lut[94] = 8'h19; gamma_lut[95] = 8'h19;
    gamma_lut[96] = 8'h1a; gamma_lut[97] = 8'h1a; gamma_lut[98] = 8'h1b; gamma_lut[99] = 8'h1b;
    gamma_lut[100] = 8'h1c; gamma_lut[101] = 8'h1c; gamma_lut[102] = 8'h1d; gamma_lut[103] = 8'h1d;
    gamma_lut[104] = 8'h1e; gamma_lut[105] = 8'h1f; gamma_lut[106] = 8'h1f; gamma_lut[107] = 8'h20;
    gamma_lut[108] = 8'h20; gamma_lut[109] = 8'h21; gamma_lut[110] = 8'h21; gamma_lut[111] = 8'h22;
    gamma_lut[112] = 8'h23; gamma_lut[113] = 8'h23; gamma_lut[114] = 8'h24; gamma_lut[115] = 8'h24;
    gamma_lut[116] = 8'h25; gamma_lut[117] = 8'h26; gamma_lut[118] = 8'h26; gamma_lut[119] = 8'h27;
    gamma_lut[120] = 8'h28; gamma_lut[121] = 8'h28; gamma_lut[122] = 8'h29; gamma_lut[123] = 8'h2a;
    gamma_lut[124] = 8'h2a; gamma_lut[125] = 8'h2b; gamma_lut[126] = 8'h2c; gamma_lut[127] = 8'h2c;
    gamma_lut[128] = 8'h2d; gamma_lut[129] = 8'h2e; gamma_lut[130] = 8'h2e; gamma_lut[131] = 8'h2f;
    gamma_lut[132] = 8'h30; gamma_lut[133] = 8'h30; gamma_lut[134] = 8'h31; gamma_lut[135] = 8'h32;
    gamma_lut[136] = 8'h32; gamma_lut[137] = 8'h33; gamma_lut[138] = 8'h34; gamma_lut[139] = 8'h35;
    gamma_lut[140] = 8'h35; gamma_lut[141] = 8'h36; gamma_lut[142] = 8'h37; gamma_lut[143] = 8'h38;
    gamma_lut[144] = 8'h38; gamma_lut[145] = 8'h39; gamma_lut[146] = 8'h3a; gamma_lut[147] = 8'h3b;
    gamma_lut[148] = 8'h3c; gamma_lut[149] = 8'h3c; gamma_lut[150] = 8'h3d; gamma_lut[151] = 8'h3e;
    gamma_lut[152] = 8'h3f; gamma_lut[153] = 8'h40; gamma_lut[154] = 8'h41; gamma_lut[155] = 8'h42;
    gamma_lut[156] = 8'h42; gamma_lut[157] = 8'h43; gamma_lut[158] = 8'h44; gamma_lut[159] = 8'h45;
    gamma_lut[160] = 8'h46; gamma_lut[161] = 8'h47; gamma_lut[162] = 8'h48; gamma_lut[163] = 8'h49;
    gamma_lut[164] = 8'h4a; gamma_lut[165] = 8'h4b; gamma_lut[166] = 8'h4c; gamma_lut[167] = 8'h4d;
    gamma_lut[168] = 8'h4e; gamma_lut[169] = 8'h4f; gamma_lut[170] = 8'h50; gamma_lut[171] = 8'h51;
    gamma_lut[172] = 8'h52; gamma_lut[173] = 8'h53; gamma_lut[174] = 8'h54; gamma_lut[175] = 8'h55;
    gamma_lut[176] = 8'h56; gamma_lut[177] = 8'h57; gamma_lut[178] = 8'h58; gamma_lut[179] = 8'h59;
    gamma_lut[180] = 8'h5a; gamma_lut[181] = 8'h5b; gamma_lut[182] = 8'h5c; gamma_lut[183] = 8'h5d;
    gamma_lut[184] = 8'h5e; gamma_lut[185] = 8'h5f; gamma_lut[186] = 8'h60; gamma_lut[187] = 8'h61;
    gamma_lut[188] = 8'h62; gamma_lut[189] = 8'h63; gamma_lut[190] = 8'h64; gamma_lut[191] = 8'h65;
    gamma_lut[192] = 8'h66; gamma_lut[193] = 8'h67; gamma_lut[194] = 8'h69; gamma_lut[195] = 8'h6a;
    gamma_lut[196] = 8'h6b; gamma_lut[197] = 8'h6c; gamma_lut[198] = 8'h6d; gamma_lut[199] = 8'h6e;
    gamma_lut[200] = 8'h6f; gamma_lut[201] = 8'h70; gamma_lut[202] = 8'h71; gamma_lut[203] = 8'h72;
    gamma_lut[204] = 8'h73; gamma_lut[205] = 8'h74; gamma_lut[206] = 8'h75; gamma_lut[207] = 8'h76;
    gamma_lut[208] = 8'h78; gamma_lut[209] = 8'h79; gamma_lut[210] = 8'h7a; gamma_lut[211] = 8'h7b;
    gamma_lut[212] = 8'h7c; gamma_lut[213] = 8'h7d; gamma_lut[214] = 8'h7e; gamma_lut[215] = 8'h7f;
    gamma_lut[216] = 8'h80; gamma_lut[217] = 8'h81; gamma_lut[218] = 8'h82; gamma_lut[219] = 8'h83;
    gamma_lut[220] = 8'h84; gamma_lut[221] = 8'h85; gamma_lut[222] = 8'h86; gamma_lut[223] = 8'h87;
    gamma_lut[224] = 8'h89; gamma_lut[225] = 8'h8a; gamma_lut[226] = 8'h8b; gamma_lut[227] = 8'h8c;
    gamma_lut[228] = 8'h8d; gamma_lut[229] = 8'h8e; gamma_lut[230] = 8'h8f; gamma_lut[231] = 8'h90;
    gamma_lut[232] = 8'h91; gamma_lut[233] = 8'h92; gamma_lut[234] = 8'h93; gamma_lut[235] = 8'h94;
    gamma_lut[236] = 8'h95; gamma_lut[237] = 8'h96; gamma_lut[238] = 8'h97; gamma_lut[239] = 8'h98;
    gamma_lut[240] = 8'h99; gamma_lut[241] = 8'h9a; gamma_lut[242] = 8'h9b; gamma_lut[243] = 8'h9c;
    gamma_lut[244] = 8'h9e; gamma_lut[245] = 8'h9f; gamma_lut[246] = 8'ha0; gamma_lut[247] = 8'ha1;
    gamma_lut[248] = 8'ha2; gamma_lut[249] = 8'ha3; gamma_lut[250] = 8'ha4; gamma_lut[251] = 8'ha5;
    gamma_lut[252] = 8'ha7; gamma_lut[253] = 8'ha8; gamma_lut[254] = 8'ha9; gamma_lut[255] = 8'hff;
end

wire									pre_Gamma_vsync				   ;
wire									pre_Gamma_hsync				   ;
wire									pre_Gamma_href					   ;
wire                   [   7:0]         pre_Gamma_y                	   ;
wire                   [   7:0]         pre_Gamma_u                	   ;
wire                   [   7:0]         pre_Gamma_v               		   ;

assign pre_Gamma_vsync = pos_ee_vsync;
assign pre_Gamma_hsync = pos_ee_hsync;
assign pre_Gamma_href = pos_ee_href;
assign pre_Gamma_y = pos_ee_y;
assign pre_Gamma_u = pos_ee_u;
assign pre_Gamma_v = pos_ee_v;

reg [7:0] init_cnt;
wire init_done = (init_cnt == 8'd255);
reg [7:0] cfg_table_addr;
reg [7:0] cfg_table_wdata;
reg cfg_table_wen;
wire cfg_table_ren = 1'b0;
wire [7:0] cfg_table_rdata;

always @(posedge w_csi_rx_clk or negedge rstn_sys) begin
    if (!rstn_sys) begin
        init_cnt <= 0;
        cfg_table_wen <= 0;
    end
    else if (!init_done) begin
        cfg_table_addr <= init_cnt;
        cfg_table_wdata <= gamma_lut[init_cnt]; // 使用步骤1的数组
        cfg_table_wen <= 1;
        init_cnt <= init_cnt + 1;
    end
    else cfg_table_wen <= 0;
end

isp_gamma #(
    .BITS(8),
    .CFG_TABLE_BITS(8)
) u_gamma (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),
    // 数据通道
    .in_href(pre_Gamma_href),
    .in_vsync(pre_Gamma_vsync),
    .in_data(pre_Gamma_y),
    .out_href(pos_Gamma_href),
    .out_vsync(pos_Gamma_vsync	),
    .out_data(pos_Gamma_y),
    // 配置接口（连接初始化逻辑）
    .cfg_table_clk(w_csi_rx_clk),
    .cfg_table_wen(cfg_table_wen),
    .cfg_table_ren(cfg_table_ren),
    .cfg_table_addr(cfg_table_addr),
    .cfg_table_wdata(cfg_table_wdata),
    .cfg_table_rdata(cfg_table_rdata)
);

data_delay #(8, 2) gamma_delay_u (w_csi_rx_clk, rstn_sys, pre_Gamma_u, pos_Gamma_u); //gamma模块内部延迟2拍
data_delay #(8, 2) gamma_delay_v (w_csi_rx_clk, rstn_sys, pre_Gamma_v, pos_Gamma_v);

wire									pos_Gamma_vsync				   ;
wire									pos_Gamma_hsync				   ;
wire									pos_Gamma_href					   ;
wire                   [   7:0]         pos_Gamma_y                	   ;
wire                   [   7:0]         pos_Gamma_u                	   ;
wire                   [   7:0]         pos_Gamma_v               		   ;


// =========================================================================================================================================
// UART Control Module
// =========================================================================================================================================
// UART控制信号
wire uart_ae_enable;              // AE算法使能
wire uart_color_correction_enable;  // 颜色矫正使能
wire uart_median_filter_enable;     // 中值滤波使能
wire uart_extinction_enable;        // 消光算法使能
wire uart_sharpen_enable;           // 锐化使能
wire [1:0]uart_model_select;        // 滤波模式使能
wire [7:0] uart_scale_level;        // 缩放等级(0-100)

// 实例化uart_control_top模块
uart_control_top u_uart_control_top (
    .clk_24M           (clk_24m),              // 24MHz时钟
    .sys_clk_96M       (clk_sys),              // 96MHz系统时钟
    .sys_rst_n         (rstn_sys),             // 系统复位
    
    .fpga_rxd_0        (fpga_rxd),            // UART接收端口0
    .fpga_txd_0        (fpga_txd),            // UART发送端口0
    // .fpga_rxd_1        (fpga_rxd_1),           // UART接收端口1
    // .fpga_txd_1        (fpga_txd_1),           // UART发送端口1
    
    .ae_enable         (uart_ae_enable),              // AE算法使能
    .color_correction_enable(uart_color_correction_enable),  // 颜色矫正使能
    .median_filter_enable(uart_median_filter_enable),     // 中值滤波使能
    .extinction_enable (uart_extinction_enable),        // 消光算法使能
    .sharpen_enable    (uart_sharpen_enable),           // 锐化使能
    .model_select      (uart_model_select),             // 模式选择
    .scale_level       (uart_scale_level)               // 缩放等级(0-100)
);

// =========================================================================================================================================
// Algorithm Control Signals
// =========================================================================================================================================
// 控制信号默认值（可以通过UART修改）
reg ae_enable = 1'b1;              // AE算法使能
reg color_correction_enable = 1'b1;  // 颜色矫正使能
reg median_filter_enable = 1'b1;     // 中值滤波使能
reg extinction_enable = 1'b1;        // 消光算法使能
reg sharpen_enable = 1'b1;           // 锐化使能
reg [1:0]model_select = 2'b00;             // 模式选择：00中值滤波；01高斯滤波；11双边滤波
reg [7:0] scale_level = 8'd50;       // 缩放等级(0-100)

// 延时寄存器，用于在帧结束后更新控制信号
reg [2:0] vsync_d = 3'b000;         // 帧同步信号延时寄存器
reg update_en = 1'b0;               // 控制信号更新使能

// 在帧结束后延时三个周期更新控制信号，确保数据传输稳定
always @(posedge clk_sys or negedge rstn_sys) begin
    if (!rstn_sys) begin
        vsync_d <= 3'b000;
        update_en <= 1'b0;
        ae_enable <= 1'b1;
        color_correction_enable <= 1'b1;
        median_filter_enable <= 1'b1;
        extinction_enable <= 1'b1;
        sharpen_enable <= 1'b1;
        model_select <= 2'b00;
        scale_level <= 8'd50;
    end else begin
        // 延时帧同步信号
        vsync_d <= {vsync_d[1:0], rgb_vsync};
        
        // 当检测到帧结束时（rgb_vsync下降沿），使能更新
        if (vsync_d[2] == 1'b1 && vsync_d[1] == 1'b0) begin
            update_en <= 1'b1;
        end
        
        // 延时三个周期后更新控制信号，并关闭更新使能
        if (update_en) begin
            ae_enable <= uart_ae_enable;
            color_correction_enable <= uart_color_correction_enable;
            median_filter_enable <= uart_median_filter_enable;
            extinction_enable <= uart_extinction_enable;
            sharpen_enable <= uart_sharpen_enable;
            model_select <= uart_model_select;
            scale_level <= uart_scale_level;
            update_en <= 1'b0;
        end
    end
end
// =========================================================================================================================================
//YUV2RGB
// ========================================================================================================================================= 
wire									pre_rgb_vsync				   ;
wire									pre_rgb_hsync				   ;
wire									pre_rgb_href				   ;
wire                   [   7:0]         pre_rgb_y                  ;
wire                   [   7:0]         pre_rgb_u                  ;
wire                   [   7:0]         pre_rgb_v                  ;
assign pre_rgb_vsync = sharpen_enable?pos_ee_vsync:pre_ee_vsync;
assign pre_rgb_href =sharpen_enable?pos_ee_href:pre_ee_href;
assign pre_rgb_y = sharpen_enable?pos_ee_y:pre_ee_y;
assign pre_rgb_u = sharpen_enable?pos_ee_u:pre_ee_u;
assign pre_rgb_v = sharpen_enable?pos_ee_v:pre_ee_v;

wire  pos_rgb_vsync;
wire  pos_rgb_hsync;
wire  pos_rgb_href;
wire [7:0] pos_rgb_r;
wire [7:0] pos_rgb_g;
wire [7:0] pos_rgb_b;

vip_yuv2rgb #(.BITS(8),.WIDTH(1280),.HEIGHT(720)) u_yuv2rgb
(
    .pclk                               (w_csi_rx_clk                ),//cmos video pixel clock
    .rst_n                             (rstn_sys               		),//global reset

    .in_href						   (pre_rgb_href                ),//Prepared Image data href
	.in_vsync						   (pre_rgb_vsync               ),//Prepared Image data vsync valid signal
	.in_y							   (pre_rgb_y                   ),//Prepared Image Y data
	.in_u							   (pre_rgb_u                   ),//Prepared Image U data
	.in_v							   (pre_rgb_v                   ),//Prepared Image V data

	.out_href						   (pos_rgb_href                ),//Processed Image data href vaild  signal
	.out_vsync						   (pos_rgb_vsync               ),//Processed Image data vsync valid signal
	.out_rgb						   ({pos_rgb_r, pos_rgb_g, pos_rgb_b})//Processed Image RGB data
);

// =========================================================================================================================================
//P2_MWB
// ========================================================================================================================================= 
//c1

wire                                    rgb_vsync                  ;
wire                                    rgb_valid                  ;
wire                   [  23:0]         rgb_data                   ;
wire                   [   7:0]         rgb_r                ;
wire                   [   7:0]         rgb_g                ;
wire                   [   7:0]         rgb_b                ;

wire									w_mwb_vsync				   ;
wire									w_mwb_hsync				   ;
wire									w_mwb_href				   ;
wire                   [   7:0]         w_mwb_rgb_r                ;
wire                   [   7:0]         w_mwb_rgb_g                ;
wire                   [   7:0]         w_mwb_rgb_b                ;

wire     [17:0]     w_rgb_r_mult = pos_rgb_r * 409; 
wire     [17:0]     w_rgb_b_mult = pos_rgb_b * 384; 
assign w_mwb_rgb_r = w_rgb_r_mult[17:16] ? 8'hFF : w_rgb_r_mult[15: 8]; 
assign w_mwb_rgb_g = pos_rgb_g; 
assign w_mwb_rgb_b = w_rgb_b_mult[17:16] ? 8'hFF : w_rgb_b_mult[15: 8]; 
assign w_mwb_vsync = pos_rgb_vsync;
assign w_mwb_href = pos_rgb_href;
// =========================================================================================================================================
//AWB
// ========================================================================================================================================= 

wire 			w_awb_vsync, w_awb_href;

wire                   [   7:0]         w_awb_rgb_r                ;
wire                   [   7:0]         w_awb_rgb_g                ;
wire                   [   7:0]         w_awb_rgb_b                ;

AWB_top u_AWB (
    .pclk(w_csi_rx_clk),
    .rst_n(rstn_sys),

    .in_href(w_mwb_href),
    .in_vsync(w_mwb_vsync),
    .in_r(w_mwb_rgb_r),
    .in_g(w_mwb_rgb_g),
    .in_b(w_mwb_rgb_b),

    .out_href(w_awb_href),
	.out_vsync(w_awb_vsync),
	.out_r(w_awb_rgb_r),
	.out_g(w_awb_rgb_g),
	.out_b(w_awb_rgb_b)
);

//Pre_DDR
assign rgb_r = color_correction_enable?w_awb_rgb_r:pos_rgb_r;
assign rgb_g = color_correction_enable?w_awb_rgb_g:pos_rgb_g;
assign rgb_b = color_correction_enable?w_awb_rgb_b:pos_rgb_b;

assign rgb_vsync = color_correction_enable?w_awb_vsync:pos_rgb_vsync;//tobechange
assign rgb_valid = color_correction_enable?w_awb_href:pos_rgb_href;//tobechange
assign rgb_data = {rgb_r,rgb_g,rgb_b};

// =========================================================================================================================================
// DDR Ctrl
// ========================================================================================================================================= 
	wire                            lcd_de;
	wire                            lcd_hs;      
	wire                            lcd_vs;
	wire 					  lcd_request; 
	wire            [7:0]           lcd_red, lcd_red2;
	wire            [7:0]           lcd_green, lcd_green2;
	wire            [7:0]           lcd_blue, lcd_blue2;
	wire            [31:0]          lcd_data;


	assign w_ddr3_awid = 0; 
	assign w_ddr3_wid = 0; 
	
	wire 			w_wframe_vsync; 
	wire 	[7:0] 	w_axi_tp; 
	
	axi4_ctrl #(.C_RD_END_ADDR(1280 * 720 *4), .C_W_WIDTH(32), .C_R_WIDTH(32), .C_ID_LEN(4)) u_axi4_ctrl (

		.axi_clk        (w_ddr3_ui_clk            ),
		.axi_reset      (w_ddr3_ui_rst            ),

		.axi_awaddr     (w_ddr3_awaddr       ),
		.axi_awlen      (w_ddr3_awlen        ),
		.axi_awvalid    (w_ddr3_awvalid      ),
		.axi_awready    (w_ddr3_awready      ),

		.axi_wdata      (w_ddr3_wdata        ),
		.axi_wstrb      (w_ddr3_wstrb        ),
		.axi_wlast      (w_ddr3_wlast        ),
		.axi_wvalid     (w_ddr3_wvalid       ),
		.axi_wready     (w_ddr3_wready       ),

		.axi_bid        (0          ),
		.axi_bresp      (0        ),
		.axi_bvalid     (1       ),

		.axi_arid       (w_ddr3_arid         ),
		.axi_araddr     (w_ddr3_araddr       ),
		.axi_arlen      (w_ddr3_arlen        ),
		.axi_arvalid    (w_ddr3_arvalid      ),
		.axi_arready    (w_ddr3_arready      ),

		.axi_rid        (w_ddr3_rid          ),
		.axi_rdata      (w_ddr3_rdata        ),
		.axi_rresp      (0        ),
		.axi_rlast      (w_ddr3_rlast        ),
		.axi_rvalid     (w_ddr3_rvalid       ),
		.axi_rready     (w_ddr3_rready       ),

		.wframe_pclk    (w_csi_rx_clk          ),
		.wframe_vsync   (rgb_vsync), //w_wframe_vsync   ),		//	Writter VSync. Flush on rising edge. Connect to EOF. 
		.wframe_data_en (rgb_valid   ),
		.wframe_data    ({8'b0,rgb_data} ),
		
		.rframe_pclk    (clk_pixel            ),
		.rframe_vsync   (~lcd_vs             ),		//	Reader VSync. Flush on rising edge. Connect to ~EOF. 
		.rframe_data_en (lcd_request             ),
		.rframe_data    (lcd_data           ),
		
		.tp_o 		(w_axi_tp)
	);
	// assign led_o[3:0] = w_axi_tp; 
// =========================================================================================================================================
// lcd_driver
// ========================================================================================================================================= 
wire data_enable2;


    lcd_driver u_lcd_driver
    (
	    //  global clock
    .clk                               (clk_pixel                 ),
    .rst_n                             (rstn_pixel                ),
	    
	    //  lcd interface
    .lcd_dclk                          (                          ),
    .lcd_blank                         (                          ),
    .lcd_sync                          (                          ),
    .lcd_request                       (lcd_request               ),//	Request data 1 cycle ahead. 
    .lcd_hs                            (lcd_hs                    ),
    .lcd_vs                            (lcd_vs                    ),
    .lcd_en                            (lcd_de                    ),
    .lcd_rgb                           ({lcd_red2,lcd_green2,lcd_blue2, lcd_red,lcd_green,lcd_blue}),
	    
	    //  user interface
    .lcd_data                          ({lcd_data[23:0] ,lcd_data[23:0]}),
    .lcd_xpos                          (x_pos                     ),
    .lcd_ypos                          (y_pos                     ) 
    );
	
	// wire [23:0] hdmi_data = (data_enable||data_enable2)? char_data : {lcd_red,lcd_green,lcd_blue}    ;
	wire [23:0] hdmi_data =  {lcd_red,lcd_green,lcd_blue}    ;
// =========================================================================================================================================
// BoundCrop
// ========================================================================================================================================= 

wire                                    w_rgb_vs_o, w_rgb_hs_o, w_rgb_de_o;
wire                   [  23:0]         w_rgb_data_o               ;
FrameBoundCrop #(.SKIP_ROWS(4),.SKIP_COLS(2),.TOTAL_ROWS(720),.TOTAL_COLS(1280)) inst_FrameCrop(
    .clk_i                             (clk_pixel                 ),
    .rst_i                             (~rstn_pixel                ),
	
    .hs_i                              (lcd_hs              ),
    .vs_i                              (lcd_vs              ),
    .de_i                              (lcd_de              ),
    .data_i                            (hdmi_data            ),
	
    .vs_o                              (w_rgb_vs_o                ),
    .hs_o                              (w_rgb_hs_o                ),
    .de_o                              (w_rgb_de_o                ),
    .data_o                            (w_rgb_data_o              ) 
);
	
// =========================================================================================================================================
// HDMI Interface
// ========================================================================================================================================= 
	assign hdmi_txd0_rst_o = rst_pixel; 
	assign hdmi_txd1_rst_o = rst_pixel; 
	assign hdmi_txd2_rst_o = rst_pixel; 
	assign hdmi_txc_rst_o = rst_pixel; 
	
	assign hdmi_txd0_oe = 1'b1; 
	assign hdmi_txd1_oe = 1'b1; 
	assign hdmi_txd2_oe = 1'b1; 
	assign hdmi_txc_oe = 1'b1; 
	
	//-------------------------------------
	//Digilent HDMI-TX IP Modified by CB elec.
    rgb2dvi #(.ENABLE_OSERDES(0)) u_rgb2dvi
    (
    .oe_i                              (1                         ),//	Always enable output
    .bitflip_i                         (4'b0000                   ),//	Reverse clock & data lanes. 
		
    .aRst                              (1'b0                      ),
    .aRst_n                            (1'b1                      ),
		
    .PixelClk                          (clk_pixel                 ),//pixel clk = 74.25M
    .SerialClk                         (                          ),//pixel clk *5 = 371.25M
		
    .vid_pVSync                        (w_rgb_vs_o                    ),
    .vid_pHSync                        (w_rgb_hs_o                    ),
    .vid_pVDE                          (w_rgb_de_o                    ),
    .vid_pData                         (w_rgb_data_o),
		
    .txc_o                             (hdmi_txc_o                ),
    .txd0_o                            (hdmi_txd0_o               ),
    .txd1_o                            (hdmi_txd1_o               ),
    .txd2_o                            (hdmi_txd2_o               ) 
    );
		
	






	
	
endmodule


