/*
 * Apple Generator Module Test Bench
 * ----------------------------
 * By: Krishna Pavani
 * For: University of Leeds
 * Date: 28th April 2024
 *
 * Description
 * ------------
 * Test Bench to check apple in the start at a default location, generates it a random place
 * if apple eaten is high
 * 
 * Inputs
 * ------
 * reset
 * clock
 * snakeLocX:1023 bit unpacked array
 * snakeLocY:1152 bit unpacked array
 * size
 * screenClock
 *
 * Outputs
 * -------
 * appleLocX
 * appleLocY

 */
 
`timescale 1 ns/100 ps

module Apple_Gen_tb;

   // Parameters
    parameter BorderThickness = 10;
    parameter AppleWidth = 10;
    parameter AppleHeight = 10;
    parameter Shift = 20;

    // Inputs
    reg appleEaten;
    reg reset;
    reg clock;
    reg [1023:0] snakeLocX;
    reg [1152:0] snakeLocY;
    reg [7:0] size;
	 reg screenClock;
    // Outputs
    wire [7:0] appleLocX;
    wire [8:0] appleLocY;

    // Instantiate the Apple_Gen module
    Apple_Gen apple_gen (
        .appleEaten(appleEaten),
        .reset(reset),
        .clock(clock),
		  .screenClock(screenClock),
        .snakeLocX(snakeLocX),
        .snakeLocY(snakeLocY),
        .size(size),
        .appleLocX(appleLocX),
        .appleLocY(appleLocY)
    );
	 integer i;

    // Initial stimulus
    initial begin
		  
		  $display("%d ns\tSimulation Started",$time);
		  $monitor("apple loc x  and y values: %d %d ", appleLocX, appleLocY);
        // Initialize inputs
        appleEaten = 1'b0;
        reset = 1'b1;
     
        size = 8; // Example size
        // Apply reset
        #10 reset = 1'b0;

        clock = 1'b0;
	
		  for(i =0; i<=1000; i=i+1) begin
				#10
				clock = ~clock;
				appleEaten = ~appleEaten;
		  end
		  
		  
				  
		  
		  
		  
		  
		  
		  
		  

        
      
    end

endmodule