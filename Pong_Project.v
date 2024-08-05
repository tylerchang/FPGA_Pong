module Pong_Project
	(input i_Clk,
	input i_UART_RX,

	// Push Buttons
	input  i_Switch_1,
	input  i_Switch_2,
	input  i_Switch_3,
	input  i_Switch_4,

	// VGA
	output o_VGA_HSync,
	output o_VGA_VSync,
	output o_VGA_Red_0,
	output o_VGA_Red_1,
	output o_VGA_Red_2,
	output o_VGA_Grn_0,
	output o_VGA_Grn_1,
	output o_VGA_Grn_2,
	output o_VGA_Blu_0,
	output o_VGA_Blu_1,
	output o_VGA_Blu_2,

	// 7 Segment Display for points
	output o_Segment1_A,
	output o_Segment1_B,
	output o_Segment1_C,
	output o_Segment1_D,
	output o_Segment1_E,
	output o_Segment1_F,
	output o_Segment1_G,
	output o_Segment2_A,
	output o_Segment2_B,
	output o_Segment2_C,
	output o_Segment2_D,
	output o_Segment2_E,
	output o_Segment2_F,
	output o_Segment2_G
	);
	
	// VGA Constants to set Frame Size
	parameter c_VIDEO_WIDTH = 3;
	parameter c_TOTAL_COLS  = 800;
	parameter c_TOTAL_ROWS  = 525;
	parameter c_ACTIVE_COLS = 640;
	parameter c_ACTIVE_ROWS = 480;
	
	// Common VGA Signals
	wire [c_VIDEO_WIDTH-1:0] w_Red_Video_Pong, w_Red_Video_Porch;
	wire [c_VIDEO_WIDTH-1:0] w_Grn_Video_Pong, w_Grn_Video_Porch;
	wire [c_VIDEO_WIDTH-1:0] w_Blu_Video_Pong, w_Blu_Video_Porch;
	
	// Point tracker
	wire [3:0] w_P1_Score;
	wire [3:0] w_P2_Score; 
	// reg [3:0] r_P1_Score = 4'b0000;
	// reg [3:0] r_P2_Score = 4'b0000;
	// assign r_P1_Score = w_P1_Score;
	// assign r_P2_Score = w_P2_Score;
	
	// P1 Display Points wires
	wire w_Segment1_A;
	wire w_Segment1_B;
	wire w_Segment1_C;
	wire w_Segment1_D;
	wire w_Segment1_E;
	wire w_Segment1_F;
	wire w_Segment1_G;
	
	// P2 Display Points wires
	wire w_Segment2_A;
	wire w_Segment2_B;
	wire w_Segment2_C;
	wire w_Segment2_D;
	wire w_Segment2_E;
	wire w_Segment2_F;
	wire w_Segment2_G;
	
	
	Binary_To_7Segment P1_Points_Display
	(.i_Clk(i_Clk),
	 .i_Binary_Num(w_P1_Score),
	 .o_Segment_A(w_Segment1_A),
	 .o_Segment_B(w_Segment1_B),
	 .o_Segment_C(w_Segment1_C),
	 .o_Segment_D(w_Segment1_D),
	 .o_Segment_E(w_Segment1_E),
	 .o_Segment_F(w_Segment1_F),
	 .o_Segment_G(w_Segment1_G)
	 );
	 
	Binary_To_7Segment P2_Points_Display
	(.i_Clk(i_Clk),
	 .i_Binary_Num(w_P2_Score),
	 .o_Segment_A(w_Segment2_A),
	 .o_Segment_B(w_Segment2_B),
	 .o_Segment_C(w_Segment2_C),
	 .o_Segment_D(w_Segment2_D),
	 .o_Segment_E(w_Segment2_E),
	 .o_Segment_F(w_Segment2_F),
	 .o_Segment_G(w_Segment2_G)
	 );
	
	// 25,000,000 / 115,200 = 217
	UART_RX #(.CLKS_PER_BIT(217)) UART_RX_Inst
	(.i_Clock(i_Clk),
	.i_RX_Serial(i_UART_RX),
	.o_RX_DV(w_RX_DV),
	.o_RX_Byte());
	
	// Generates Sync Pulses to run VGA
	VGA_Sync_Pulses #(.TOTAL_COLS(c_TOTAL_COLS),
					.TOTAL_ROWS(c_TOTAL_ROWS),
					.ACTIVE_COLS(c_ACTIVE_COLS),
					.ACTIVE_ROWS(c_ACTIVE_ROWS)) VGA_Sync_Pulses_Inst 
	(.i_Clk(i_Clk),
	.o_HSync(w_HSync_VGA),
	.o_VSync(w_VSync_VGA),
	.o_Col_Count(),
	.o_Row_Count()
	);
	
	// Making sure all switches get quality presses
	Debounce_Switch Switch_1
	(.i_Clk(i_Clk),
	 .i_Switch(i_Switch_1),
	 .o_Switch(w_Switch_1));

	Debounce_Switch Switch_2
	(.i_Clk(i_Clk),
	 .i_Switch(i_Switch_2),
	 .o_Switch(w_Switch_2));

	Debounce_Switch Switch_3
	(.i_Clk(i_Clk),
	 .i_Switch(i_Switch_3),
	 .o_Switch(w_Switch_3));

	Debounce_Switch Switch_4
	(.i_Clk(i_Clk),
	 .i_Switch(i_Switch_4),
	 .o_Switch(w_Switch_4));
	 
	// PONG Module
	Pong_Top #(.c_TOTAL_COLS(c_TOTAL_COLS),
		 .c_TOTAL_ROWS(c_TOTAL_ROWS),
		 .c_ACTIVE_COLS(c_ACTIVE_COLS),
		 .c_ACTIVE_ROWS(c_ACTIVE_ROWS)) Pong_Inst
	(.i_Clk(i_Clk),
	.i_HSync(w_HSync_VGA),
	.i_VSync(w_VSync_VGA),
	.i_Game_Start(w_RX_DV),
	.i_Paddle_Up_P1(w_Switch_1),
	.i_Paddle_Dn_P1(w_Switch_2),
	.i_Paddle_Up_P2(w_Switch_3),
	.i_Paddle_Dn_P2(w_Switch_4),
	.o_HSync(w_HSync_Pong),
	.o_VSync(w_VSync_Pong),
	.o_Red_Video(w_Red_Video_Pong),
	.o_Grn_Video(w_Grn_Video_Pong),
	.o_Blu_Video(w_Blu_Video_Pong),
	.o_P1_Score(w_P1_Score),
	.o_P2_Score(w_P2_Score));
	
	// Making sure graphics are centered
	VGA_Sync_Porch  #(.VIDEO_WIDTH(c_VIDEO_WIDTH),
					.TOTAL_COLS(c_TOTAL_COLS),
					.TOTAL_ROWS(c_TOTAL_ROWS),
					.ACTIVE_COLS(c_ACTIVE_COLS),
					.ACTIVE_ROWS(c_ACTIVE_ROWS))
	VGA_Sync_Porch_Inst
	(.i_Clk(i_Clk),
	.i_HSync(w_HSync_Pong),
	.i_VSync(w_VSync_Pong),
	.i_Red_Video(w_Red_Video_Pong),
	.i_Grn_Video(w_Grn_Video_Pong),
	.i_Blu_Video(w_Blu_Video_Pong),
	.o_HSync(o_VGA_HSync),
	.o_VSync(o_VGA_VSync),
	.o_Red_Video(w_Red_Video_Porch),
	.o_Grn_Video(w_Grn_Video_Porch),
	.o_Blu_Video(w_Blu_Video_Porch));
	
	assign o_VGA_Red_0 = w_Red_Video_Porch[0];
	assign o_VGA_Red_1 = w_Red_Video_Porch[1];
	assign o_VGA_Red_2 = w_Red_Video_Porch[2];

	assign o_VGA_Grn_0 = w_Grn_Video_Porch[0];
	assign o_VGA_Grn_1 = w_Grn_Video_Porch[1];
	assign o_VGA_Grn_2 = w_Grn_Video_Porch[2];

	assign o_VGA_Blu_0 = w_Blu_Video_Porch[0];
	assign o_VGA_Blu_1 = w_Blu_Video_Porch[1];
	assign o_VGA_Blu_2 = w_Blu_Video_Porch[2];
	
	
	//P1 Points Display wiring
	assign o_Segment1_A = ~w_Segment1_A;
	assign o_Segment1_B = ~w_Segment1_B;
	assign o_Segment1_C = ~w_Segment1_C;
	assign o_Segment1_D = ~w_Segment1_D;
	assign o_Segment1_E = ~w_Segment1_E;
	assign o_Segment1_F = ~w_Segment1_F;
	assign o_Segment1_G = ~w_Segment1_G;
	
	//P2 Points Display wiring
	assign o_Segment2_A = ~w_Segment2_A;
	assign o_Segment2_B = ~w_Segment2_B;
	assign o_Segment2_C = ~w_Segment2_C;
	assign o_Segment2_D = ~w_Segment2_D;
	assign o_Segment2_E = ~w_Segment2_E;
	assign o_Segment2_F = ~w_Segment2_F;
	assign o_Segment2_G = ~w_Segment2_G;

endmodule