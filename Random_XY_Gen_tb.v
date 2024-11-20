`timescale 1 ns/100 ps

module Random_XY_Gen_tb;

    // Inputs
    reg clock;
    reg reset;

    // Outputs
    wire [7:0] randomX;
    wire [8:0] randomY;

    // Instantiate the module under test
    Random_XY_Gen dut (
        .clock(clock),
        .reset(reset),
        .randomX(randomX),
        .randomY(randomY)
    );

    // Clock generation
   integer i;

	initial begin

	$display("%d ns\tSimulation Started",$time);
	$monitor("%d %d random x  and y values: ", randomX, randomY);
	
	clock = 1'b0;
	
	for(i =0; i<=20; i=i+1) begin
		#10
		clock = ~clock;
	end
	
end

endmodule
