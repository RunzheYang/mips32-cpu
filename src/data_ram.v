module data_ram (

		input wire 					clk,
		input wire 					ce,
		input wire 					we,
		input wire[`DataAddrBus]	addr,
		input wire[3:0]				sel,
		input wire[`DataBus]		data_in,

		output reg[`DataBus]		data_out

	);

	reg[`ByteWidth]	data_mem0[0:`DataMemNum - 1];
	reg[`ByteWidth]	data_mem1[0:`DataMemNum - 1];
	reg[`ByteWidth]	data_mem2[0:`DataMemNum - 1];
	reg[`ByteWidth]	data_mem3[0:`DataMemNum - 1];

	// write
	always @(posedge clk) begin
		if (ce == `ChipDisable) begin
			data_out <= `ZeroWord;
		end else if (we == `True) begin
			if (sel[3] == `True) begin
				data_mem3[addr[`DataMemNumLog2 + 1 : 2]] <= data_in[31:24];
			end
			if (sel[2] == `True) begin
				data_mem2[addr[`DataMemNumLog2 + 1 : 2]] <= data_in[23:16];
			end
			if (sel[1] == `True) begin
				data_mem1[addr[`DataMemNumLog2 + 1 : 2]] <= data_in[15:8];
			end
			if (sel[0] == `True) begin
				data_mem0[addr[`DataMemNumLog2 + 1 : 2]] <= data_in[7:0];
			end
		end
	end

	// read
	always @( * ) begin
		if (ce == `ChipDisable) begin
			data_out <= `ZeroWord;
		end else if (we == `False) begin
			data_out <= {
				data_mem3[addr[`DataMemNumLog2 + 1 : 2]],
				data_mem2[addr[`DataMemNumLog2 + 1 : 2]],
				data_mem1[addr[`DataMemNumLog2 + 1 : 2]],
				data_mem0[addr[`DataMemNumLog2 + 1 : 2]]
			};
		end else begin
			data_out <= `ZeroWord;
		end
	end

endmodule