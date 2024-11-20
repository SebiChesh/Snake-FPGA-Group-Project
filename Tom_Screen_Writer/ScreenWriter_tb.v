`timescale 1 ns/100 ps
module ScreenWriter_tb;


	 // Global Clock/Reset
    // - Clock
    reg clock;

    // - Global Reset
    reg  reset;
	 // - Apple and snake values
	 reg [7:0] appleX;
	 reg [8:0] appleY;
	 reg [1023:0] snakeX;
	 reg [1151:0] snakeY;
 
	 
    // - Application Reset - for debug

    
    // LT24 Interface
    wire             LT24Wr_n;
    wire             LT24Rd_n;
    wire             LT24CS_n;
    wire             LT24RS;
    wire             LT24Reset_n;
    wire [     15:0] LT24Data;
    wire             LT24LCDOn;



	ScreenWriter ScreenWriter_dut(
	.clock(clock),

	.reset(reset),
	.appleX(appleX),
	.appleY(appleY),
	.snakeX(snakeX),
	.snakeY(snakeY),

	.LT24Wr_n(LT24Wr_n),
	.LT24Rd_n(LT24Rd_n),
	.LT24CS_n(LT24CS_n),
	.LT24RS(LT24RS),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data(LT24Data),
	.LT24LCDOn(LT24LCDOn)
	);


	initial begin
	  reset <= 1'b1;
	  #10;
	  reset <= 1'b0;
	  appleY <= 160;
	  appleX <= 120;
	  snakeX[7:0] = 		40;
	  snakeX[15:8] =		50;
	  snakeX[23:16] =		60;
	  snakeX[1023:24]=	0;
	  snakeY[8:0] =		30;
	  snakeY[17:9] =		30;
	  snakeY[26:18] =		30;
	  snakeY[1151:27]=	0;	  
	  #10000000;
	  snakeX[7:0] = 		30;
	  snakeX[15:8] =		40;
	  snakeX[23:16] =		50;
	  snakeX[1023:24]=	0;
	  snakeY[8:0] =		30;
	  snakeY[17:9] =		30;
	  snakeY[26:18] =		30;
	  snakeY[1151:27]=	0;
	  
	end

	always begin
		clock <= 1'b0;
		#10;
		clock <= 1'b1;
		#10;
	end

endmodule