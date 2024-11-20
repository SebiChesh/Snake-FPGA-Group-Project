/*=========================================================
 * Testbench for Scoreboard Display Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 31 March 2024
 *
 *=========================================================
 *Description
 *--------------------------------------------------------------
 * This module tests the functionality of the Scoreboard module
 * for different input combinations of level, size, debugMode, 
 * gameOver signals in a synchronous mode where screenClock cycle
 * time period is 6250 times that of the clock signal. In the 
 * DE1Soc board, the clock has 50MHz frequency and the screenClock
 * has a lower frequency of 4Hz. However, the test methodology 
 * used in this test bench will work to simulate same functionality 
 * with a lower simulation time.
 *--------------------------------------------------------------
*/

//------------------------------------------------------
// Timescale derivative
//------------------------------------------------------
`timescale 1 ns/100 ps

//------------------------------------------------------
// Module Declaration
//------------------------------------------------------
module Scoreboard_tb;

//------------------------------------------------------
//Declaration of inputs
//------------------------------------------------------
reg screenClock, reset, gameOver, debugMode, clock;
reg [7:0] size;
reg [7:0] appleLocX;
reg [8:0] appleLocY;
reg [2:0] level;

//------------------------------------------------------
//Declare outputs of the module
//------------------------------------------------------
wire [6:0] seg0; wire [6:0] seg1; wire [6:0] seg2;
wire [6:0] seg3; wire [6:0] seg4; wire [6:0] seg5;

//------------------------------------------------------
//Instantiate dut
//------------------------------------------------------
Scoreboard Scoreboard_dut (
	
	//..................................................
	// Module inputs
	//..................................................
	.clock ( clock),
	.screenClock ( screenClock),
	.size ( size),
	.gameOver (gameOver),
	.appleLocX ( appleLocX),
	.appleLocY ( appleLocY),
	.reset ( reset),
	.level ( level),
	.debugMode (debugMode),
	
	//..................................................
	// Module outputs
	//..................................................
	.seg0 ( seg0),
	.seg1 ( seg1),
	.seg2 ( seg2),
	.seg3 ( seg3),
	.seg4 ( seg4),
	.seg5 ( seg5)
	
);

//---------------------------------------------------
//Integers that will be used in the test bench logic
//---------------------------------------------------
integer i, j;

//------------------------------------------------------
// Test bench logic
//------------------------------------------------------
initial begin
	
	$display ("Simulation has started at %d ns", $time);		//Display Simulation Start
		
	//......................................................
	// Initial values
	//......................................................
	reset = 1; screenClock = 0; size = 1; gameOver = 0; debugMode = 0; level = 3'b000; 

	appleLocX = 15; appleLocY = 12; clock = 0;

	//.....................................................
	// Inverting reset signal and clock signal
	//.....................................................
	#30; reset = ~reset; clock = ~clock; 
	
	//.........................................................
	// For loop for varying the clock and screenClock signals.
	// The screenClock signal is 6250 times slower than the clock
	// signal. The same is achieved by using another for loop 
	// with the loop variable j for inverting the clock signal.
	//.........................................................
	for (i=0; i<500; i=i+1) begin

		for (j=0; j<6250; j = j+1) begin
			#10; clock = ~clock;
		end

		#10; screenClock = ~screenClock; 		//Screenclock inverted
		
		//
		//For every even value of i, size will be incremented by 2
		//
		if (i%2) begin
			
			size = size+1;
			
		end

		//
		// For every multiples of 40, debug signal will be inverted
		//
		if (i%40==0) begin
			debugMode = ~debugMode;
			appleLocX = appleLocX + 11;
			appleLocY = appleLocX + 16;
		end

		//
		// For every multiples of 20, gameOver signals will be inverted
		//
		if (i%20==0) begin
			
			gameOver = ~gameOver;
			
		end

	
		//
		// At every iterations, display all the critical values on the transcript window
		// of Modelsim
		//
		$display (" %d cycles: screenClock=%b, debug=%b, gameOver=%b size=%d, num = (%b %b %b %b %b %b )",
				(1+i/2), screenClock, debugMode, gameOver, size, seg5, seg4, seg3, seg2, seg1, seg0);

	end
	
	$display ("Simulation has ended at %d ns", $time); 			//End simulation

end

endmodule