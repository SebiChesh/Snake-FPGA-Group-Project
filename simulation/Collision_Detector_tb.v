/*
 * Synchronus testbench for Collision_Detector Module
 * ----------------------------
 * By: Sebastian Cheshire
 * For: University of Leeds
 * Date: 7th April 2024
 *
 * Description
 * ------------
 *  Testbench that conducts full exhaustive testing to ensure the submodule was robust and could handle
 *  full/partial overlap, glance collisions (1 pixel overlap) and glance misses in all orientations.
 *  Thank you to Renwentai Zhou who greatly helped develop the code for simulating a clock in a testbench
 *  during class Lab sessions and the same code snippet has been used here.
 */
 
`timescale 1 ns/100 ps

module Collision_Detector_tb;

	// Parameter declaration

	localparam NUM_CYCLES = 100; // simulation runs for this many clock cycles
	localparam CLOCK_FREQ = 50000000; // set to the clock frequency of the DE1 soc board
	localparam RST_CYCLES = 2; // number cycles of reset at the beginning of simulation

	// Testbench generated signals

	reg clock;
	reg reset;
	reg [1023:0] snakeLocX;
	reg [1152:0] snakeLocY;
	reg [7:0] size;
	reg [7:0] appleLocX;
	reg [8:0] appleLocY;

	// DUT output signals
	
	wire appleEaten;
	wire collision;

	// Calculate the period for half a clock cycle

	real HALF_CLOCK_PERIOD = (1e9 / $itor(CLOCK_FREQ)) / 2.0;
	
	// Instatiation of DUT
	
	Collision_Detector #(
	
		// Parameter declaration
		.SegWidth(10),
		.SegHeight(10),
		.BorderThickness(20),
		.DisplayWidth(240),
		.DisplayHeight(320),
		.AppleWidth(10),
		.AppleHeight(10)
	
	) Collision_Detector_dut (
	
		.snakeLocX( snakeLocX ),
		.snakeLocY( snakeLocY ),
		.size( size ),
		.appleLocX( appleLocX ),
		.appleLocY( appleLocY ),
		.clock( clock ),
		.reset( reset ),
		.appleEaten( appleEaten ),
		.collision( collision ),
		.screenClock( clock )
	
	);

	

	// Testbench logic

	initial begin

		//print to console simualtion started and time

		$display("%d ns\tSimulation Started", $time);
		
		$monitor("%d ns: reset=%b clock=%b appleEaten:%b collision:%b size=%d AppleLocation: (%d %d) SnakeLocationHead:(%d,%d) SnakeLocationSeg1: (%d %d) SnakeLocationSeg2: (%d %d) SnakeLocationSeg3 (%d %d)", $time, reset, clock, appleEaten, collision, size, appleLocX,
		appleLocY, snakeLocX[7:0], snakeLocY[8:0], snakeLocX[15:8], snakeLocY[17:9], snakeLocX[23:16], snakeLocY[26:18], snakeLocX[31:24], snakeLocY[35:27]);
 
		// setting variables to known states
		clock = 1'b0;
		reset = 1'b0;
		snakeLocX[7:0] = 8'd150; // setting snake head to x coordiante  pixel 150
		snakeLocY[8:0] = 9'd150; // setting snake head to y coordiante  pixel 150
		snakeLocX[1023:8] = 1016'd0; // setting rest of snake body to pixel 0
		snakeLocY[1152:9] = 1143'd0; // setting rest of snake body to pixel 0
		size = 8'd1; // setting size to 1
		appleLocX = 8'd0; // setting apple x location to pixel 0
		appleLocY = 9'd20; // setting apple y location to pixel 20
		 
		// snake has not collided with anything snake head location (30,30) segments 1: (40,40) 2: (50,50) 3: (60,60) size 4
		#(9*HALF_CLOCK_PERIOD);
		size <= 8'd4;
		snakeLocX[7:0] <= 8'd30;
		snakeLocX[15:8] <= 8'd40;
		snakeLocX[23:16] <= 8'd50;
		snakeLocX[31:24] <= 8'd60;
		snakeLocY[8:0] <= 9'd30;
		snakeLocY[17:9] <= 9'd40;
		snakeLocY[26:18] <= 9'd50;
		snakeLocY[35:27] <= 9'd60;
		
		// snake collides with apple direct collision
		#(4*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd30;
		appleLocY <= 8'd30;

		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;
		
		// Apple moves. apple eaten should overlap collide with snake. top left corner of snake inside apple
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd25;
		appleLocY <= 8'd25;
	
		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;
		
		// Apple moves. apple eaten should go high. overlap collide with snake. top left corner of apple inside snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd35;
		appleLocY <= 8'd35;

		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten goes high should. overlap collide with snake. with no top left corners inside either apple segment or snake head segment
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd35;
		appleLocY <= 8'd25;

		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten should go high. collides with glancing touch of 1 pixel over lap on left side of snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd21;
		appleLocY <= 8'd30;

		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten should go high. Collides with glancing touch of 1 pixel overlap on right side of snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd39;
		appleLocY <= 8'd30;
		
		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten should go high. Collides with glancing touch of 1 pixel overlap on top side of snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd30;
		appleLocY <= 8'd21;

		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten stay low. Near glancing miss of 1 pixel space on left side of snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd20;
		appleLocY <= 8'd30;

		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten stay low. Near glancing miss of 1 pixel space on right side of snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd40;
		appleLocY <= 8'd30;
		
		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten stay low. Near glancing miss of 1 pixel space on top side of snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd30;
		appleLocY <= 8'd20;

		// Apple moves. apple eaten should go low
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd70;
		appleLocY <= 8'd70;

		// Apple moves. apple eaten stay low. Near glancing miss of 1 pixel space on bottom side of snake
		#(2*HALF_CLOCK_PERIOD);
		appleLocX <= 8'd30;
		appleLocY <= 8'd40;

		//glancing miss with left wall. Collision stays low
		#(2*HALF_CLOCK_PERIOD);
		snakeLocX[7:0] <= 8'd20;
		snakeLocY[8:0] <= 9'd100;
		
		//Collision with left wall. Collision goes high
		#(6*HALF_CLOCK_PERIOD);
		snakeLocX[7:0] <= 8'd19;
		snakeLocY[8:0] <= 9'd100;
		
		#(6*HALF_CLOCK_PERIOD);
		reset <=1'b1;
		
		//Glancing miss with top wall. Collision stays low
		#(2*HALF_CLOCK_PERIOD);
		reset <=1'b0;
		snakeLocX[7:0] <= 8'd100;
		snakeLocY[8:0] <= 9'd20;
		
		//Collision with top wall. Collision goes high
		#(6*HALF_CLOCK_PERIOD);		
		snakeLocX[7:0] <= 8'd100;
		snakeLocY[8:0] <= 9'd19;
		
		#(6*HALF_CLOCK_PERIOD);
		reset <=1'b1;
		
		//Glancing miss with right wall. Collision stays low
		#(2*HALF_CLOCK_PERIOD);
		reset <=1'b0;
		snakeLocX[7:0] <= 8'd210;
		snakeLocY[8:0] <= 9'd100;
		
		//collision with right wall. Collision goes high
		#(6*HALF_CLOCK_PERIOD);
		snakeLocX[7:0] <= 8'd211;
		snakeLocY[8:0] <= 9'd100;
		
		#(6*HALF_CLOCK_PERIOD);
		reset <=1'b1;

		//Glancing miss with bottom wall collision stays low
		#(2*HALF_CLOCK_PERIOD);
		reset <=1'b0;
		snakeLocX[7:0] <= 8'd100;
		snakeLocY[8:0] <= 9'd290;
	
		// collision with bottom wall
		#(6*HALF_CLOCK_PERIOD);
		snakeLocX[7:0] <= 8'd100;
		snakeLocY[8:0] <= 9'd291;
		
		
		#(6*HALF_CLOCK_PERIOD);
		reset <=1'b1;
		#(2*HALF_CLOCK_PERIOD);
		reset <=1'b0;
		snakeLocX[7:0] <= 8'd100;
		snakeLocX[15:8] <= 8'd110;
		snakeLocX[23:16] <= 8'd120;
		snakeLocX[31:24] <= 8'd130;
		snakeLocY[8:0] <= 9'd100;
		snakeLocY[17:9] <= 9'd100;
		snakeLocY[26:18] <= 9'd100;
		snakeLocY[35:27] <= 9'd100;

		// body collision with segment 1 of snake body
		#(8*HALF_CLOCK_PERIOD);
		snakeLocX[7:0] <= 8'd110;
		snakeLocY[8:0] <= 9'd100;
		

		
		
		
		
		
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