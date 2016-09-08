module memory (

		input wire	rst,

		input wire[`RegAddrBus]	dest_addr_in,
		input wire				wreg_in,
		input wire[`RegBus]		dest_data_in,

		input wire[`RegBus]		hi_in,
		input wire[`RegBus]		lo_in,
		input wire 				whilo_in,

		input wire[`AluOpBus]	aluop_in,
		input wire[`RegBus]		mem_addr_in,
		input wire[`RegBus]		src2_data_in,

		input wire[`RegBus]		mem_data_in,

		output reg[`RegAddrBus]	dest_addr_out,
		output reg 				wreg_out,
		output reg[`RegBus]		dest_data_out,

		output reg[`RegBus]		hi_out,
		output reg[`RegBus]		lo_out,
		output reg 				whilo_out,

		output reg[`RegBus]		mem_addr_out,
		output wire				mem_we_out,
		output reg[3:0]			mem_sel_out,
		output reg[`RegBus]		mem_data_out,
		output reg 				mem_ce_out

	);

	wire[`RegBus]	zero32;
	reg 			mem_we;

	assign mem_we_out = mem_we;
	assign zero32 = `ZeroWord;

	always @( * ) begin
		if (rst == `RstEnable) begin
			dest_addr_out <= `NOPRegAddr;
			wreg_out      <= `False;
			dest_data_out <= `ZeroWord;
			hi_out        <= `ZeroWord;
			lo_out        <= `ZeroWord;
			whilo_out     <= `False;
			mem_addr_out  <= `ZeroWord;
			mem_we        <= `False;
			mem_sel_out   <= 4'b0000;
			mem_data_out  <= `ZeroWord;
			mem_ce_out    <= `ChipDisable;
		end else begin
			dest_addr_out <= dest_addr_in;
			wreg_out      <= wreg_in;
			dest_data_out <= dest_data_in;
			hi_out        <= hi_in;
			lo_out        <= lo_in;
			whilo_out     <= whilo_in;
			mem_addr_out  <= `ZeroWord;
			mem_we        <= `False;
			mem_sel_out   <= 4'b1111;
			mem_ce_out    <= `ChipDisable;
			case (aluop_in)
				`LB_OP:     begin		
					mem_addr_out <= mem_addr_in;
					mem_we     <= `False;
					mem_ce_out   <= `ChipEnable;
					case (mem_addr_in[1:0])
						2'b00: begin
							dest_data_out   <= {{24{mem_data_in[31]}},mem_data_in[31:24]};
							mem_sel_out <= 4'b1000;
						end
						2'b01: begin
							dest_data_out   <= {{24{mem_data_in[23]}},mem_data_in[23:16]};
							mem_sel_out <= 4'b0100;
						end
						2'b10: begin
							dest_data_out   <= {{24{mem_data_in[15]}},mem_data_in[15:8]};
							mem_sel_out <= 4'b0010;
						end
						2'b11: begin
							dest_data_out   <= {{24{mem_data_in[7]}},mem_data_in[7:0]};
							mem_sel_out <= 4'b0001;
						end
						default:   begin
							dest_data_out   <= `ZeroWord;
						end
					endcase
				end
				`LBU_OP:     begin
						mem_addr_out <= mem_addr_in;
						mem_we     <= `False;
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00: begin
									dest_data_out   <= {{24{1'b0}},mem_data_in[31:24]};
									mem_sel_out <= 4'b1000;
							end
							2'b01: begin
									dest_data_out   <= {{24{1'b0}},mem_data_in[23:16]};
									mem_sel_out <= 4'b0100;
							end
							2'b10: begin
									dest_data_out   <= {{24{1'b0}},mem_data_in[15:8]};
									mem_sel_out <= 4'b0010;
							end
							2'b11: begin
									dest_data_out   <= {{24{1'b0}},mem_data_in[7:0]};
									mem_sel_out <= 4'b0001;
							end
							default:   begin
									dest_data_out   <= `ZeroWord;
							end
						endcase
					end
				`LH_OP:		begin		
							mem_addr_out <= mem_addr_in;
						mem_we     <= `False;
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00: begin
								dest_data_out   <= {{16{mem_data_in[31]}},mem_data_in[31:16]};
								mem_sel_out <= 4'b1100;
							end
							2'b10: begin
								dest_data_out   <= {{16{mem_data_in[15]}},mem_data_in[15:0]};
								mem_sel_out <= 4'b0011;
							end
							default:   begin
								dest_data_out   <= `ZeroWord;
							end
						endcase
					end
				`LHU_OP:     begin
						mem_addr_out <= mem_addr_in;
						mem_we     <= `False;
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00:  begin
								dest_data_out   <= {{16{1'b0}},mem_data_in[31:16]};
								mem_sel_out <= 4'b1100;
							end
							2'b10:  begin
								dest_data_out   <= {{16{1'b0}},mem_data_in[15:0]};
								mem_sel_out <= 4'b0011;
							end
							default:    begin
								dest_data_out   <= `ZeroWord;
							end
						endcase
					end
				`LW_OP:		begin
						mem_addr_out <= mem_addr_in;
						mem_we     <= `False;
						dest_data_out    <= mem_data_in;
						mem_sel_out  <= 4'b1111;
						mem_ce_out   <= `ChipEnable;
				end
				`LWL_OP:     begin
							mem_addr_out <= {mem_addr_in[31:2], 2'b00};
						mem_we     <= `False;
						mem_sel_out  <= 4'b1111;
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00:  begin
									dest_data_out <= mem_data_in[31:0];
							end
							2'b01:  begin
									dest_data_out <= {mem_data_in[23:0],src2_data_in[7:0]};
							end
							2'b10:  begin
									dest_data_out <= {mem_data_in[15:0],src2_data_in[15:0]};
							end
							2'b11:  begin
									dest_data_out <= {mem_data_in[7:0],src2_data_in[23:0]};
							end
							default:    begin
									dest_data_out <= `ZeroWord;
							end
						endcase
				end
				`LWR_OP:      begin 
						mem_addr_out <= {mem_addr_in[31:2], 2'b00};
						mem_we     <= `False;
						mem_sel_out  <= 4'b1111;
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00: begin
									dest_data_out <= {src2_data_in[31:8],mem_data_in[31:24]};
							end
							2'b01: begin
									dest_data_out <= {src2_data_in[31:16],mem_data_in[31:16]};
							end
							2'b10: begin
									dest_data_out <= {src2_data_in[31:24],mem_data_in[31:8]};
							end
							2'b11: begin
									dest_data_out <= mem_data_in;
							end
							default: begin
									dest_data_out <= `ZeroWord;
							end
						endcase
				end
				`SB_OP:		begin 
						mem_addr_out <= mem_addr_in;
						mem_we     <= `True;
						mem_data_out <= {src2_data_in[7:0],src2_data_in[7:0],
														src2_data_in[7:0],src2_data_in[7:0]};
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00: begin
								mem_sel_out <= 4'b1000;
							end
							2'b01: begin
								mem_sel_out <= 4'b0100;
							end
							2'b10: begin
								mem_sel_out <= 4'b0010;
							end
							2'b11: begin
								mem_sel_out <= 4'b0001; 
							end
							default: begin
								mem_sel_out <= 4'b0000;
							end
						endcase
				end
				`SH_OP:		begin 
						mem_addr_out <= mem_addr_in;
						mem_we     <= `True;
						mem_data_out <= {src2_data_in[15:0],src2_data_in[15:0]};
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00: begin
								mem_sel_out <= 4'b1100;
							end
							2'b10: begin
								mem_sel_out <= 4'b0011;
							end
							default: begin
								mem_sel_out <= 4'b0000;
							end
						endcase
				end
				`SW_OP:		begin 
						mem_addr_out <= mem_addr_in;
						mem_we     <= `True;
						mem_data_out <= src2_data_in;
						mem_sel_out  <= 4'b1111;
						mem_ce_out   <= `ChipEnable;
				end
				`SWL_OP:      begin 
						mem_addr_out <= {mem_addr_in[31:2], 2'b00};
						mem_we     <= `True;
						mem_ce_out   <= `ChipEnable;
						case (mem_addr_in[1:0])
							2'b00: begin 
								mem_sel_out <= 4'b1111;
								mem_data_out <= src2_data_in;
							end
							2'b01: begin
								mem_sel_out <= 4'b0111;
								mem_data_out <= {zero32[7:0],src2_data_in[31:8]};
							end
							2'b10: begin
								mem_sel_out <= 4'b0011;
								mem_data_out <= {zero32[15:0],src2_data_in[31:16]};
							end
							2'b11: begin
								mem_sel_out <= 4'b0001;
								mem_data_out <= {zero32[23:0],src2_data_in[31:24]};
							end
							default: begin
								mem_sel_out <= 4'b0000;
							end
					endcase
				end
				`SWR_OP:      begin 
					mem_addr_out <= {mem_addr_in[31:2], 2'b00};
					mem_we     <= `True;
					mem_ce_out   <= `ChipEnable;
							case (mem_addr_in[1:0])
								2'b00: begin 
									mem_sel_out  <= 4'b1000;
									mem_data_out <= {src2_data_in[7:0],zero32[23:0]};
								end
								2'b01: begin
									mem_sel_out  <= 4'b1100;
									mem_data_out <= {src2_data_in[15:0],zero32[15:0]};
								end
								2'b10: begin
									mem_sel_out  <= 4'b1110;
									mem_data_out <= {src2_data_in[23:0],zero32[7:0]};
								end
								2'b11: begin
									mem_sel_out  <= 4'b1111;
									mem_data_out <= src2_data_in[31:0];
								end
								default:  begin
									mem_sel_out  <= 4'b0000;
								end
							endcase
				end 
				default: begin   
				end
			endcase
		end
	end

endmodule