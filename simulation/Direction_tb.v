/*
 * Synchronus testbench for Direction Module
 * ----------------------------
 * By: Sebastian Cheshire
 * For: University of Leeds
 * Date: 4th April 2024
 *
 * Description
 * ------------
 * This testbench exhaustively tests all possible inputs into the direction module
 * It tests that the snake can go from its default no movent to all directions
 * It checks that the snake direction cant be accidently reversed into itself i.e if it moving forwards, the snake wont go backwards if the user pressed back button
 * It checks that all directions apart from reversing directions can be achieved from any direction
 * 
 *
 * It takes as input 1 bit clock, 1 bit reset and 4 bit key input.
 * It outputs a 4 bit reg called direction which is the direction snake should move in based on user KEY pressing input
 *
 * Thank you to Renwentai Zhou who greatly helped develop the code for simulating a clock in a testbench
 * during class Lab sessions and the same code snippet has been used here.
 */
 
`timescale 1 ns/100 ps

module Direction_tb;

	// Parameter declaration

	localparam NUM_CYCLES = 100; // simulation runs for this many clock cycles
	localparam CLOCK_FREQ = 50000000; // set to the clock frequency of the DE1 soc board
	localparam RST_CYCLES = 1; // number cycles of reset at the beginning of simulation

	// Testbench generated signals

	reg clock;
	reg reset;
	reg [3:0] keys; // simulates user inputs of pressing keys KEY0-3

	// DUT output signals

	wire [3:0] direction; // direction of travel of snake

	// Calculate the period for half a clock cycle

	real HALF_CLOCK_PERIOD = (1e9 / $itor(CLOCK_FREQ)) / 2.0;

	Direction Direction_dut (
		.clock ( clock ),
		.reset ( reset ),
		.keysHW ( keys ),
		.direction ( direction )

	);

	// Testbench logic

	initial begin

		//print to console simualtion started and time

		$display("%d ns\tSimulation Started", $time);

		// setting inputs to 0
		clock = 1'b0;
		reset = 1'b0;
		keys = 4'b0000;

		
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0001; // transition NO_MOVEMENT --> DOWN
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0000; // transition DOWN --> NO_MOVEMENT (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0010; // transition DOWN --> UP (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0100; // transition DOWN --> RIGHT
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0001; // transition RIGHT --> DOWN
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b1000; // transition DOWN --> LEFT
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0001; // transition LEFT --> DOWN
		#(2*HALF_CLOCK_PERIOD);
		
		reset = 1'b1;
		keys = ~4'b0010; // transition NO_MOVEMENT --> UP
		#(2*HALF_CLOCK_PERIOD);
		reset = 1'b0;
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0000; // transition UP --> NO_MOVEMENT (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0001; // transition UP --> DOWN (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0100; // transition UP --> RIGHT
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0010; // transition RIGHT --> UP
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b1000; // transition UP --> LEFT
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0010; // transition LEFT --> UP
		#(2*HALF_CLOCK_PERIOD);
		
		reset = 1'b1;
		keys = ~4'b0100; // transition NO_MOVEMENT --> RIGHT
		#(2*HALF_CLOCK_PERIOD);
		reset = 1'b0;
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0000; // transition RIGHT --> NO_MOVEMENT (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b1000; // transition RIGHT --> LEFT (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		
		reset = 1'b1;
		keys = ~4'b1000; // transition NO_MOVEMENT --> LEFT
		#(2*HALF_CLOCK_PERIOD);
		reset = 1'b0;
		#(2*HALF_CLOCK_PERIOD);	
		keys = ~4'b0000; // transition LEFT --> NO_MOVEMENT (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'b0100; // transition LEFT --> RIGHT (NO TRANSITION SHOULD OCCUR)
		#(2*HALF_CLOCK_PERIOD);
		
		keys = ~4'd3; // transition LEFT --> 3 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd5; // transition LEFT --> 5 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd6; // transition LEFT --> 6 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd7; // transition LEFT --> 7 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd9; // transition LEFT --> 9 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd10; // transition LEFT --> 10 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd11; // transition LEFT --> 11 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd12; // transition LEFT --> 12 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd13; // transition LEFT --> 13 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd14; // transition LEFT --> 14 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		keys = ~4'd15; // transition LEFT --> 15 (DOUBLE PRESS)
		#(2*HALF_CLOCK_PERIOD);
		
		
	end

	// Resets test bench for RST_CYCLES number of cycles

	initial begin

		reset = 1'b1;	// set reset high
		repeat(RST_CYCLES) @(posedge clock);	//Wait for RST_CYCLES number of cycles
		reset = 1'b0;	// Set reset signal to low
	 
	end

	//generate the clock
	integer half_cycles = 0;


 	// Thank you to Renwentai Zhou who greatly helped develop the code for simulating a clock in a testbench
 	// during class Lab sessions and the same code snippet has been used here.

	always begin
		//Generates the next half cycle of the simulated clock
		
		#(HALF_CLOCK_PERIOD);          // Half clock cycle delay
		clock = ~clock;                // Inverts clock value 
		half_cycles = half_cycles + 1; // Counter Incremented by 1
		
		// Checks if the desired number of half clock cycles have been completed and if so, stop simulation
		if (half_cycles == (2*NUM_CYCLES)) begin 
		
			half_cycles = 0; 		   // Reset half_cycles
			$stop;                     // Stop the simulation
		end
	end

endmodule