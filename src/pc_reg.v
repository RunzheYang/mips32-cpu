module pc_reg (

		input wire	clk,
		input wire	rst,

		// from ctrl
		input wire[5:0]	stall,

		// from decode
		input wire			branch_flag_in,
		input wire[`RegBus]	branch_tar_addr_in,

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
			pc <= `AddrStart;
		end else if (stall[0] == `NoStop) begin
			if (branch_flag_in == `Branch) begin
				pc <= branch_tar_addr_in;
			end else begin
				pc <= pc + 32'h00000004;
			end
		end
	end

endmodule