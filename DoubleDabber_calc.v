/*=========================================================
 * Module for BCD Conversion
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat for Unit 3 Lab tasks. The module
 * logic has been taken from codes generated as part of the
 * lab activity, with slight modifications.
 *=========================================================
 *Description
 *------------------------------------------------------------
 * This module converts an N-bit input to Binary Coded Decimal
 * format using double dabble algorithm.
 * 
 * Parameters: N (Default value: 5)
 *
 * Inputs:
 * -> a
 * 
 * Outputs:
 * -> [11:0] a
 *-------------------------------------------------------------
*/

//--------------------------------------------------------------
// Module Declaration 
//--------------------------------------------------------------
module DoubleDabber_calc #(
	parameter N = 5

)(
	//...........................................................
	// Inputs and Outputs to the module
	//...........................................................
	input [N-1:0] a,
	output [11:0] digit

);

//Intermediate registers and wires needed for the module functioning
reg [11:0] BCD_num;
wire [11:0] Shifted_BCD [0:N-1];

//----------------------------------------------------------------
// Whenever input changes, BCD num will be initialized to zero
// and then be used in double dabble algorithm
//----------------------------------------------------------------
always @ (a) begin
	BCD_num  = 12'd0;
end

genvar i;								//Generate Variable

//-----------------------------------------------------------------
// Shifter module that performs all the steps involved in a single
// shifting process, will be instantiated here. The current 
// instantiation will do the first shifting operation and output
// from this instantiation will be used as input for the next step. 
//-----------------------------------------------------------------
Shifter # (
	.Bin_add(0),
	.N (N)
) Shift_1 (
	.BCD_num (BCD_num),
	.Bin_num (a [N-1]),
	.Shifted_BCD (Shifted_BCD [0])
);

//-----------------------------------------------------------------
// By using the generate variable, multiple shiting operations are
// performed depending on the input size. The output of from each 
// shifting operation is passed as input to the next. 
//-----------------------------------------------------------------
generate 

	for (i=1;i<N;i=i+1) begin: shifterloop
		
		Shifter # (
			.Bin_add(i),
			.N (N)
		)  Shift_N (
		.BCD_num (Shifted_BCD [i-1]),
		.Bin_num (a [N-i-1]),
		.Shifted_BCD (Shifted_BCD [i])
		);
	end

endgenerate


assign digit = Shifted_BCD [N-1];				// Assign the shifter BCD to the output


endmodule