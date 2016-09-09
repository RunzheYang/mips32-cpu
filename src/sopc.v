module sopc (
		input wire	clk,
		input wire	rst
	);

	wire[`InstAddrBus]	inst_addr;
	wire[`InstBus]		inst;
	wire				rom_ce;

	wire[`DataAddrBus]	ram_addr;
	wire[`DataBus]		ram_data_in;
	wire[`DataBus]		ram_data_out;
	wire				ram_ce;
	wire[3:0]			ram_sel;
	wire				ram_we;

	cpu cpu0 (
			.clk	(clk),
			.rst	(rst),

			.rom_data_in	(inst),
			.rom_addr_out	(inst_addr),
			.rom_ce_out		(rom_ce),

			.ram_data_in	(ram_data_out),
			.ram_addr_out	(ram_addr),
			.ram_data_out	(ram_data_in),
			.ram_we_out		(ram_we),
			.ram_sel_out	(ram_sel),
			.ram_ce_out		(ram_ce)

		);

	inst_rom inst_rom0 (
			.ce		(rom_ce),
			.addr	(inst_addr),
			.inst	(inst)
		);

	data_ram data_ram0 (
			.clk		(clk),
			.ce			(ram_ce),
			.we			(ram_we),
			.addr		(ram_addr),
			.sel		(ram_sel),
			.data_in 	(ram_data_in),
			.data_out 	(ram_data_out)
		);

endmodule