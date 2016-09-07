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

		input wire[`DoubleRegBus]   hilo_temp_in,
        input wire[1:0]             cnt_in,

		output reg[`RegBus]		hi_out,
		output reg[`RegBus]		lo_out,
		output reg 				whilo_out,

		output reg[`RegAddrBus]	dest_addr_out,
		output reg 				wreg_out,
		output reg[`RegBus]		dest_data_out,

        output reg[`DoubleRegBus]   hilo_temp_out,
        output reg[1:0]             cnt_out,

		output reg 	stall_req

	);
	
	// register saving logic result
	reg[`RegBus] logicres;
	// register saving shift result
	reg[`RegBus] shiftres;
	// register saving move result
	reg[`RegBus] moveres;

	reg[`RegBus] HI;
	reg[`RegBus] LO;

	// variables for arithmetic alu
	wire			ov_sum;
	wire			src1_eq_src2;
	wire			src1_lt_src2;
	reg[`RegBus]	arithmeticres;
	wire[`RegBus]	src2_in_mux;
	wire[`RegBus]	src1_in_not;
	wire[`RegBus]	result_sum;
	wire[`RegBus]	opdata1_mult; // a * b, a
	wire[`RegBus]	opdata2_mult; // a * b, b
	wire[`DoubleRegBus]	hilo_temp; // 64-bit temp result
	reg[`DoubleRegBus] 	hilo_temp1;
	reg[`DoubleRegBus]	mulres;
    reg                 stall_req_madd_msub;
	

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

	// if aluop is sub or slt, src2_in_mux = (~src2) + 1
	// otherwise src2
	assign src2_in_mux = ((aluop_in == `SUB_OP)  
					||  (aluop_in == `SUBU_OP) 
					|| (aluop_in == `SLT_OP)) ? 
					(~src2_data_in) + 1 : src2_data_in;

	assign result_sum = src1_data_in + src2_in_mux;

	// check whether overflowed
	// 1. pos + pos = neg, 2. neg + neg = pos.
	assign ov_sum = ((!src1_data_in[31] && !src2_in_mux[31]) && result_sum[31]) 
					||((src1_data_in[31] && src2_in_mux[31]) && (!result_sum[31]));

	// judge whether src1 < src2
	// if aluop is slt, then 1. neg < pos 2. pos-pos = neg 3. neg - neg = neg
	// compare unsigned integer simply by "<"
	assign src1_lt_src2 = ((aluop_in == `SLT_OP))?  
                         ((src1_data_in[31] && !src2_data_in[31]) ||   
                         (!src1_data_in[31] && !src2_data_in[31] && result_sum[31])||  
                               (src1_data_in[31] && src2_data_in[31] && result_sum[31]))  
                         :(src1_data_in < src2_data_in);

    assign src1_in_not = ~src1_data_in;

    // alu operations ARITHMETIC
    always @( * ) begin
    	if (rst == `RstEnable) begin
    		arithmeticres <= `ZeroWord;
    	end else begin
    		case (aluop_in)
	    		`SLT_OP, `SLTU_OP: begin
	    			arithmeticres <= src1_lt_src2;
	    		end
	    		`ADD_OP, `ADDU_OP, `ADDI_OP, `ADDIU_OP: begin
	    			arithmeticres <= result_sum;
	    		end
	    		`SUB_OP, `SUBU_OP: begin
	    			arithmeticres <= result_sum;
	    		end
	    		`CLZ_OP: begin
					arithmeticres <=  src1_data_in[31] ? 0  : src1_data_in[30] ? 1 :  
			                    	  src1_data_in[29] ? 2  : src1_data_in[28] ? 3 :  
			                    	  src1_data_in[27] ? 4  : src1_data_in[26] ? 5 :  
			                    	  src1_data_in[25] ? 6  : src1_data_in[24] ? 7 :  
			                    	  src1_data_in[23] ? 8  : src1_data_in[22] ? 9 :  
			                    	  src1_data_in[21] ? 10 : src1_data_in[20] ? 11 :  
			                    	  src1_data_in[19] ? 12 : src1_data_in[18] ? 13 :  
			                    	  src1_data_in[17] ? 14 : src1_data_in[16] ? 15 :  
			                    	  src1_data_in[15] ? 16 : src1_data_in[14] ? 17 :  
			                    	  src1_data_in[13] ? 18 : src1_data_in[12] ? 19 :  
			                    	  src1_data_in[11] ? 20 : src1_data_in[10] ? 21 :  
			                    	  src1_data_in[9]  ? 22 : src1_data_in[8]  ? 23 :  
			                    	  src1_data_in[7]  ? 24 : src1_data_in[6]  ? 25 :  
			                    	  src1_data_in[5]  ? 26 : src1_data_in[4]  ? 27 :  
			                    	  src1_data_in[3]  ? 28 : src1_data_in[2]  ? 29 :  
			                    	  src1_data_in[1]  ? 30 : src1_data_in[0]  ? 31 : 32 ;
	    		end
	    		`CLO_OP: begin
					arithmeticres <=  src1_in_not[31] ? 0  : src1_in_not[30] ? 1 :  
			                    	  src1_in_not[29] ? 2  : src1_in_not[28] ? 3 :  
			                    	  src1_in_not[27] ? 4  : src1_in_not[26] ? 5 :  
			                    	  src1_in_not[25] ? 6  : src1_in_not[24] ? 7 :  
			                    	  src1_in_not[23] ? 8  : src1_in_not[22] ? 9 :  
			                    	  src1_in_not[21] ? 10 : src1_in_not[20] ? 11 :  
			                    	  src1_in_not[19] ? 12 : src1_in_not[18] ? 13 :  
			                    	  src1_in_not[17] ? 14 : src1_in_not[16] ? 15 :  
			                    	  src1_in_not[15] ? 16 : src1_in_not[14] ? 17 :  
			                    	  src1_in_not[13] ? 18 : src1_in_not[12] ? 19 :  
			                    	  src1_in_not[11] ? 20 : src1_in_not[10] ? 21 :  
			                    	  src1_in_not[9]  ? 22 : src1_in_not[8]  ? 23 :  
			                    	  src1_in_not[7]  ? 24 : src1_in_not[6]  ? 25 :  
			                    	  src1_in_not[5]  ? 26 : src1_in_not[4]  ? 27 :  
			                    	  src1_in_not[3]  ? 28 : src1_in_not[2]  ? 29 :  
			                    	  src1_in_not[1]  ? 30 : src1_in_not[0]  ? 31 : 32 ;
	    		end
	    		default: begin
	    			arithmeticres <= `ZeroWord;
	    		end
	    	endcase
    	end
    end

    // multiplication
    // (~src1) + 1 if src < 0
    assign opdata1_mult = ((aluop_in ==`MUL_OP
    					|| aluop_in ==`MULT_OP
    					|| aluop_in ==`MADD_OP
    					|| aluop_in ==`MSUB_OP) 
    					&& (src1_data_in[31] == 1'b1)) ? (~src1_data_in + 1) : src1_data_in;
    // (~src2) + 1 if src < 0
    assign opdata2_mult = ((aluop_in ==`MUL_OP
    					|| aluop_in ==`MULT_OP
    					|| aluop_in ==`MADD_OP
    					|| aluop_in ==`MSUB_OP)  
    					&& (src2_data_in[31] == 1'b1)) ? (~src2_data_in + 1) : src2_data_in;
    // store the temporary result into hilo_temp
    assign hilo_temp = opdata1_mult * opdata2_mult;
    // fix the result:
    // MULT, MUL, MADD, MSUB: src1 ^ src2 == 1 => complement; otherwise, hilo_temp;
    // MULTU: the unsigned result in hilo_temp.
    always @( * ) begin
    	if (rst == `RstEnable) begin
    		mulres <= {`ZeroWord, `ZeroWord};
    	end else if (aluop_in == `MULT_OP || aluop_in == `MUL_OP ||
    				aluop_in == `MADD_OP || aluop_in == `MSUB_OP) begin
    		if (src1_data_in[31] ^ src2_data_in[31] == 1'b1) begin
    			mulres <= ~hilo_temp + 1;
    		end else begin
    			mulres <= hilo_temp;
    		end 
    	end else begin
    		mulres <= hilo_temp;
    	end
    end

    // MADD, MADDU, MSUB, MSUBU
    always @( * ) begin
    	if (rst == `RstEnable) begin
    		hilo_temp_out <= {`ZeroWord, `ZeroWord};
    		cnt_out <= 2'b00;
    		stall_req_madd_msub <= `NoStop;
    	end else begin
    		case (aluop_in)
    			`MADD_OP, `MADDU_OP: begin
    				if (cnt_in == 2'b00) begin
						hilo_temp_out       <= mulres;
						cnt_out             <= 2'b01;
						hilo_temp1          <= {`ZeroWord, `ZeroWord};
						stall_req_madd_msub <= `Stop;
    				end else if (cnt_in == 2'b01) begin
						hilo_temp_out       <= {`ZeroWord, `ZeroWord};
						cnt_out             <= 2'b10;
						hilo_temp1          <= hilo_temp_in + {HI, LO};
						stall_req_madd_msub <= `NoStop;
    				end
    			end
    			`MSUB_OP, `MSUBU_OP: begin
    				if (cnt_in == 2'b00) begin
						hilo_temp_out       <= ~mulres + 1;
						cnt_out             <= 2'b01;
						stall_req_madd_msub <= `Stop;
    				end else if (cnt_in == 2'b01) begin
						hilo_temp_out       <= {`ZeroWord, `ZeroWord};
						cnt_out             <= 2'b10;
						hilo_temp1          <= hilo_temp_in + {HI, LO};
						stall_req_madd_msub <= `NoStop;
    				end
    			end
    			default: begin
    				hilo_temp_out <= {`ZeroWord, `ZeroWord};
    				cnt_out <= 2'b00;
    				stall_req_madd_msub <= `NoStop;
    			end
    		endcase
    	end
    end

    // stall_req
    always @( * ) begin
    	stall_req = stall_req_madd_msub;
    end

	// select a result
	always @( * ) begin
		dest_addr_out <= dest_addr_in;
		if ((aluop_in == `ADD_OP 
			|| aluop_in == `ADDI_OP
			|| aluop_in == `SUB_OP) 
			&& ov_sum == `True) begin
			wreg_out <= `False;
		end else begin
			wreg_out <= wreg_in;		
		end
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
			`RES_ARITHMETIC: begin
				dest_data_out <= arithmeticres;
			end
			`RES_MUL: begin
				dest_data_out <= mulres;
			end
			default: begin
				dest_data_out <= `ZeroWord;
			end
		endcase
	end

	// MTHI, MTLO and other operations change HILO
	always @( * ) begin
		if (rst == `RstEnable) begin
			whilo_out <= `False;
			hi_out    <= `ZeroWord;
			lo_out    <= `ZeroWord;
		end else if (aluop_in == `MSUB_OP 
			|| aluop_in == `MSUBU_OP) begin
			whilo_out <= `True;
			hi_out    <= hilo_temp1[63:32];	
			lo_out    <= hilo_temp1[31:0];
		end else if (aluop_in == `MADD_OP 
			|| aluop_in == `MADDU_OP) begin
			whilo_out <= `True;
			hi_out    <= hilo_temp1[63:32];	
			lo_out    <= hilo_temp1[31:0];
		end else if (aluop_in == `MULT_OP 
			|| aluop_in == `MULTU_OP) begin
			whilo_out <= `True;
			hi_out    <= mulres[63:32];	
			lo_out    <= mulres[31:0];
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