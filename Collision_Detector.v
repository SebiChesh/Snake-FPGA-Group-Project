/*
 * Direction Module
 * ----------------------------
 * By: Sebastian Cheshire
 * For: University of Leeds
 * Date: 6th April 2024
 *
 * Description
 * ------------
 * The collision detection module determines whether the snake head has
 * had a gameover collision such as with the game boundary walls or its 
 * own body and positive collisions with an apple. It takes as input snakeLocX,
 * snakeLocY, size, appleLocX, appleLocY, clock, screenClock and reset and
 * outputs  1 bit reg’s appleEaten and collision which act as flags for the
 * other modules to inform of the type of collision. 
 *
 * Inputs:
 * 		1024 bit snakeLocX
 * 		1153 bit snakeLocY
 * 		8 bit size
 * 		8 bit appleLocX
 * 		9 bit appleLocY
 * 		1 bit clock, screenClock and reset
 * 
 * Output:
 * 		1 bit appleEaten
 * 		1 bit collision
 */
 
module Collision_Detector #(
	
	// Parameter list
	parameter SegWidth = 10, // Width of snake segment in pixels
	parameter SegHeight = 10, // Height of snake segment in pixels
	parameter BorderThickness = 10, // Thickness of border walls in pixels
	parameter DisplayWidth = 240, // Width of display in pixels
	parameter DisplayHeight = 320, // Height of display in pixels
	parameter AppleWidth = 10, // Width of the apple in pixels
	parameter AppleHeight = 10 // Height of the apple in pixels

)(
	// Port declaration
	input [1023:0] snakeLocX, // serialized form of snake body and head x locations
	input [1152:0] snakeLocY, // serialized form of snake body and head y locations
	input [7:0] size, // number of the snake body segments
	input [7:0] appleLocX, // x location of the apple
	input [8:0] appleLocY, // y location of the apple
	input clock, // 50 MHz clock
	input screenClock, // game refresh clock
	input reset, // game reset flag
	output reg appleEaten, // snake eats apple flag
	output reg collision // snake has had a gameover collision flag
	
);

	integer i, j, k; // loop variables for unpacking the snakeLocX and snakeLocY serialised arrays into arrays
	integer snakeLoopVar; // loop variable for detecting collision betweeen snakehead and body
	
	reg [7:0] snakeLocXArray [0:127]; 
	reg [8:0] snakeLocYArray [0:127];
	reg bodyCollision, wallCollision; // variables that go high if snake head collides with either its body or wall
	

	
	// Synchronously checks if the snake head has collided with an apple and if so it sets appleEaten high asynchronously sets AppleEaten low if reset high
	always @(posedge clock or posedge reset) begin
		
		if (reset) begin
			
			appleEaten <= 1'b0;
			
		end else begin
		
			// Sets appleEaten low if its high
			if (appleEaten) begin
				
				appleEaten <= 1'b0;
			
			end
		
			// Checks if the snake head has collided eith the appple if so it sets appleEaten high
			if ( ((appleLocX >= snakeLocXArray[0]) && (appleLocX < (snakeLocXArray[0] + SegWidth)) ) || ( ((appleLocX + AppleWidth-1) >= snakeLocXArray[0]) && ((appleLocX + AppleWidth-1) < (snakeLocXArray[0] + SegWidth))) ) begin				
				if ( ((appleLocY >= snakeLocYArray[0]) && (appleLocY < (snakeLocYArray[0] + SegHeight)) ) || ( ((appleLocY + AppleHeight-1) >= snakeLocYArray[0]) && ((appleLocY + AppleHeight-1) < (snakeLocYArray[0] + SegHeight))) ) begin
				
					appleEaten <= 1'b1;
				
				end
			end
		end
	end
	
	// Synchronously checks if the snake head has collided with its own body and asynchronously resets bodyCollision to low if reset high
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			
			bodyCollision <=1'b0;
			
		end else begin
			
			// Checks if the snake head has collided with any of its body segments
			for (snakeLoopVar = 1; snakeLoopVar<127 ; snakeLoopVar= snakeLoopVar+1) begin
				if (snakeLoopVar < size) begin
				
			
					if ( ((snakeLocXArray[snakeLoopVar] >= snakeLocXArray[0]) && (snakeLocXArray[snakeLoopVar] < (snakeLocXArray[0]+ SegWidth)) ) || ( ((snakeLocXArray[snakeLoopVar] + SegWidth -1) >= snakeLocXArray[0]) &&  ((snakeLocXArray[snakeLoopVar] + SegWidth -1) < (snakeLocXArray[0] + SegWidth))) ) begin
						if ( ((snakeLocYArray[snakeLoopVar] >= snakeLocYArray[0]) && (snakeLocYArray[snakeLoopVar] < (snakeLocYArray[0]+ SegHeight)) ) || ( ((snakeLocYArray[snakeLoopVar] + SegHeight -1) >= snakeLocYArray[0]) &&  ((snakeLocYArray[snakeLoopVar] + SegHeight -1) < (snakeLocYArray[0] + SegHeight))) ) begin

							bodyCollision <= 1'b1;
						
						end
					end
				end	
			end
		end
	end
	
	// Synchronously checks if the snake head has collided with any of the walls around the screen and asynchronously resets wallCollision to low if reset high
	always @(posedge clock or posedge reset) begin
	
		if (reset) begin
		
			wallCollision <=1'b0;
		
		end else begin
		
			if ( ((snakeLocXArray[0] < BorderThickness) && (snakeLocXArray[0] >= 0)) || ( ((snakeLocXArray[0] + SegWidth -1) < BorderThickness) && ((snakeLocXArray[0] + SegWidth - 1) >= 0) ) || ( (snakeLocXArray[0] < DisplayWidth) && (snakeLocXArray[0] >= (DisplayWidth - BorderThickness)) ) || ( ((snakeLocXArray[0] + SegWidth -1) < DisplayWidth) && ((snakeLocXArray[0] + SegWidth - 1) >= (DisplayWidth - BorderThickness)) ) ) begin
			
				wallCollision <=1'b1;
			
			end else if ( ((snakeLocYArray[0] < BorderThickness) && (snakeLocYArray[0] >= 0)) || ( ((snakeLocYArray[0] + SegHeight -1) < BorderThickness) && ((snakeLocYArray[0] + SegHeight - 1) >= 0) ) || ( (snakeLocYArray[0] < DisplayHeight) && (snakeLocYArray[0] >= (DisplayHeight - BorderThickness)) ) || ( ((snakeLocYArray[0] + SegHeight -1) < DisplayHeight) && ((snakeLocYArray[0] + SegHeight - 1) >= (DisplayHeight - BorderThickness)) ) ) begin
			
				wallCollision <=1'b1;
			
			end
		
		end
	
	end
	
	
	// Builds the snakeLocX and Y Arrays from their unpacked serialised form stored in snakeLocX and snakeLocY if reset high then arrays are reset and filled with 0 apart from index 0 which is the head which is set to coordinates (50,50)
	always @(posedge screenClock or posedge reset) begin
	
		if (reset) begin
		
			snakeLocXArray[0] = 8'd100;
			snakeLocYArray[0] = 9'd160;
			
			
			for (i=1;i<128;i=i+1) begin
				
				// Builds the snakeLocXArray from snakeLocX
				for (j=0;j<8;j=j+1) begin
					
					snakeLocXArray[i][j] = 1'b0;
						
				end
				
				// Builds the snakeLocYarray from snakeLocY
				for (k=0;k<9;k=k+1) begin
					
					snakeLocYArray[i][k]= 1'b0;
						
				end
			end
			
		end else begin
			
			for (i=0;i<128;i=i+1) begin
				
				// Builds the snakeLocXArray from snakeLocX
				for (j=0;j<8;j=j+1) begin
					
					snakeLocXArray[i][j] = snakeLocX[i*8+j];
						
				end
				
				// Builds the snakeLocYarray from snakeLocY
				for (k=0;k<9;k=k+1) begin
					
					snakeLocYArray[i][k]= snakeLocY[i*9+k];

				end
			end
		end
	end
	
	// sets collision high if either wallCollision or bodyCollision is high. resets collision to 0 if reset high
	always @(posedge clock or posedge reset) begin

		if (reset) begin
		
			collision <= 1'b0;
		
		end else begin
		
			if ( wallCollision || bodyCollision) begin
			
				collision <= 1'b1;
			
			end
			
		end

	end
	
endmodule


	
	
	
 