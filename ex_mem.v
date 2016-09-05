module ex_mem (

		input wire 	clk,
		input wire	rst,

		input wire[`RegAddrBus]	ex_dest_addr,
		input wire				ex_wreg,
		input wire[`RegBus]		ex_dest_data,

		output reg[`RegAddrBus]	mem_dest_addr,
		output reg 				mem_wreg,
		output reg[`RegBus]		mem_dest_data

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			mem_dest_addr <= `NOPRegAddr;
			mem_wreg      <= `False;
			mem_dest_data <= `ZeroWord;
		end else begin
			mem_dest_addr <= ex_dest_addr;
			mem_wreg      <= ex_wreg;
			mem_dest_data <= ex_dest_data;
		end
	end

endmodule