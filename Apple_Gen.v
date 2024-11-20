/*
 * Apple Generator Module
 * ----------------------------
 * By: Krishna Pavani
 * For: University of Leeds
 * Date: 9th April 2024
 *
 * Description
 * ------------
 * Generates apple in the start at a default location, generates it a random place
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
 * 
 Credits
 -------
 Snake unpacking logic provided by Sebastian Cheshire

 */
module Apple_Gen #(
	parameter SegWidth = 10,
	parameter SegHeight = 10,
	parameter BorderThickness = 10,
	parameter AppleWidth = 10,
	parameter AppleHeight = 10,
	parameter DisplayWidth = 240,
	parameter DisplayHeight = 320
)
(
    // Inputs for apple generator
    input appleEaten,
    input reset,
    input clock,
    input [1023:0] snakeLocX, // snake X coordinates array
    input [1152:0] snakeLocY, // snake Y coordinates array
    input [7:0]size,
	 input screenClock,

    // Outputs for apple generator
    output reg [7:0] appleLocX,
    output reg [8:0] appleLocY
);

reg [7:0]randomX;
reg [8:0]randomY;
reg [7:0] newAppleLocX;
reg [8:0] newAppleLocY;
reg insideSnakeBody;
integer i,j,k,l,snakeLoopVar;
reg [7:0] snakeLocXArray [0:127];
reg [8:0] snakeLocYArray [0:127];



always @(posedge clock or posedge reset) begin

	 if (reset) begin
			// setting some initial coordinates
			randomX<=100;
			randomY<=160;
	 end else begin


	//Basic incremental counter logic based on clock cycle
		if (randomX>(240-(BorderThickness + AppleWidth))) begin
			randomX<=BorderThickness;
		end else if (randomX<BorderThickness) begin
			randomX<=100;
		end else begin
			randomX<=randomX+10;
		end
		if (randomY>(320 -(BorderThickness + AppleHeight))) begin
			randomY<=BorderThickness;
		end else if (randomY<BorderThickness) begin
			randomY<=160;
		end else begin
			randomY<=randomY+10;
		end

	 end

end



// Builds the snakeLocX and Y Arrays from their unpacked serialised form stored in snakeLocX and snakeLocY if reset high then arrays are reset and filled with 0
always @(posedge screenClock or posedge reset) begin

		if (reset) begin

			snakeLocXArray[0] = 8'd50;
			snakeLocYArray[0] = 9'd50;


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


always @(posedge clock or posedge reset) begin
	// At the beginning of the game or after reset, set the initial position of the apple
	if (reset) begin
		appleLocX <= 100;
		appleLocY <= 200;
		insideSnakeBody = 0;
   end 
	else begin
		if (appleEaten) begin
		   // assign random values to apple ccordinates
			appleLocX <= randomX;
		   appleLocY <= randomY;
			

			 // Checks if the snake head has collided with any of its body segments
			for (snakeLoopVar = 0; snakeLoopVar<127 ; snakeLoopVar= snakeLoopVar+1) begin
				if (snakeLoopVar < size) begin
				
					if ( ((appleLocX >= snakeLocXArray[snakeLoopVar]) && (appleLocX < (snakeLocXArray[snakeLoopVar] + SegWidth)) ) || ( ((appleLocX + AppleWidth-1) >= snakeLocXArray[snakeLoopVar]) && ((appleLocX + AppleWidth-1) < (snakeLocXArray[snakeLoopVar] + SegWidth))) ) begin				
						if ( ((appleLocY >= snakeLocYArray[snakeLoopVar]) && (appleLocY < (snakeLocYArray[snakeLoopVar] + SegHeight)) ) || ( ((appleLocY + AppleHeight-1) >= snakeLocYArray[snakeLoopVar]) && ((appleLocY + AppleHeight-1) < (snakeLocYArray[snakeLoopVar] + SegHeight))) ) begin
						   appleLocX <= 150;
				         appleLocY <= 150;
						
						end
					end
					
				end	
			end
		
			
		end

	end




end

endmodule