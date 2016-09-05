module ex_mem (

		input wire 	clk,
		input wire	rst,

		input wire[`RegAddrBus]	ex_dest_addr,
		input wire				ex_wreg,
		input wire[`RegBus]		ex_dest_data,

		input wire[`RegBus]		ex_hi,
		input wire[`RegBus]		ex_lo,
		input wire				ex_whilo,

		output reg[`RegAddrBus]	mem_dest_addr,
		output reg 				mem_wreg,
		output reg[`RegBus]		mem_dest_data,

		output reg[`RegBus]		mem_hi,
		output reg[`RegBus]		mem_lo,
		output reg				mem_whilo

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			mem_dest_addr <= `NOPRegAddr;
			mem_wreg      <= `False;
			mem_dest_data <= `ZeroWord;
			mem_hi        <= `ZeroWord;
			mem_lo        <= `ZeroWord;
			mem_whilo     <= `False;
		end else begin
			mem_dest_addr <= ex_dest_addr;
			mem_wreg      <= ex_wreg;
			mem_dest_data <= ex_dest_data;
			mem_hi        <= ex_hi;
			mem_lo        <= ex_lo;
			mem_whilo     <= ex_whilo;
		end
	end

endmodule