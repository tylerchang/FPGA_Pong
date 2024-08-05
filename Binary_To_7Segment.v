module Binary_To_7Segment
	(input i_Clk,
	 input [3:0] i_Binary_Num,
	 output o_Segment_A,
	 output o_Segment_B,
	 output o_Segment_C,
	 output o_Segment_D,
	 output o_Segment_E,
	 output o_Segment_F,
	 output o_Segment_G);
	 
	reg[6:0] r_Hex_Encoding = 7'h00;
	
	always @(posedge i_Clk)
		begin
			// convert binary to 7 bit encoding, represented as a hex
			case (i_Binary_Num)
				4'b0000 : r_Hex_Encoding <= 7'h7E; // setting hex encoding to 0, binary: 111 1110
				4'b0001 : r_Hex_Encoding <= 7'h30; // 1...
				4'b0010 : r_Hex_Encoding <= 7'h6D; // 2
				4'b0011 : r_Hex_Encoding <= 7'h79; // 3
				4'b0100 : r_Hex_Encoding <= 7'h33; // 4
				4'b0101 : r_Hex_Encoding <= 7'h5B; // 5			
				4'b0110 : r_Hex_Encoding <= 7'h5F; // 6
				4'b0111 : r_Hex_Encoding <= 7'h70; // 7
				4'b1000 : r_Hex_Encoding <= 7'h7F; // 8
				4'b1001 : r_Hex_Encoding <= 7'h7B; // 9
				4'b1010 : r_Hex_Encoding <= 7'h77; // A
				4'b1011 : r_Hex_Encoding <= 7'h1F; // b
				4'b1100 : r_Hex_Encoding <= 7'h4E; // C
				4'b1101 : r_Hex_Encoding <= 7'h3D; // d
				4'b1110 : r_Hex_Encoding <= 7'h4F; // E
				4'b1111 : r_Hex_Encoding <= 7'h47; // F
			endcase
		end
	
	assign o_Segment_A = r_Hex_Encoding[6];
	assign o_Segment_B = r_Hex_Encoding[5];
	assign o_Segment_C = r_Hex_Encoding[4];
	assign o_Segment_D = r_Hex_Encoding[3];
	assign o_Segment_E = r_Hex_Encoding[2];
	assign o_Segment_F = r_Hex_Encoding[1];
	assign o_Segment_G = r_Hex_Encoding[0];

endmodule //Binary_To_7Segment