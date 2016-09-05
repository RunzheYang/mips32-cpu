module cpu (

		input wire	clk,
		input wire 	rst,

		input	wire[`RegBus]	rom_data_in,
		output	wire[`RegBus]	rom_addr_out,
		output	wire			rom_ce_out

	);
	
	// IF ->
	wire[`InstAddrBus]	pc;

	// -> ID	
	wire[`InstAddrBus]	id_pc_in;
	wire[`InstBus]		id_inst_in;

	// ID -> 
	wire[`AluOpBus]		id_aluop_out;
	wire[`AluSelBus]	id_alusel_out;
	wire[`RegBus]		id_src1_data_out;
	wire[`RegBus]		id_src2_data_out;
	wire				id_wreg_out;
	wire[`RegAddrBus]	id_dest_addr_out;

	// -> EXE
	wire[`AluOpBus]		ex_aluop_in;
	wire[`AluSelBus]	ex_alusel_in;
	wire[`RegBus]		ex_src1_data_in;
	wire[`RegBus]		ex_src2_data_in;
	wire				ex_wreg_in;
	wire[`RegAddrBus]	ex_dest_addr_in;

	// EXE ->
	wire				ex_wreg_out;
	wire[`RegAddrBus]	ex_dest_addr_out;
	wire[`RegBus]		ex_dest_data_out;

	// -> MEM
	wire				mem_wreg_in;
	wire[`RegAddrBus]	mem_dest_addr_in;
	wire[`RegBus]		mem_dest_data_in;

	// MEM ->
	wire				mem_wreg_out;
	wire[`RegAddrBus]	mem_dest_addr_out;
	wire[`RegBus]		mem_dest_data_out;

	// -> WB
	wire				wb_wreg_in;
	wire[`RegAddrBus]	wb_dest_addr_in;
	wire[`RegBus]		wb_dest_data_in;

	// Regfile for ID
	wire				reg1_read;
	wire				reg2_read;
	wire[`RegBus]		reg1_data;
	wire[`RegBus]		reg2_data;
	wire[`RegAddrBus]	reg1_addr;
	wire[`RegAddrBus]	reg2_addr;


	// pc_reg instantiation
	pc_reg pc_reg0 (
			.clk 	(clk),
			.rst 	(rst),
			.pc 	(pc),
			.ce 	(rom_ce_out)
		);

	assign rom_addr_out = pc;

	// if/id instantiation
	if_id if_id0 (
			.clk	(clk),
			.rst	(rst),
			.if_pc	(pc),
			.if_inst(rom_data_in),
			.id_pc 	(id_pc_in),
			.id_inst(id_inst_in)
		);

	// decode instantiation
	decode id0 (
			.rst		(rst),
			.pc_in		(id_pc_in),
			.inst_in	(id_inst_in),

			.src1_data_in	(reg1_data),
			.src2_data_in	(reg2_data),

			.ex_dest_addr_in	(ex_dest_addr_out),
			.ex_dest_data_in	(ex_dest_data_out),
			.ex_wreg_in			(ex_wreg_out),

			.mem_dest_addr_in	(mem_dest_addr_out),
			.mem_dest_data_in	(mem_dest_data_out),
			.mem_wreg_in		(mem_wreg_out),

			.src1_read_out	(reg1_read),
			.src2_read_out	(reg2_read),
			.src1_addr_out	(reg1_addr),
			.src2_addr_out	(reg2_addr),

			.aluop_out		(id_aluop_out),
			.alusel_out		(id_alusel_out),
			.src1_data_out	(id_src1_data_out),
			.src2_data_out	(id_src2_data_out),
			.dest_addr_out	(id_dest_addr_out),
			.wreg_out		(id_wreg_out)
		);

	// regfile instantiation 
	reg_file reg_file0 (
			.clk	(clk),
			.rst	(rst),

			.we		(wb_wreg_in),
			.waddr	(wb_dest_addr_in),
			.wdata	(wb_dest_data_in),

			.re1	(reg1_read),
			.raddr1	(reg1_addr),
			.rdata1	(reg1_data),

			.re2	(reg2_read),
			.raddr2	(reg2_addr),
			.rdata2	(reg2_data)
		);

	// id/ex instantiation
	id_ex id_ex0 (
			.clk	(clk),
			.rst	(rst),

			.id_aluop		(id_aluop_out),
			.id_alusel		(id_alusel_out),
			.id_src1_data	(id_src1_data_out),
			.id_src2_data	(id_src2_data_out),
			.id_dest_addr	(id_dest_addr_out),
			.id_wreg		(id_wreg_out),

			.ex_aluop		(ex_aluop_in),
			.ex_alusel		(ex_alusel_in),
			.ex_src1_data	(ex_src1_data_in),
			.ex_src2_data	(ex_src2_data_in),
			.ex_dest_addr	(ex_dest_addr_in),
		 	.ex_wreg 		(ex_wreg_in)
		);

	// execute instantiation
	execute ex0 (
			.rst	(rst),

			.aluop_in		(ex_aluop_in),
			.alusel_in		(ex_alusel_in),
			.src1_data_in	(ex_src1_data_in),
			.src2_data_in	(ex_src2_data_in),
			.dest_addr_in	(ex_dest_addr_in),
			.wreg_in		(ex_wreg_in),

			.dest_addr_out	(ex_dest_addr_out),
			.wreg_out		(ex_wreg_out),
			.dest_data_out	(ex_dest_data_out)
		);

	// ex/mem instantiation
	ex_mem ex_mem0 (
			.clk	(clk),
			.rst	(rst),

			.ex_dest_addr	(ex_dest_addr_out),
			.ex_wreg		(ex_wreg_out),
			.ex_dest_data	(ex_dest_data_out),

			.mem_dest_addr	(mem_dest_addr_in),
			.mem_wreg		(mem_wreg_in),
			.mem_dest_data	(mem_dest_data_in)
		);

	// memory instantiation
	memory mem0 (
			.rst	(rst),

			.dest_addr_in	(mem_dest_addr_in),
			.wreg_in		(mem_wreg_in),
			.dest_data_in	(mem_dest_data_in),

			.dest_addr_out	(mem_dest_addr_out),
			.wreg_out		(mem_wreg_out),
			.dest_data_out	(mem_dest_data_out)
		);

	// mem/wb instantiation
	mem_wb men_wb0 (
			.clk	(clk),
			.rst	(rst),

			.mem_dest_addr	(mem_dest_addr_out),
			.mem_wreg		(mem_wreg_out),
			.mem_dest_data	(mem_dest_data_out),

			.wb_dest_addr	(wb_dest_addr_in),
			.wb_wreg		(wb_wreg_in),
			.wb_dest_data	(wb_dest_data_in)
		);

endmodule