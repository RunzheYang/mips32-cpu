module memory (

		input wire	rst,

		input wire[`RegAddrBus]	dest_addr_in,
		input wire				wreg_in,
		input wire[`RegBus]		dest_data_in,

		output reg[`RegAddrBus]	dest_addr_out,
		output reg 				wreg_out,
		output reg[`RegBus]		dest_data_out

	);

	always @( * ) begin
		if (rst == `RstEnable) begin
			dest_addr_out <= `NOPRegAddr;
			wreg_out      <= `False;
			dest_data_out <= `ZeroWord;
		end else begin
			dest_addr_out <= dest_addr_in;
			wreg_out      <= wreg_in;
			dest_data_out <= dest_data_in;
		end
	end

endmodule