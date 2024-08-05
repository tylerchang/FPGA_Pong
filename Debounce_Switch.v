module Debounce_Switch(input i_Clk, input i_Switch, output o_Switch);
	
	parameter c_DEBOUNCE_LIMIT = 250000; // 10 ms at 25MHz is 250000 cycles
	
	reg r_State = 1'b0;
	reg [17:0] r_Count = 0;
	
	always @(posedge i_Clk) // This runs EVERY cycle!
		begin
			// If we detect that there's a toggle in the button, we wanna wait 10ms which is the same thing as 250000 cycles
			if(i_Switch !== r_State && r_Count < c_DEBOUNCE_LIMIT)
				r_Count <= r_Count + 1; // COUNTER
			// Once we have waited 10ms, we will reset the counter and formally assign the value of the input to the filtered state
			else if(r_Count == c_DEBOUNCE_LIMIT)
				begin
					r_Count <= 0;
					r_State <= i_Switch;
				end
			else
				r_Count <= 0;  
		end 
	
	assign o_Switch = r_State;

endmodule // Debounce_Switch