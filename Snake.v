/*=========================================================
 * Snake Generator Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 31 March 2024
 *
 *=========================================================
 * Description
 *------------------------------------------------------------
 * This module takes clock, reset, Screen refresh rate, and
 * snake direction as inputs and generates the xy coordinates
 * of the snake as the output.
 * 
 * Parameters:
 * -> SegWidth: Width of a segment
 * -> SegHeight: Height of a segment
 *
 * Inputs: 
 * -> clock: main clock signal from the board
 * -> reset: reset bit from reset module
 * -> appleEaten: apple eaten detection signal 
 * -> screenClock: Screen refresh cycle
 * 
 * Outputs:
 * -> [1023:0] snakeLocx: Unpacked version of snake x-coorinates
 * -> [1151:0] snakeLocY: Unpacked version of snake y-coordinates
 * -> [7:0] size: size of the snake in terms of num of segments
 *--------------------------------------------------------------
*/


//--------------------------------------------------------------
// Module Declaration with two parameters, one for segment width
// and another for segment height of the snake
//--------------------------------------------------------------
module Snake #(

	parameter SegWidth = 10,
	parameter SegHeight = 10

) (

	//...........................................................
	// Define inputs to the module
	//...........................................................

	input clock,
	input reset,
	input screenClock,
	input appleEaten,
	input [3:0] direction,

	//...........................................................
	// Define outputs to the module
	//...........................................................
	output reg [1023:0] snakeLocX,   	//horizontal direction is greater than 2^9
	output reg [1151:0] snakeLocY,	 	//Vertical direction is greater than 2^8
	output [7:0] size

);

integer i, j, k;

reg [7:0] snakeLocXArray [0:127];
reg [8:0] snakeLocYArray [0:127];
reg [7:0] sizeReg;

//----------------------------------------------------------------
// Procedural block for Snake Body calculation from the direction 
// input. The Snake body is calculated using 1D arrays of registers
// storing the X and Y coordinates of the snake location. 
// Snake body maximum length is set to 127 and the snake cannot 
// grow beyond that length. As per the current design, the game keeps 
// going with continuous increment in size, but without any further 
// growth in snake length when the length crosses 127. Every time 
// appleEaten signal goes high, the snake size gets incremented by 2.
//----------------------------------------------------------------
always @ (posedge screenClock or posedge reset) begin

	//............................................................
	// On reset, Snake size will be reset to zero and will appear
	// at the coordinate (100,160). The rest of the snake body are 
	// initialized at (0,0) through the for loop.
	//............................................................
	if (reset) begin

		snakeLocXArray[0] = 8'd100;
		snakeLocYArray[0] = 9'd160;

		for (j=1; j<128;j=j+1) begin
			snakeLocXArray[j] = 8'd0;
			snakeLocYArray[j] = 9'd0;
		end

	end else begin
		
		//...........................................................
		// The snake checks if the direction input is non zero and if
		// true, the snake body array values get recalculated for the 
		// segments from index [0] to [size-1]. 
		// For example, snakeLocXArray [2] = snakeLocXArray [1], 
		//				snakeLocXArray [1] = snakeLocXArray [0]
		// and similar operation for Y axis when size is equal to 3. 
		//...........................................................
		if (direction) begin					
			for (i = 127; i>=1 ; i=i-1 ) begin	
															
				if (i<= size-1) begin
					snakeLocXArray[i] = snakeLocXArray[i-1];
					snakeLocYArray[i] = snakeLocYArray[i-1];
				end

			end
		end
		//............................................................
		// Till now, only values for the snake body is calculated and 
		// the coordinate of snake head denoted by snakeLocXArray [0],  
		// snakeLocYArray [0] will be calculated using the below logic
		// by using a case statement based on the direction input.
		//............................................................
		case (direction)                            
			4'b0001: snakeLocYArray [0] = snakeLocYArray [0] + SegHeight;		//move down
			4'b0010: snakeLocYArray [0] = snakeLocYArray [0] - SegHeight;		//move up
			4'b0100: snakeLocXArray [0] = snakeLocXArray[0] + SegWidth;      	//move right
			4'b1000: snakeLocXArray [0] = snakeLocXArray[0] - SegWidth;			//move left

		endcase
	end

	//............................................................
	//Verilog 2001 doesn't allow arrays are the inputs/outputs to 
	// a module and hence, the snakeLocXArray and snakeLocYArray
	// which are arrays of 8 bit, 9 bit registers respectively will 
	// be unpacked serially to wider registers. For X coordinates,
	// a 1024 bit register is used and for Y coordinate, a 1152 bit
	// register is used. In other modules, the unpacked array will
	// then be packed using a similar for loop to use within that
	// module.
	//............................................................
	for (i=0;i<128;i=i+1) begin
		
		for (j=0;j<8;j=j+1) begin

			snakeLocX[i*8+j]=snakeLocXArray[i][j];			// X coordinate unpacking

		end

		for (k=0;k<9;k=k+1) begin

			snakeLocY[i*9+k]=snakeLocYArray[i][k];			// Y coordinate unpacking

		end

	end
	
end

//----------------------------------------------------------------
//The below procedural block calculates the size of the snake based
// on the appleEaten signal. if appleEaten is high, the snake size
// will increment by 1 for every clock cycle and the snake module 
// detects appleEaten high signal for 2 clock posedge of the clock
// incrementing the size by 2 every time an apple is eaten by the 
// snake. Size value is first stored in a register sizeReg and a 
// continuous assignment of the sizeReg to the wire size is done.
//----------------------------------------------------------------
always @(posedge clock or posedge reset) begin

		if (reset) begin

				sizeReg=8'b00000001;

		end else if (appleEaten) begin

			sizeReg=sizeReg+1;

		end

end


assign size = sizeReg;				//Assign size reg value to the output port


endmodule
