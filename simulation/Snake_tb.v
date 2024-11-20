/*=========================================================
 * Testbench for Scoreboard Display Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 05 April 2024
 *
 *=========================================================
 *Description
 *--------------------------------------------------------------
 * This module tests the functionality of the Snake module
 * for different input combinations of direction and appleEaten. 
 * Both clock and screenclock inputs are inverted at different 
 * cycles. The screenclock cycles were used to check if the 
 * snake coordinates are changing according the correct direction
 * input and clock cycles were used to update the size from the
 * appleEaten input. 
 *--------------------------------------------------------------
*/

//------------------------------------------------------
// Timescale derivative
//------------------------------------------------------
`timescale 1 ns/100 ps

//------------------------------------------------------
// Module Declaration
//------------------------------------------------------
module Snake_tb;

//------------------------------------------------------
//Declaration of inputs
//------------------------------------------------------
reg clock;
reg screenClock;
reg appleEaten;
reg [3:0] direction;
reg reset;

//------------------------------------------------------
//Declaration of outputs to the module
//------------------------------------------------------
wire [1023:0] snakeLocX;
wire [1151:0] snakeLocY;
wire [7:0] size;

//------------------------------------------------------
//Instantiate dut
//------------------------------------------------------
Snake #(
	//parameter value set to 10
	.SegWidth(10)

)  Snake_dut (
	
	//..................................................
	// Module inputs
	//..................................................
	.reset (reset),
	.clock (clock),
	.screenClock ( screenClock),
	.appleEaten ( appleEaten),
	.direction ( direction),

	//..................................................
	// Module outputs
	//..................................................	
	.snakeLocX ( snakeLocX),
	.snakeLocY ( snakeLocY),
	.size ( size)

);


integer i, j;					//Integers that will be used in the test bench logic

initial begin  

	$display ("Simulation started at %d ns",$time);				//Display Simulation Start
	
	//......................................................
	// Display critical values to evaluate the functionality 
	// of the module. Snake size is checked for upto 5 
	// segments.
	//......................................................	
	$monitor ("%d ns: reset=%b screenclock=%b appleEaten=%b direction=%b size=%d
				SnakeLocation: (%d %d) (%d %d) (%d %d) (%d %d) (%d %d)",
				$time, reset, screenClock,appleEaten, direction, size, 
				snakeLocX[7:0],snakeLocY[8:0],snakeLocX[15:8],snakeLocY[17:9],
				snakeLocX[23:16],snakeLocY[26:18],snakeLocX[31:24],snakeLocY[35:27],
				snakeLocX[39:32],snakeLocY[44:36]);
				
	//......................................................
	// Initial values
	//......................................................
	reset=1; screenClock=0; clock=0; appleEaten=0; direction=0000;


	#10; reset=~reset; clock=~clock; direction = 0100; 					//Inverting reset and update clock, direction

	
	//.............................................................................
	// The below for loop contains two loops. The loop variable i will have 
	// four iterations and in each iteration, direction and appleEaten values are
	// changed to monitor the Snake body coordinates. In each iterations of i, the 
	// screenclock signal will be inverted 5 times to check snake movement in the 
	// right direction using another for loop with loop variable j.
	//.............................................................................
	for (i=0; i<4; i=i+1) begin 

		//
		//	Change screenclock 5 times
		//
		for (j=0;j<6; j=j+1) begin
			#10; screenClock=~screenClock;
		end

		//
		// Case statement to vary direction based on the value of i
		//
		case (i) 
			1: direction = 4'b0010;
			2: direction = 4'b1000;
			3: direction = 4'b0001;
			default: direction = 0100;
		endcase

		//
		// Below lines of code performs 3 clock cycles and 3 screenclock cycles
		// appleEaten signal will stay high for one full clock cycle.
		//
		#10; clock=~clock; 
		#10;clock=~clock; appleEaten=~appleEaten; screenClock=~screenClock; 
		#10; screenClock=~screenClock; clock=~clock;
		#10; clock=~clock; 
		#10; clock=~clock; appleEaten=~appleEaten; screenClock=~screenClock; 
		#10; screenClock=~screenClock; clock=~clock;
		
	end

#10; reset=~reset; 					// Lastly, the reset bit is set high to check reset logic

$display ("Simulation has stopped at %d ns ", $time);				//Simulation Stop Indication


end

endmodule
