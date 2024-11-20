`timescale  1 ns/100 ps
module Top_Testbench;

	//inputs
	reg [3:0] keys;
	reg resetHW;
	reg clock;

	//wires
	wire [6:0] seg0;
	wire [6:0] seg1;
	wire [6:0] seg2;
	wire LT24Wr_n;
	wire LT24Rd_n;
	wire LT24CS_n;
	wire LT24RS;
	wire LT24Reset_n;
	wire [15:0] LT24Data;
	wire LT24LCDOn;


	Snake_Top Snake_Top_DUT(
	.keys(keys),
	.resetHW(resetHW),
	.clock(clock),
	.seg0(seg0),
	.seg1(seg1),
	.LT24Wr_n(LT24Wr_n),
	.LT24Rd_n(LT24Rd_n),
	.LT24CS_n(LT24CS_n),
	.LT24RS(LT24RS),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data(LT24Data),
	.LT24LCDOn(LT24LCDOn)
	);

	initial begin
		resetHW <= 1'b0;
		#100;
		resetHW <= 1'b1;
		#100;
		resetHW <= 1'b0;
		#100;
		keys<= 4'b0001;
	end
	
	always begin
		clock <= 1'b0;
		#10;
		clock <= 1'b1;
		#10;
	end
	

	
	
endmodule