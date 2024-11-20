/*=========================================================
 * Shofter Module for Double Dabble algorithm
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat for Unit 3 lab task 6. The same 
 * code is used with minimal modification in the logic.
 * Further code formatting and commenting done to improve
 * readability.
 *
 *=========================================================
 * Description
 *---------------------------------------------------------
 * This module does one cycle of the shifting operation in
 * a double dabble algorithm to convert one N-bit binary 
 * number to BCD format.
 *
 * Parameters:
 * Bin_add: 
 * N: 
 *
 * Inputs:
 * -> [11:0] BCD_num: 12-bit input for single shift operation
 * -> Bin_num: A selected single bit from the N-bit number 
 *             for which BCD conversion is required.
 * 
 * Outputs:
 * -> [11:0] Shifted_BCD: The output display mode
 *
 *----------------------------------------------------------
*/

module Shifter # (

	//.....................................................
	// Parameter declaration.
	//.....................................................
	parameter Bin_add=0,
	parameter N=5
	
) (
	//................................................
	// Declaration of inputs and outputs
	//................................................
	input [11:0] BCD_num,
	input Bin_num,
	output reg [11:0] Shifted_BCD
);

//------------------------------------------------------------------
// Declaration of temporary registers that will be used in the logic
//------------------------------------------------------------------
wire [11:0] temp;
wire [11:0] temp2;

assign temp = {BCD_num [10:0],1'b0};		// Single shift operation
wire cout;									// Wire to store cout from adder

//---------------------------------------------------
// Using NBit adder module, the input single bit binary 
// will be added to the shifted temp wire.
//---------------------------------------------------
AdderNBit # (
	.N (12)
) Bit0 (
	.a (temp),
	.b ({11'd0,Bin_num}),
	.cin (1'b0),
	.sum (temp2),
	.cout(cout)
);

//--------------------------------------------------------
// Procedural block to check if any of the 4-bit blocks 
// of the 12 bit temp2 reaches 5, and if so, the value will
// be added by 3 as per the double dabble algorithm. The
// new value will be stored in the Shifted_BCD register.
//--------------------------------------------------------
always @(*) begin

	Shifted_BCD=temp2;

	//.........................................................
	// Checks if all the numbers from the Nbit input of the 
	// doubledabber_calc module are added to the 12 bit output.
	//.........................................................
	if (Bin_add<N-1) begin

		//.....................................................
		// Checks [3:0] block of temp2
		//.....................................................
		if (temp2[3:0]>=4'd5) begin

			Shifted_BCD[3:0]=temp2[3:0] + 3;

		end

		//.....................................................
		// Checks [7:4] block of temp2
		//.....................................................
		if (temp2[7:4]>=4'd5) begin

			Shifted_BCD[7:4]=temp2[7:4] + 3;

		end

		//.....................................................
		// Checks [11:8] block of temp2
		//.....................................................
		if (temp2[11:8]>=4'd5) begin

			Shifted_BCD[11:8]=temp2[11:8] + 3;

		end

	end

end


endmodule
