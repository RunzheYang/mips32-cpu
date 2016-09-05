module execute (

		input wire rst,

		input wire[`AluOpBus]	aluop_in,
		input wire[`AluSelBus]	alusel_in,
		input wire[`RegBus]		src1_data_in,
		input wire[`RegBus]		src2_data_in,
		input wire[`RegAddrBus]	dest_addr_in,
		input wire				wreg_in,

		input wire[`RegBus]		hi_in,
		input wire[`RegBus]		lo_in,

		input wire[`RegBus]		wb_hi_in,
		input wire[`RegBus]		wb_lo_in,
		input wire 				wb_whilo_in,

		input wire[`RegBus]		mem_hi_in,
		input wire[`RegBus]		mem_lo_in,
		input wire 				mem_whilo_in,

		output reg[`RegBus]		hi_out,
		output reg[`RegBus]		lo_out,
		output reg 				whilo_out,

		output reg[`RegAddrBus]	dest_addr_out,
		output reg 				wreg_out,
		output reg[`RegBus]		dest_data_out

	);
	
	// register saving logic result
	reg[`RegBus] logicres;
	// register saving shift result
	reg[`RegBus] shiftres;
	// register saving move result
	reg[`RegBus] moveres;

	reg[`RegBus] HI;
	reg[`RegBus] LO;

	// alu operations LOGIC
	always @( * ) begin
		if (rst == `RstEnable) begin
			logicres <= `ZeroWord;
		end else begin
			case (aluop_in)
				`AND_OP: begin
					logicres <= src1_data_in & src2_data_in;
				end
				`OR_OP: begin
					logicres <= src1_data_in | src2_data_in;
				end
				`XOR_OP: begin
					logicres <= src1_data_in ^ src2_data_in;
				end
				`NOR_OP: begin
					logicres <= ~(src1_data_in | src2_data_in);
				end
				default: begin
					logicres <= `ZeroWord;
				end
			endcase
		end
	end

	// alu operations SHIFT
	always @( * ) begin
		if (rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_in)
				`SLL_OP: begin
					shiftres <= src2_data_in << src1_data_in[4:0];
				end
				`SRL_OP: begin
					shiftres <= src2_data_in >> src1_data_in[4:0];
				end
				`SRA_OP: begin
					shiftres <= 
					({32{src2_data_in[31]}} << (6'd32 - {1'b0, src1_data_in[4:0]})) 
					| src2_data_in >> src1_data_in[4:0];
				end
				default: begin
					shiftres <= `ZeroWord;
				end
			endcase
		end
	end

	// renew HI and LO without data hazard
	always @( * ) begin
		if (rst == `RstEnable) begin
			{HI, LO} <= {`ZeroWord, `ZeroWord};
		end else if (mem_whilo_in == `True) begin
			{HI, LO} <= {mem_hi_in, mem_lo_in};
		end else if (wb_whilo_in == `True) begin
			{HI, LO} <= {wb_hi_in, wb_lo_in};
		end else begin
			{HI, LO} <= {hi_in, lo_in};
		end
	end

	// MOVZ, MOVN, MFHI, MFLO
	always @( * ) begin
		if (rst == `RstEnable) begin
			moveres <= `ZeroWord;
		end else begin
			moveres <= `ZeroWord;
			case (aluop_in)
				`MOVZ_OP: begin
					moveres <= src1_data_in;
				end
				`MOVN_OP: begin
					moveres <= src1_data_in;
				end
				`MFHI_OP: begin
					moveres <= HI;
				end
				`MFLO_OP: begin
					moveres <= LO;
				end
			endcase
		end
	end

	// select a result
	always @( * ) begin
		dest_addr_out <= dest_addr_in;
		wreg_out <= wreg_in;
		case (alusel_in)
			`RES_LOGIC: begin
				dest_data_out <= logicres;
			end
			`RES_SHIFT: begin
				dest_data_out <= shiftres;
			end
			`RES_MOVE: begin
				dest_data_out <= moveres;
			end
			default: begin
				dest_data_out <= `ZeroWord;
			end
		endcase
	end

	// MTHI, MTLO
	always @( * ) begin
		if (rst == `RstEnable) begin
			whilo_out <= `False;
			hi_out    <= `ZeroWord;
			lo_out    <= `ZeroWord;
		end else if (aluop_in == `MTHI_OP) begin
			whilo_out <= `True;
			hi_out    <= src1_data_in;
			lo_out    <= LO;
		end else if (aluop_in == `MTLO_OP) begin
			whilo_out <= `True;
			hi_out    <= HI;
			lo_out    <= src1_data_in;
		end else begin
			whilo_out <= `False;
			hi_out    <= `ZeroWord;
			lo_out    <= `ZeroWord;	
		end
	end

endmodule