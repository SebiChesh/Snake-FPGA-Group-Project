/*
 * Random Generator Module
 * ----------------------------
 * By: Krishna Pavani
 * For: University of Leeds
 * Date: 9th April 2024
 *
 * Description
 * ------------
 *Generates random X and Y coordinates
 */
 
 module Random_XY_Gen (
	input clock,
	input reset,
	
	output reg [7:0]randomX,
	output reg [8:0]randomY
);

reg [31:0] seed = 32'hACE1; // Initial seed value



always @(posedge clock or posedge reset) begin

	 if (reset) begin
    seed <= 32'hACE1; // Reset seed value
	 end
	 
    // Use LFSR or other PRNG algorithm to generate pseudo-random values
    // Example: Linear Feedback Shift Register (LFSR)
    seed <= seed ^ ((seed << 5) | (seed >> 11)); // LFSR operation for randomness

    // Limit range and assign to rand_X and rand_Y

    

    randomX <= seed[7:0] % 240; // change VGA display width
    randomY <= seed[8:0] % 320; // change VGA display height
end



endmodule