module mem_wb (

		input wire	clk,
		input wire	rst,

		input wire[`RegAddrBus]	mem_dest_addr,
		input wire				mem_wreg,
		input wire[`RegBus]		mem_dest_data,

		output reg[`RegAddrBus]	wb_dest_addr,
		output reg 				wb_wreg,
		output reg[`RegBus]		wb_dest_data

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			wb_dest_addr <= `NOPRegAddr;
			wb_wreg      <=	`False;
			wb_dest_data <= `ZeroWord;
		end else begin
			wb_dest_addr <= mem_dest_addr;
			wb_wreg      <=	mem_wreg;
			wb_dest_data <= mem_dest_data;
		end
	end

endmodule