/*=========================================================
 * Hex to 7-segment convertor Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat as part of Unit 1 lab task. The 
 * same code is utilized for the snake game and used on the
 * Scoreboard module. No modifications to the original code
 * other than formatting and commenting to improve readability.
 *
 *=========================================================
 *Description
 *------------------------------------------------------------
 * This module takes a 4-bit binary number as input and 
 * converts it into a seven segment display format as a 7-bit
 * output.
 *
 * Parameters:
 * INVERT_OUTPUT: Value is 1 if output needs to be inverted
 * 				  and 0 otherwise.
 *
 * Inputs:
 * -> HexVal: Hex input (4-bit binary)
 * 
 * Outputs:
 * -> SevenSeg: 7-bit output to display on the board 
 *-------------------------------------------------------------
*/

//--------------------------------------------------------------
// Module Declaration 
//--------------------------------------------------------------
module HexTo7Segment #(
	
	//...............................
	// Parameter declaration
	//...............................
	parameter INVERT_OUTPUT = 0
) (
	//................................
	//Declare input and output	
	//................................
	input [3:0] HexVal,
	output reg [6:0] SevenSeg
	
);

//--------------------------------------------------
//Create a look up table to assign correct output
//--------------------------------------------------
always @ * begin

	//..............................................
	// case (expression)
	//..............................................
	case (HexVal) 								

		4'h0: SevenSeg = 7'b0111111; 			//assign value of 0

		4'h1: SevenSeg = 7'b0000110; 			//assign value of 1
		
		4'h2: SevenSeg = 7'b1011011; 			//assign value of 2
		
		4'h3: SevenSeg = 7'b1001111; 			//assign value of 3
		
		4'h4: SevenSeg = 7'b1100110; 			//assign value of 4
		
		4'h5: SevenSeg = 7'b1101101; 			//assign value of 5
		
		4'h6: SevenSeg = 7'b1111101; 			//assign value of 6
		
		4'h7: SevenSeg = 7'b0000111; 			//assign value of 7
		
		4'h8: SevenSeg = 7'b1111111; 			//assign value of 8
		
		4'h9: SevenSeg = 7'b1101111; 			//assign value of 9
		
		4'hA: SevenSeg = 7'b1110111; 			//assign value of A
		
		4'hB: SevenSeg = 7'b1111100; 			//assign value of B
		
		4'hC: SevenSeg = 7'b0111001; 			//assign value of C
		
		4'hD: SevenSeg = 7'b1011110; 			//assign value of D
		
		4'hE: SevenSeg = 7'b1111001; 			//assign value of E
		
		4'hF: SevenSeg = 7'b1110001; 			//assign value of F
		
		default: SevenSeg = 7'b0000000;			//assign default value of 0
	
	endcase
	
	//------------------------------------------
	// Apply a bitwise not operator if the value
	// of INVERT_OUTPUT is 1.
	//------------------------------------------
	if (INVERT_OUTPUT) begin
		SevenSeg = ~SevenSeg;
	end

end

endmodule