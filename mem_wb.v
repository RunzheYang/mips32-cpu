module mem_wb (

		input wire	clk,
		input wire	rst,

		input wire[`RegAddrBus]	mem_dest_addr,
		input wire				mem_wreg,
		input wire[`RegBus]		mem_dest_data,

		input wire[`RegBus]		mem_hi,
		input wire[`RegBus]		mem_lo,
		input wire				mem_whilo,

		input wire		mem_llbit_we,
		input wire		mem_llbit_data,

		input wire[5:0]	stall,

		output reg 		wb_llbit_we,
		output reg 		wb_llbit_data,

		output reg[`RegAddrBus]	wb_dest_addr,
		output reg 				wb_wreg,
		output reg[`RegBus]		wb_dest_data,

		output reg[`RegBus]		wb_hi,
		output reg[`RegBus]		wb_lo,
		output reg 				wb_whilo

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			wb_dest_addr  <= `NOPRegAddr;
			wb_wreg       <= `False;
			wb_dest_data  <= `ZeroWord;
			wb_hi         <= `ZeroWord;
			wb_lo         <= `ZeroWord;
			wb_whilo      <= `False;
			wb_llbit_we   <= `False;
			wb_llbit_data <= 1'b0;
		end else if (stall[4] == `Stop && stall[5] == `NoStop) begin
			wb_dest_addr  <= `NOPRegAddr;
			wb_wreg       <= `False;
			wb_dest_data  <= `ZeroWord;
			wb_hi         <= `ZeroWord;
			wb_lo         <= `ZeroWord;
			wb_whilo      <= `False;
			wb_llbit_we   <= `False;
			wb_llbit_data <= 1'b0;
		end else if (stall[4] == `NoStop) begin
			wb_dest_addr  <= mem_dest_addr;
			wb_wreg       <= mem_wreg;
			wb_dest_data  <= mem_dest_data;
			wb_hi         <= mem_hi;
			wb_lo         <= mem_lo;
			wb_whilo      <= mem_whilo;
			wb_llbit_we   <= wb_llbit_we;
			wb_llbit_data <= wb_llbit_data;
		end
	end

endmodule