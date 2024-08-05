// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217
 
module UART_RX
  #(parameter CLKS_PER_BIT = 217)
  (
   input        i_Clock,
   input        i_RX_Serial, // The input bit stream from the UART
   output       o_RX_DV, // To confirm if full byte as been read?
   output [7:0] o_RX_Byte // The actual read data
   );
  
  // State Machine Setup
  // These are all states being represented by bits, the bits themselves don't actually mean anything
  parameter IDLE_STATE = 3'b000;
  parameter RX_START_BIT_STATE = 3'b001;
  parameter RX_DATA_BITS_STATE = 3'b010;
  parameter RX_STOP_BIT_STATE  = 3'b011;
  parameter CLEANUP_STATE = 3'b100;
  
  reg [7:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; //8 bits total, we need to keep track of which one we're on
  reg [7:0]     r_RX_Byte     = 0;
  reg           r_RX_DV       = 0; // for confirmation
  reg [2:0]     r_SM_Main     = 0; // This is how we will keep track of what state we are on
  
  
  // Purpose: Control RX state machine
  always @(posedge i_Clock)
	begin
		case(r_SM_Main)
			IDLE_STATE:
				begin
					r_RX_DV <= 1'b0;
					r_Clock_Count <= 0;
					r_Bit_Index <= 0;
					
					// Detect a start bit
					if(i_RX_Serial == 1'b0)
						r_SM_Main <= RX_START_BIT_STATE;
					else
						r_SM_Main <= IDLE_STATE;			
				end
			RX_START_BIT_STATE:
				begin
					if(r_Clock_Count == (CLKS_PER_BIT-1) / 2)
						begin
							if(i_RX_Serial == 1'b0) // We have confirmed the start state
								begin
									r_Clock_Count <= 0;
									r_SM_Main <= RX_DATA_BITS_STATE;
								end
							else
								r_SM_Main <= IDLE_STATE;
						end
					else // Keep counting until we wait (217-1)/2 cycles
						begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_SM_Main <= RX_START_BIT_STATE;
						end
				end
			// Wait CLKS_PER_BIT - 1 clock cycles to sample serial data
			RX_DATA_BITS_STATE:
				begin
					if(r_Clock_Count < CLKS_PER_BIT - 1)
						begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_SM_Main <= RX_DATA_BITS_STATE;
						end
					else
						begin
							r_Clock_Count <= 0;
							r_RX_Byte[r_Bit_Index] <= i_RX_Serial;
							
							// Check if we have received all bits
							if(r_Bit_Index < 7)
								begin
									r_Bit_Index <= r_Bit_Index + 1;
									r_SM_Main <= RX_DATA_BITS_STATE;
								end
							else
								begin
									r_SM_Main <= RX_STOP_BIT_STATE;
									r_Bit_Index <= 0;
								end
						end
				end
			RX_STOP_BIT_STATE:
				begin
					if(r_Clock_Count < CLKS_PER_BIT - 1)
						begin
							r_Clock_Count <= r_Clock_Count + 1;
							r_SM_Main <= RX_STOP_BIT_STATE;
						end
					else
						begin
							r_RX_DV <= 1'b1;
							r_Clock_Count <= 0;
							r_SM_Main <= CLEANUP_STATE;
						end
				end
			CLEANUP_STATE:
				begin
					r_SM_Main <= IDLE_STATE;
					r_RX_DV <= 1'b0;
				end
			
			default:
				r_SM_Main <= IDLE_STATE;
		endcase
	end

	assign o_RX_DV = r_RX_DV;
	assign o_RX_Byte = r_RX_Byte;
  
  
endmodule // UART_RX
