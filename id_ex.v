module id_ex (

		input wire	clk,
		input wire	rst,

		input wire[`AluOpBus]	id_aluop,
		input wire[`AluSelBus]	id_alusel,
		input wire[`RegBus]		id_src1_data,
		input wire[`RegBus]		id_src2_data,
		input wire[`RegAddrBus]	id_dest_addr,
		input wire				id_wreg,

		output reg[`AluOpBus]	ex_aluop,
		output reg[`AluSelBus]	ex_alusel,
		output reg[`RegBus]		ex_src1_data,
		output reg[`RegBus]		ex_src2_data,
		output reg[`RegAddrBus]	ex_dest_addr,
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
		end else begin
			ex_aluop     <= id_aluop;
			ex_alusel    <= id_alusel;
			ex_src1_data <= id_src1_data;
			ex_src2_data <= id_src2_data;
			ex_dest_addr <= id_dest_addr;
			ex_wreg      <= id_wreg;
		end
	end

endmodule