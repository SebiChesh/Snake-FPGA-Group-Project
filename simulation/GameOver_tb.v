
/*
 * Game Over FSM Module test bench
 * ----------------------------
 * By: Krishna Pavani
 * For: University of Leeds
 * Date: 20th April 2024
 *
 * Description
 * ------------
 * Test bench to determine if the game is over and switches to reset state
 */
 module GameOver_tb;

    // Parameters
    localparam CLOCK_PERIOD = 10; // Clock period in time units
    
    
    // Signals
    reg clock;
    reg reset;
    reg collision;
    wire gameOver;
    
    // Instantiate the module
    GameOver UUT (
        .collision(collision),
        .reset(reset),
        .clock(clock),
        .gameOver(gameOver)
    );
    
    // Clock generation
    always #((CLOCK_PERIOD/2)) clock = ~clock;
    
    // Initial values
    initial begin
        clock = 0;
        reset = 1'b1;
		  collision = 1'b0;
		  #10;
		  reset = 1'b0;
		  #10;
		  

		  $monitor("Output gameOver value: %d ", gameOver);
        
        #10; // Wait a bit
        
        // Test scenario 1: No collision, no reset
        $display("Test scenario 1: No collision, no reset");
        reset = 1'b0;
        collision = 1'b0;
        #10;
		  #100;
        
        // Test scenario 2: Collision occurs
        $display("Test scenario 2: Collision occurs");
        reset = 1'b0;
        collision = 1'b1;
		  #1000;
        
        // Test scenario 3: Reset occurs
        $display("Test scenario 3: Reset occurs");
        reset = 1'b1;
        collision = 1'b0;
        #10;
		  #1000;
		  
		  $display("Test scenario 3: Reset occurs and collision occurs");
        reset = 1'b1;
        collision = 1'b1;
        #10;
        
        
    end
    
endmodule
