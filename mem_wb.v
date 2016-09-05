module mem_wb (

		input wire	clk,
		input wire	rst,

		input wire[`RegAddrBus]	mem_dest_addr,
		input wire				mem_wreg,
		input wire[`RegBus]		mem_dest_data,

		input wire[`RegBus]		mem_hi,
		input wire[`RegBus]		mem_lo,
		input wire				mem_whilo,

		output reg[`RegAddrBus]	wb_dest_addr,
		output reg 				wb_wreg,
		output reg[`RegBus]		wb_dest_data,

		output reg[`RegBus]		wb_hi,
		output reg[`RegBus]		wb_lo,
		output reg 				wb_whilo

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			wb_dest_addr <= `NOPRegAddr;
			wb_wreg      <=	`False;
			wb_dest_data <= `ZeroWord;
			wb_hi        <= `ZeroWord;
			wb_lo        <= `ZeroWord;
			wb_whilo     <= `False;
		end else begin
			wb_dest_addr <= mem_dest_addr;
			wb_wreg      <=	mem_wreg;
			wb_dest_data <= mem_dest_data;
			wb_hi        <= mem_hi;
			wb_lo        <= mem_lo;
			wb_whilo     <= mem_whilo;
		end
	end

endmodule