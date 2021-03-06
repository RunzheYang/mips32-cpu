module inst_rom (

		input wire					ce,
		input wire[`InstAddrBus]	addr,
		output reg[`InstBus]		inst

	);
	
	reg[`InstBus]	inst_mem[`InstMemNum : 0];

	initial $readmemh ("inst_rom.data", inst_mem);

	always @( * ) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
		end else begin
			inst <= inst_mem[addr[`InstMemNumLog2 + 1 : 2]];
			// inst <= inst_mem[`ZeroWord];
		end
	end

endmodule