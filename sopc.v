module sopc (
		input wire	clk,
		input wire	rst
	);

	wire[`InstAddrBus]	inst_addr;
	wire[`InstBus]		inst;
	wire				rom_ce;

	cpu cpu0 (
			.clk	(clk),
			.rst	(rst),

			.rom_data_in	(inst),
			.rom_addr_out	(inst_addr),
			.rom_ce_out		(rom_ce)
		);

	inst_rom inst_rom0 (
			.ce		(rom_ce),
			.addr	(inst_addr),
			.inst	(inst)
		);

endmodule