/*=========================================================
 * Test bench for Snake Top Level Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 16 April 2024
 *
 *=========================================================
 *Description
 *--------------------------------------------------------------
 * This module simulations and tests the functioning of the top level module
 * The module checks generation of all the output signals 
 * and updation of the slower clocks with respect to different 
 * inputs of level. Since all the submodules are exhaustively
 * checked for functionality, basic tests are done in this
 * module by using a synchronous test bench logic inspired
 * from the unit 2/3 lab tasks	
 *--------------------------------------------------------------
*/

//------------------------------------------------------
// Timescale derivative
//------------------------------------------------------
`timescale 1 ns/ 100 ps
//------------------------------------------------------
// Module Declaration
//------------------------------------------------------
module Snake_Top_tb;				

//------------------------------------------------------
//Declaration of inputs
//------------------------------------------------------
	reg [3:0] keys;
	reg resetHW;
	reg clock;
	reg level1Switch;
	reg level2Switch;
	reg level3Switch;
	reg debugMode;
	
	
	//------------------------------------------------------
	//Declare test LED outputs
	//------------------------------------------------------
	wire directionUp;
	wire directionDown;
	wire directionLeft;
	wire directionRight;
	wire collisionHigh;
	wire resetHigh;
	wire appleEatenHigh;
	wire screenClockHigh;
	

	//------------------------------------------------------
	//Declare main outputs of the module
	//------------------------------------------------------
	wire [6:0] seg0;
	wire [6:0] seg1;
	wire [6:0] seg2;
	wire [6:0] seg3;
	wire [6:0] seg4;
	wire [6:0] seg5;
	wire LT24Wr_n;
	wire LT24Rd_n;
	wire LT24CS_n;
	wire LT24RS;
	wire LT24Reset_n;
	wire [15:0] LT24Data;
	wire LT24LCDOn;
	

//------------------------------------------------------
//Instantiate dut
//------------------------------------------------------	
Snake_Top Snake_Top_dut (

	//..................................................
	// Module inputs
	//..................................................
	.keys ( keys),										
	.resetHW ( resetHW),
	.clock ( clock),
	.level1Switch ( level1Switch),
	.level2Switch ( level2Switch),
	.level3Switch ( level3Switch),

	//..................................................
	// Module outputs
	//..................................................	
	.directionUp ( directionUp),
	.directionDown ( directionDown),
	.directionLeft ( directionLeft),
	.directionRight ( directionRight),
	.seg0 ( seg0),
	.seg1 ( seg1),
	.seg2 (seg2),
	.seg3 ( seg3),
	.seg4 ( seg4),
	.seg5 ( seg5),
	.LT24Wr_n ( LT24Wr_n),
	.LT24Rd_n ( LT24Rd_n),
	.LT24CS_n (LT24CS_n),
	.LT24RS ( LT24RS),
	.LT24Reset_n (LT24Reset_n),
	.LT24Data (LT24Data),
	.LT24LCDOn (LT24LCDOn)

);



localparam ClockFrequency = 50000000; 			//Clock frequency

//------------------------------------------------------------
// Test bench logic for hard reset signal. Synchronous logic
// similar to the one used in Unit 2, 3 lab resources has been
// adopted here
//------------------------------------------------------------
initial begin

	$display("Simulation started at %d ns",$time);			// Simulation start indication

	resetHW = 1'b1;											// Reset switch signal set to zero
	
	repeat(10000) @ (posedge clock);							// Wait for 10000 clock cycles		

	resetHW = ~resetHW;										// Set reset to zero

end

//-------------------------------------------------------------
// Procedural block to initialize all inputs including clock
//-------------------------------------------------------------
initial begin
	
	clock=0;													// Clock signal

	keys = 4'b1111;												// Button keys to initial default value

	level1Switch = 0;	level2Switch = 0;	level3Switch = 0;	// Level Switch values

	debugMode = 0;												// Debug switch value

end

//------------------------------------------------------------
// Logic for calculating the clock frequency has been taken 
// from the Unit 2/3 SYnchronous test bench examples from lab
// resources. In this case, the total clock period is 20ns and
// hence the half of the period denoted by HalfPeriod parameter
// has been set to 10ns.
//------------------------------------------------------------
real HalfPeriod = (1000000000.0/$itor(ClockFrequency))/2.0;

integer numCycles = 0;					//Variable denoting number of full clock cycles

//-------------------------------------------------------------
// Procedural block for the synchronous logic
//-------------------------------------------------------------
always begin

	//........................................................
	// Clock signal will be inverted at 10ns or one HalfPeriod
	// The operation will be done twice to have a full clock 
	// cycle.
	//........................................................
	#(HalfPeriod); clock = ~clock;			
	#(HalfPeriod); clock = ~clock;

	numCycles = numCycles + 1;				//Number of full clock cycles


	//..........................................
	// Direction input changed at 100th cycle
	//..........................................
	if (numCycles == 100) begin
		keys = 4'b1110;
	end

	//.......................................................
	// Direction input changed again at 50x10^6 clock cycles
	//.......................................................
	if (numCycles == ClockFrequency) begin

		keys = 4'b1101;

	end

	//......................................................
	//Display all critical values at every 6250000 cycles
	//......................................................
	if (numCycles % 6250000 == 0) begin

		$display("%d ns Keys=%b clock=%b reset=%b level=%d  number= (%b %b %b %b %b %b)", $time, 
					keys, clock, resetHW, {level1Switch,level2Switch,level1Switch}, seg5, seg4, seg3, seg2, seg1, seg0);

	end
	
	//........................................................
	// Change to level 1 at 6250000th cycle
	//........................................................
	if (numCycles == 6250000) begin

		level1Switch = 1'b1;

	end

	//........................................................
	// Change to level 7 at 25x10^6 th cycle
	//........................................................
	if (numCycles == ClockFrequency/2) begin

		level2Switch = 1'b1;
		level3Switch = 1'b1;

	end

	//........................................................
	// Set to stop the simulation at 200x10^6 cycles
	// Reset numCycles to zero
	//........................................................
	if (numCycles >= 4* ClockFrequency) begin

		numCycles = 0;
		$stop;

	end


end

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//OLD LOGIC FOR TEST BENCH
//-----------------------------------------------------------------------------------------------------------------------------
/*

//integer i, j;

initial begin
	$display("Simulation started at %d ns",$time);

	//Initial value
	clock=0;
	keys = 4'b1111;
	resetHW = 1'b1;
	level1Switch = 0;	level2Switch = 0;	level3Switch = 0;
	debugMode = 0;

	#50; resetHW=~resetHW; clock=~clock; #50; resetHW=~resetHW; clock=~clock;
	#50; resetHW=~resetHW; clock=~clock; 
	#10; clock=~clock; keys = 4'b1110;
	
	for (i=0;i<=500000000; i=i+1) begin

		#10; clock=~clock; 
		if (i==1000) begin
			resetHW=~resetHW;  
		end
		if (i==1500) begin
			resetHW=~resetHW;  
		end

		if (i%250000==0) begin

			$display("%d th cycle Keys=%b clock=%b reset=%b level=%d  number= (%b %b %b %b %b %b)", i/2, 
					keys, clock, resetHW, {level1Switch,level2Switch,level1Switch}, seg5, seg4, seg3, seg2, seg1, seg0);

		end
	end

	$display("Simulation has ended at %d ns",$time);

end
*/

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

endmodule
