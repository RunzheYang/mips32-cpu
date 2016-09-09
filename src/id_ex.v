module id_ex (

		input wire	clk,
		input wire	rst,

		input wire[`AluOpBus]	id_aluop,
		input wire[`AluSelBus]	id_alusel,
		input wire[`RegBus]		id_src1_data,
		input wire[`RegBus]		id_src2_data,
		input wire[`RegAddrBus]	id_dest_addr,
		input wire				id_wreg,

		input wire[5:0]			stall,

		input wire[`RegBus]		id_link_addr,
		input wire				id_in_delayslot,
		input wire 				next_inst_delayslot_in,

		input wire[`RegBus]		id_inst,

		output reg[`RegBus] 	ex_link_addr,
		output reg 				ex_in_delayslot,
		output reg 				next_inst_delayslot_out,

		output reg[`AluOpBus]	ex_aluop,
		output reg[`AluSelBus]	ex_alusel,
		output reg[`RegBus]		ex_src1_data,
		output reg[`RegBus]		ex_src2_data,
		output reg[`RegAddrBus]	ex_dest_addr,

		output reg[`RegBus] 	ex_inst,

		output reg 				ex_wreg

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluop     <= `NOP_OP;
			ex_alusel    <= `RES_NOP;
			ex_src1_data <= `ZeroWord;
			ex_src2_data <= `ZeroWord;
			ex_dest_addr <= `NOPRegAddr;
			ex_wreg      <= `False;
			ex_link_addr <= `ZeroWord;
			ex_in_delayslot <= `NotInDelaySlot;
			next_inst_delayslot_out <= `NotInDelaySlot;
			ex_inst <= `ZeroWord;
		end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
			ex_aluop     <= `NOP_OP;
			ex_alusel    <= `RES_NOP;
			ex_src1_data <= `ZeroWord;
			ex_src2_data <= `ZeroWord;
			ex_dest_addr <= `NOPRegAddr;
			ex_wreg      <= `False;
			ex_link_addr <= `ZeroWord;
			ex_in_delayslot <= `NotInDelaySlot;
			ex_inst <= `ZeroWord;
		end else if (stall[2] == `NoStop) begin
			ex_aluop     <= id_aluop;
			ex_alusel    <= id_alusel;
			ex_src1_data <= id_src1_data;
			ex_src2_data <= id_src2_data;
			ex_dest_addr <= id_dest_addr;
			ex_wreg      <= id_wreg;
			ex_link_addr <= id_link_addr;
			ex_in_delayslot <= id_in_delayslot;
			next_inst_delayslot_out <= next_inst_delayslot_in;
			ex_inst <= id_inst;
		end
	end

endmodule