/*
 * Apple Generated Inside Snake Checking Module
 * ----------------------------
 * By: Krishna Pavani
 * For: University of Leeds
 * Date: 25th April 2024
 *
 * Description
 * ------------
 * This module checks whether the apple is generated inside the snake body and gives a output 1
 */
module Apple_Gen_InsideBody #(
	parameter SegWidth = 10,
	parameter SegHeight = 10,
	parameter BorderThickness = 10,
	parameter AppleWidth = 10,
	parameter AppleHeight = 10,
	parameter DisplayWidth = 240,
	parameter DisplayHeight = 320
)
(
    // Inputs 
    input reset,
    input clock,
    input [1023:0] snakeLocX, //Array of snake X coordinates
    input [1152:0] snakeLocY, //Array of snake Y coordinates
    input [7:0]size,
	 input screenClock,
    input [7:0] appleLocX, //Generated apple X coordinates
    input [8:0] appleLocY, //Generated apple Y coordinates
	 
	 // Outputs
	 output reg appleFoundInsideBody
);

integer i,j,k,snakeLoopVar;
reg [7:0] snakeLocXArray [0:127];
reg [8:0] snakeLocYArray [0:127];

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

	if (reset) begin
		appleFoundInsideBody = 1'b0;
	end 
	else begin
	   appleFoundInsideBody = 1'b0;
		
         // Checks if the snake head has collided with any of its body segments
			for (snakeLoopVar = 0; snakeLoopVar<127 ; snakeLoopVar= snakeLoopVar+1) begin
				if (snakeLoopVar < size) begin
				
					if ( ((appleLocX >= snakeLocXArray[snakeLoopVar]) && (appleLocX < (snakeLocXArray[snakeLoopVar] + SegWidth)) ) || ( ((appleLocX + AppleWidth-1) >= snakeLocXArray[snakeLoopVar]) && ((appleLocX + AppleWidth-1) < (snakeLocXArray[snakeLoopVar] + SegWidth))) ) begin				
						if ( ((appleLocY >= snakeLocYArray[snakeLoopVar]) && (appleLocY < (snakeLocYArray[snakeLoopVar] + SegHeight)) ) || ( ((appleLocY + AppleHeight-1) >= snakeLocYArray[snakeLoopVar]) && ((appleLocY + AppleHeight-1) < (snakeLocYArray[snakeLoopVar] + SegHeight))) ) begin
						   
							appleFoundInsideBody = 1'b1;
						
						end
					end
					
				end	
			end
	end
end
endmodule



