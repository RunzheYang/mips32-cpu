module execute (

		input wire rst,

		input wire[`AluOpBus]	aluop_in,
		input wire[`AluSelBus]	alusel_in,
		input wire[`RegBus]		src1_data_in,
		input wire[`RegBus]		src2_data_in,
		input wire[`RegAddrBus]	dest_addr_in,
		input wire				wreg_in,

		output reg[`RegAddrBus]	dest_addr_out,
		output reg 				wreg_out,
		output reg[`RegBus]		dest_data_out

	);
	
	// register saving logic result
	reg[`RegBus] logicout;
	// register saving shift result
	reg[`RegBus] shiftout;

	// alu operations LOGIC
	always @( * ) begin
		if (rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_in)
				`AND_OP: begin
					logicout <= src1_data_in & src2_data_in;
				end
				`OR_OP: begin
					logicout <= src1_data_in | src2_data_in;
				end
				`XOR_OP: begin
					logicout <= src1_data_in ^ src2_data_in;
				end
				`NOR_OP: begin
					logicout <= ~(src1_data_in | src2_data_in);
				end
				default: begin
					logicout <= `ZeroWord;
				end
			endcase
		end
	end

	// alu operations SHIFT
	always @( * ) begin
		if (rst == `RstEnable) begin
			shiftout <= `ZeroWord;
		end else begin
			case (aluop_in)
				`SLL_OP: begin
					shiftout <= src2_data_in << src1_data_in[4:0];
				end
				`SRL_OP: begin
					shiftout <= src2_data_in >> src1_data_in[4:0];
				end
				`SRA_OP: begin
					shiftout <= 
					({32{src2_data_in[31]}} << (6'd32 - {1'b0, src1_data_in[4:0]})) 
					| src2_data_in >> src1_data_in[4:0];
				end
				default: begin
					shiftout <= `ZeroWord;
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
				dest_data_out <= logicout;
			end
			`RES_SHIFT: begin
				dest_data_out <= shiftout;
			end
			default: begin
				dest_data_out <= `ZeroWord;
			end
		endcase
	end

endmodule