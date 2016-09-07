module ex_mem (

		input wire 	clk,
		input wire	rst,

		input wire[`RegAddrBus]	ex_dest_addr,
		input wire				ex_wreg,
		input wire[`RegBus]		ex_dest_data,

		input wire[`RegBus]		ex_hi,
		input wire[`RegBus]		ex_lo,
		input wire				ex_whilo,

		input wire[5:0]			stall,

		input wire[`DoubleRegBus]	hilo_in,
		input wire[1:0]				cnt_in,

		output reg[`DoubleRegBus]	hilo_out,
		output reg[1:0]				cnt_out,

		output reg[`RegAddrBus]	mem_dest_addr,
		output reg 				mem_wreg,
		output reg[`RegBus]		mem_dest_data,

		output reg[`RegBus]		mem_hi,
		output reg[`RegBus]		mem_lo,
		output reg				mem_whilo

	);

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			mem_dest_addr <= `NOPRegAddr;
			mem_wreg      <= `False;
			mem_dest_data <= `ZeroWord;
			mem_hi        <= `ZeroWord;
			mem_lo        <= `ZeroWord;
			mem_whilo     <= `False;
			hilo_out      <= {`ZeroWord, `ZeroWord};
			cnt_out       <= 2'b00;
		end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
			mem_dest_addr <= `NOPRegAddr;
			mem_wreg      <= `False;
			mem_dest_data <= `ZeroWord;
			mem_hi        <= `ZeroWord;
			mem_lo        <= `ZeroWord;
			mem_whilo     <= `False;
			hilo_out      <= hilo_in;
			cnt_out       <= cnt_in;
		end else if (stall[3] == `NoStop) begin
			mem_dest_addr <= ex_dest_addr;
			mem_wreg      <= ex_wreg;
			mem_dest_data <= ex_dest_data;
			mem_hi        <= ex_hi;
			mem_lo        <= ex_lo;
			mem_whilo     <= ex_whilo;
			hilo_out      <= {`ZeroWord, `ZeroWord};
			cnt_out       <= 2'b00;
		end else begin
			hilo_out      <= hilo_in;
			cnt_out       <= cnt_in;
		end
	end

endmodule