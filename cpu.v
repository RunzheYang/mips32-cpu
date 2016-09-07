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
	wire				in_delayslot;

	// ID -> 
	wire[`AluOpBus]		id_aluop_out;
	wire[`AluSelBus]	id_alusel_out;
	wire[`RegBus]		id_src1_data_out;
	wire[`RegBus]		id_src2_data_out;
	wire				id_wreg_out;
	wire[`RegAddrBus]	id_dest_addr_out;

	wire 				id_in_delayslot_out;
	wire[`RegBus]		id_link_addr_out;
	wire 				id_nex_inst_delayslot_out;
	wire[`RegBus]		id_branch_tar_addr_out;
	wire				id_branch_flag_out;

	// -> EXE
	wire[`AluOpBus]		ex_aluop_in;
	wire[`AluSelBus]	ex_alusel_in;
	wire[`RegBus]		ex_src1_data_in;
	wire[`RegBus]		ex_src2_data_in;
	wire				ex_wreg_in;
	wire[`RegAddrBus]	ex_dest_addr_in;
	wire[`DoubleRegBus]	hilo_temp_in;
	wire[1:0] 			cnt_in;
	wire[`RegBus]		ex_link_addr_in;
	wire				ex_in_delayslot_in;

	// EXE ->
	wire				ex_wreg_out;
	wire[`RegAddrBus]	ex_dest_addr_out;
	wire[`RegBus]		ex_dest_data_out;

	wire[`RegBus]		ex_hi_out;
	wire[`RegBus]		ex_lo_out;
	wire				ex_whilo_out;

	wire[`DoubleRegBus]	hilo_temp_out;
	wire[1:0] 			cnt_out;

	// -> MEM
	wire				mem_wreg_in;
	wire[`RegAddrBus]	mem_dest_addr_in;
	wire[`RegBus]		mem_dest_data_in;

	wire[`RegBus]		mem_hi_in;
	wire[`RegBus]		mem_lo_in;
	wire				mem_whilo_in;

	// MEM ->
	wire				mem_wreg_out;
	wire[`RegAddrBus]	mem_dest_addr_out;
	wire[`RegBus]		mem_dest_data_out;

	wire[`RegBus]		mem_hi_out;
	wire[`RegBus]		mem_lo_out;
	wire				mem_whilo_out;

	// -> WB
	wire				wb_wreg_in;
	wire[`RegAddrBus]	wb_dest_addr_in;
	wire[`RegBus]		wb_dest_data_in;

	wire[`RegBus]		wb_hi_in;
	wire[`RegBus]		wb_lo_in;
	wire				wb_whilo_in;

	// Reg_file
	wire				reg1_read;
	wire				reg2_read;
	wire[`RegBus]		reg1_data;
	wire[`RegBus]		reg2_data;
	wire[`RegAddrBus]	reg1_addr;
	wire[`RegAddrBus]	reg2_addr;

	// HILO
	wire[`RegBus]		hi_data;
	wire[`RegBus]		lo_data;

	//ctrl
	wire		stall_req_id;
	wire		stall_req_ex;
	wire[5:0]	stall;

	//div
	wire				signed_div;
	wire				div_start;
	wire[`RegBus]		div_opdata1;
	wire[`RegBus]		div_opdata2;
	wire[`DoubleRegBus]	div_result;
	wire				div_ready;

 

	//CTRL
	ctrl ctrl0 (
			.rst			(rst),
			.stall_req_id	(stall_req_id),
			.stall_req_ex	(stall_req_ex),
			.stall 			(stall)
		);

	// pc_reg instantiation
	pc_reg pc_reg0 (
			.clk 	(clk),
			.rst 	(rst),
			.stall	(stall),
			.branch_flag_in		(id_branch_flag_out),
			.branch_tar_addr_in (id_branch_tar_addr_out),
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
			.stall 	(stall),
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

			.in_delayslot_in   (in_delayslot),

			.next_inst_delayslot_out	(id_nex_inst_delayslot_out),
			.branch_flag_out			(id_branch_flag_out),
			.branch_tar_addr_out		(id_branch_tar_addr_out),
			.link_addr_out				(id_link_addr_out),
			.in_delayslot_out			(id_in_delayslot_out),

			.src1_read_out	(reg1_read),
			.src2_read_out	(reg2_read),
			.src1_addr_out	(reg1_addr),
			.src2_addr_out	(reg2_addr),

			.aluop_out		(id_aluop_out),
			.alusel_out		(id_alusel_out),
			.src1_data_out	(id_src1_data_out),
			.src2_data_out	(id_src2_data_out),
			.dest_addr_out	(id_dest_addr_out),
			.wreg_out		(id_wreg_out),
			.stall_req 		(stall_req_id)
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

	// HILO instantiation
	hilo_reg hilo_reg0 (
			.clk	(clk),
			.rst	(rst),

			.we		(wb_whilo_in),
			.hi_in	(wb_hi_in),
			.lo_in	(wb_lo_in),

			.hi_out	(hi_data),
			.lo_out	(lo_data)
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
			.stall 			(stall),
			.id_link_addr			(id_link_addr_out),
			.id_in_delayslot		(id_in_delayslot_out),
			.next_inst_delayslot_in	(id_nex_inst_delayslot_out),
			.ex_link_addr			(ex_link_addr_in),
			.ex_in_delayslot		(ex_in_delayslot_in),
			.next_inst_delayslot_out	(in_delayslot),
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

			.hi_in	(hi_data),
			.lo_in	(lo_data),

			.wb_hi_in		(wb_hi_in),
			.wb_lo_in		(wb_lo_in),
			.wb_whilo_in	(wb_whilo_in),

			.hilo_temp_in	(hilo_temp_in),
			.cnt_in			(cnt_in),

			.mem_hi_in		(mem_hi_out),
			.mem_lo_in		(mem_lo_out),
			.mem_whilo_in	(mem_whilo_out),

			.div_result_in	(div_result),
			.div_ready_in	(div_ready),

			.link_addr_in	(ex_link_addr_in),
			.in_delayslot_in	(ex_in_delayslot_in),

			.dest_addr_out	(ex_dest_addr_out),
			.wreg_out		(ex_wreg_out),
			.dest_data_out	(ex_dest_data_out),

			.hi_out		(ex_hi_out),
			.lo_out		(ex_lo_out),
			.whilo_out	(ex_whilo_out),

			.hilo_temp_out	(hilo_temp_out),
			.cnt_out 		(cnt_out),

			.div_opdata1_out	(div_opdata1),
			.div_opdata2_out	(div_opdata2),
			.div_start_out		(div_start),
			.signed_div_out		(signed_div),

			.stall_req 	(stall_req_ex)
		);

	// ex/mem instantiation
	ex_mem ex_mem0 (
			.clk	(clk),
			.rst	(rst),

			.ex_dest_addr	(ex_dest_addr_out),
			.ex_wreg		(ex_wreg_out),
			.ex_dest_data	(ex_dest_data_out),

			.ex_hi 			(ex_hi_out),
			.ex_lo 			(ex_lo_out),
			.ex_whilo		(ex_whilo_out),

			.stall 			(stall),

			.hilo_in 		(hilo_temp_out),
			.cnt_in			(cnt_out),

			.hilo_out 		(hilo_temp_in),
			.cnt_out		(cnt_in),

			.mem_dest_addr	(mem_dest_addr_in),
			.mem_wreg		(mem_wreg_in),
			.mem_dest_data	(mem_dest_data_in),

			.mem_hi 		(mem_hi_in),
			.mem_lo 		(mem_lo_in),
			.mem_whilo 		(mem_whilo_in)
		);

	// memory instantiation
	memory mem0 (
			.rst	(rst),

			.dest_addr_in	(mem_dest_addr_in),
			.wreg_in		(mem_wreg_in),
			.dest_data_in	(mem_dest_data_in),

			.hi_in		(mem_hi_in),
			.lo_in		(mem_lo_in),
			.whilo_in 	(mem_whilo_in),

			.dest_addr_out	(mem_dest_addr_out),
			.wreg_out		(mem_wreg_out),
			.dest_data_out	(mem_dest_data_out),

			.hi_out		(mem_hi_out),
			.lo_out		(mem_lo_out),
			.whilo_out	(mem_whilo_out)
		);

	// mem/wb instantiation
	mem_wb men_wb0 (
			.clk	(clk),
			.rst	(rst),

			.mem_dest_addr	(mem_dest_addr_out),
			.mem_wreg		(mem_wreg_out),
			.mem_dest_data	(mem_dest_data_out),

			.mem_hi 	(mem_hi_out),
			.mem_lo 	(mem_lo_out),
			.mem_whilo 	(mem_whilo_out),

			.stall 		(stall),

			.wb_dest_addr	(wb_dest_addr_in),
			.wb_wreg		(wb_wreg_in),
			.wb_dest_data	(wb_dest_data_in),

			.wb_hi 		(wb_hi_in),
			.wb_lo 		(wb_lo_in),
			.wb_whilo 	(wb_whilo_in)
		);

	div div0 (
			.clk(clk),
			.rst(rst),

			.signed_div_in	(signed_div),
			.opdata1_in (div_opdata1),
			.opdata2_in (div_opdata2),
			.start_in	(div_start),
			.annul_in 	(1'b0),

			.result_out (div_result),
			.ready_out 	(div_ready)
		);

endmodule