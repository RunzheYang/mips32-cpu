`timescale 1ns/1ps

module sopc_tb ( );

	reg CLOCK;
	reg rst;

	initial begin
		CLOCK = 1'b0;
		forever #10 CLOCK = ~CLOCK;
	end


	initial begin
				rst = `RstEnable;
		#195 	rst = `RstDisable;
		#4000	$stop;
	end

	sopc sopc0 (
			.clk 	(CLOCK),
			.rst 	(rst)
		);

	initial begin            
            $dumpfile("sopc_tb.vcd");
            $dumpvars(0, sopc_tb);
	end

endmodule