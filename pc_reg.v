module pc_reg (

		input wire	clk,
		input wire	rst,

		input wire[5:0]	stall,

		output reg[`InstAddrBus]	pc,
		output reg					ce

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

	always @(posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <=`AddrStart;
		end else if (stall[0] == `NoStop) begin
			pc <= pc + 32'h00000004;
		end
	end

endmodule