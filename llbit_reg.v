module llbit_reg (

		input wire	clk,
		input wire	rst,

		// exception?
		input wire 	flush,

		input wire	llbit_in,
		input wire	we,

		output reg 	llbit_out

	);

	always @( * ) begin
		if (rst == `RstEnable) begin
			llbit_out <= `False;
		end else if (flush == `True) begin
			llbit_out <= 1'b0;
		end else if (we == `WriteEnable) begin
			llbit_out <= llbit_in;
		end
	end

endmodule