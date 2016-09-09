module hilo_reg (
		input wire 	clk,
		input wire 	rst,

		input wire			we,
		input wire[`RegBus]	hi_in,
		input wire[`RegBus]	lo_in,

		output reg[`RegBus]	hi_out,
		output reg[`RegBus] lo_out
	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			hi_out <= `ZeroWord;
			lo_out <= `ZeroWord;
		end else if (we == `WriteEnable) begin
			hi_out <= hi_in;
			lo_out <= lo_in;	
		end
	end

endmodule