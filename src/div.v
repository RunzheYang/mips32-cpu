module div (

		input wire clk,
		input wire rst,

		input wire 			signed_div_in,
		input wire[31:0]	opdata1_in,
		input wire[31:0]	opdata2_in,
		input wire 			start_in,
		input wire 			annul_in,

		output reg[63:0]	result_out,
		output reg			ready_out

	);

	wire[32:0]	div_temp;
	reg[5:0]	cnt;
	reg[64:0]	dividend;
	reg[1:0]	state;
	reg[31:0]	divisor;
	reg[31:0]	temp_op1;
	reg[31:0]	temp_op2;

	assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};

	always @(posedge clk) begin  
		if (rst == `RstEnable) begin  
			state    <= `DivFree;  
			ready_out  <= `DivResultNotReady;  
			result_out <= {`ZeroWord,`ZeroWord};  
 		end else begin  
	 		case (state)  
		//*******************   DivFree State    ********************  
		// Three cases
		// 1. divisor = 0, then go to DivByZero
		// 2. divisor ≠ 0, then go to DivOn. Initialize cnt = 0.
		// If it a signed division && dividend or divisor < 0, 
		// and get its complement
		// store the highest digit in divisor to dividend[32]
		// prepare for the first iteration
		// 3. No div. keep ready_out = DivResultNotReady
		// and result_out = 0
		//***********************************************************  
				`DivFree:  begin
					if(start_in == `DivStart && annul_in == 1'b0) begin  
						if(opdata2_in == `ZeroWord) begin  
						state <= `DivByZero;
						end else begin  
						state <= `DivOn;
						cnt <= 6'b000000;  
						if(signed_div_in == 1'b1 && opdata1_in[31] == 1'b1 ) begin  
							temp_op1 = ~opdata1_in + 1;
						end else begin  
							temp_op1 = opdata1_in;  
						end  
						if(signed_div_in == 1'b1 && opdata2_in[31] == 1'b1 ) begin  
							temp_op2 = ~opdata2_in + 1;
						end else begin  
							temp_op2 = opdata2_in;  
						end  
						dividend <= {`ZeroWord,`ZeroWord};  
						dividend[32:1] <= temp_op1;  
						divisor <= temp_op2;  
						end  
					end else begin
						ready_out <= `DivResultNotReady;  
						result_out <= {`ZeroWord,`ZeroWord};  
					end  
				end  
	  
				`DivByZero:     begin
					dividend <= {`ZeroWord,`ZeroWord};  
					state <= `DivEnd;                  
				end
	  
				`DivOn:          begin               
					if(annul_in == 1'b0) begin  
						if(cnt != 6'b100000) begin   
							if(div_temp[32] == 1'b1) begin   
									dividend <= {dividend[63:0] , 1'b0};  
							end else begin  
									dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};  
							end  
							cnt <= cnt + 1;  
						end else begin
							if((signed_div_in == 1'b1) &&   
									((opdata1_in[31] ^ opdata2_in[31]) == 1'b1)) begin  
								dividend[31:0] <= (~dividend[31:0] + 1); 
							end  
							if((signed_div_in == 1'b1) &&   
									((opdata1_in[31] ^ dividend[64]) == 1'b1)) begin                
								dividend[64:33] <= (~dividend[64:33] + 1);
							end  
							state <= `DivEnd;
							cnt <= 6'b000000;
						end  
					end else begin  
						state <= `DivFree;
					end   
				end  
	 
				`DivEnd:       begin 
				 	result_out <= {dividend[64:33], dividend[31:0]};    
				 	ready_out <= `DivResultReady;  
				 	if(start_in == `DivStop) begin  
						state <= `DivFree;  
						ready_out <= `DivResultNotReady;  
						result_out <= {`ZeroWord,`ZeroWord};           
					end            
				end  
			endcase  
	 	end  
	end

endmodule	