
/*
 * Game Over FSM Module
 * ----------------------------
 * By: Krishna Pavani
 * For: University of Leeds
 * Date: 28th April 2024
 *
 * Description
 * ------------
 * Determine if the game is over and switches to reset state
 
 * Inputs
 * ------
 * collision
 * reset
 * clock
 *
 * Outputs
 * -------
 * gameOver
 *
 */
 
module GameOver (
	input collision,
	input reset,
	input clock,
	
	output reg gameOver

);

reg [1:0] state;
reg [1:0] nextState;

//defining states

localparam RESET_STATE = 2'b00;
localparam GAME_STATE = 2'b01;
localparam GAME_OVER = 2'b10;

// outputs for each state
always @(state) begin
	
	case(state)
		RESET_STATE: begin
			gameOver = 1'b0; // define reset output
		end
		GAME_STATE: begin
			gameOver = 1'b0; // define game state output
		end
		GAME_OVER: begin
		
			gameOver = 1'b1; // define game over output
		end
		default : begin
			gameOver = 1'b0;
		end
	endcase
end

//Defining state transitions

always @(posedge clock or posedge reset) begin
	// Clock or reset event triggers this block
	
	if (reset) begin
		// If reset signal is asserted
		nextState <= RESET_STATE; // Transition to the reset state
	end
	else begin
		// If reset signal is not asserted
		
		case (state)
			// State-dependent behavior
			
			// Reset State behavior
			RESET_STATE: begin
				if (reset) begin
					// If reset signal is still asserted
					nextState <= RESET_STATE; // Stay in the reset state
				end
				else if (!reset) begin
					// If reset signal is not asserted anymore
					nextState <= GAME_STATE; // Transition to the game state
				end
			end
			
			// Game State behavior
			GAME_STATE: begin
				if (collision) begin
					// If collision occurs
					nextState <= GAME_OVER; // Transition to game over state
				end
				else if (!collision || !reset) begin
					// If no collision or reset signal is asserted
					nextState <= GAME_STATE; // Stay in the game state
				end
				else if (reset) begin
					// If reset signal is asserted
					nextState <= RESET_STATE; // Transition to the reset state
				end
			end
			
			// Game Over State behavior
			GAME_OVER: begin
				if (reset) begin
					// If reset signal is asserted
					nextState <= RESET_STATE; // Transition to the reset state
				end
				else if (!reset) begin
					// If reset signal is not asserted
					nextState <= GAME_OVER; // Stay in the game over state
				end
			end
			default : begin
				nextState <= RESET_STATE;
				end
		endcase
	end
	state <= nextState;
end

endmodule
