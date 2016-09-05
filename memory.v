module memory (

		input wire	rst,

		input wire[`RegAddrBus]	dest_addr_in,
		input wire				wreg_in,
		input wire[`RegBus]		dest_data_in,

		input wire[`RegBus]		hi_in,
		input wire[`RegBus]		lo_in,
		input wire 				whilo_in,

		output reg[`RegAddrBus]	dest_addr_out,
		output reg 				wreg_out,
		output reg[`RegBus]		dest_data_out,

		output reg[`RegBus]		hi_out,
		output reg[`RegBus]		lo_out,
		output reg 				whilo_out

	);

	always @( * ) begin
		if (rst == `RstEnable) begin
			dest_addr_out <= `NOPRegAddr;
			wreg_out      <= `False;
			dest_data_out <= `ZeroWord;
			hi_out        <= `ZeroWord;
			lo_out        <= `ZeroWord;
			whilo_out     <= `False;
		end else begin
			dest_addr_out <= dest_addr_in;
			wreg_out      <= wreg_in;
			dest_data_out <= dest_data_in;
			hi_out        <= hi_in;
			lo_out        <= lo_in;
			whilo_out     <= whilo_in;
		end
	end

endmodule