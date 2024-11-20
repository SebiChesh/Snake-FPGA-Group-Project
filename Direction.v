/*
 * Direction Module
 * ----------------------------
 * By: Sebastian Cheshire
 * For: University of Leeds
 * Date: 4th April 2024
 *
 * Description
 * ------------
 * This module maps the user input from pressing KEY0-3 on the DE1Soc board to directions the snake will travel in
 * 
 * Inputs:
 * 		keys: 4 bit binary number from the KEYs on the DE1SOC board
 * 		reset: 1 bit number to reset module (HIGH = module reset)
 *		clock: 1 bit number for clock input
 *
 * Output:
 * 		direction: 4 bit binary number used to store the direction of travel
 *			Example: no movement = 1111
 * 					 down = 0001
 *					 up = 0010
 *					 right = 0100
 *					 left = 1000
 */

 module Direction (
 
	input [3:0] keysHW, // input from KEY0-3
	input reset, // reset to reset direction
	input clock, // clock
	output reg [3:0] direction // direction the snake should travel in based on input from keys
	
 );
 
	reg [3:0] state; // reg where state is stored
	wire [3:0] keys = ~keysHW; // inverts input keys as hardware keys when not pressed are set
							   // high and other module logic assumes low hence inverted for code conformity

	//local parameter declaration for states movements up down left right and no movement 
	localparam NO_MOVEMENT = 4'b1111;
	localparam DOWN = 4'b0001;
	localparam UP = 4'b0010;
	localparam RIGHT = 4'b0100;
	localparam LEFT = 4'b1000;
	

	//Define the outputs of the moore state machine direction module which are dependent on the current state
	always @(*) begin
		
		case (state)
		
			NO_MOVEMENT: begin // defines output for state NO_MOVEMENT
	
				direction = NO_MOVEMENT;
					
			end			
			DOWN: begin // defines output for state DOWN
			
				direction = DOWN;
				
			end			
			UP: begin // defines output for state UP
			
				direction = UP;
			end
			RIGHT: begin // defines output for state RIGHT
			
				direction = RIGHT;

			end
			LEFT: begin // defines output for state LEFT 
			
				direction = LEFT;
				
			end
			default: begin
				
				direction = LEFT;
				
			end
		endcase
	end
				
				
	// State transition logic
	always @(posedge clock or posedge reset) begin
	
		if (reset) begin
		
			// if game is reset then snake movement set to NO_MOVMENT state
			state <= NO_MOVEMENT;
		
		// checks that only a single key is pressed and only updates state if only single key
		// pressed if the user lets go of keys it ensures direction of travel stays the same

		end else if ((keys == DOWN) || (keys == UP) || (keys == RIGHT) || (keys == LEFT)) begin 
					
			case (state)
			
				NO_MOVEMENT: begin // Define NO_MOVEMENT behaviour
				
					state <= keys;
					
				end
				DOWN: begin // Defines DOWN behaviour
				
					if (keys != UP) begin // stops user crashing into itself by going in opposite direction its currently travelling in
					
						state <= keys;
						
					end					
				end
				UP: begin // Defines UP behaviour
				
					if (keys != DOWN) begin // stops user crashing into itself by going in opposite direction its currently travelling in
					
						state <= keys;
							
					end					
				end
				RIGHT: begin // Defines RIGHT behaviour
				
					if (keys != LEFT) begin // stops user crashing into itself by going in opposite direction its currently travelling in
					
						state <= keys;
						
					end				
				end
				LEFT: begin // Defines LEFT behaviour
					
					if (keys != RIGHT) begin // stops user crashing into itself by going in opposite direction its currently travelling in
					
						state <= keys;
						
					end						
				end
				
				default: begin
				
					state <= LEFT;

				end
			endcase
		end
	end

endmodule
				
				
					
					
					
					
			
			
				
 

 
