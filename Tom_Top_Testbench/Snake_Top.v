/*
 *--------|Snake Top Level Module|-----------
 *Created by- 
 *Shibin Hamza Achambat, 09 April 2024
 *
 *____Description______
 *This module takes buttons, one toggle switch, clock as inputs 
 *and generates required output for the hex and LCD display
 *
*/

module Snake_Top (
	
	//inputs
	input [3:0] keys,
	input resetHW,
	input clock,
	
	//Output LED for testing
	output directionUp,
	output directionDown,
	output directionLeft,
	output directionRight,
	output collisionHigh,
	output resetHigh,
	output appleEatenHigh,
	output screenClockHigh,
	
	//main outputs
	output [6:0] seg0,
	output [6:0] seg1,
	output [6:0] seg2,
	output LT24Wr_n,
	output LT24Rd_n,
	output LT24CS_n,
	output LT24RS,
	output LT24Reset_n,
	output [15:0] LT24Data,
	output LT24LCDOn
	
);

integer i,j;
reg [24:0] screenClockWidth;

wire screenClock; //Screen refresh cycle for updation of the snake body
reg regScreenClock;  //Clock register for screen refresh
wire reset, collision, appleEaten; //Reset, collision, appleEaten value that will be considered in other modules
wire [3:0] direction;

wire [1023:0] snakeLocX;
wire [1151:0] snakeLocY;
wire [7:0] size;

//registers required for apple generation
wire [7:0] appleLocX;
wire [8:0] appleLocY;

assign screenClock = regScreenClock;

//reset bit generator module
ResetSwitch ResetSwitch0 (
		
		.resetHW ( resetHW),
		.collision ( collision),
		.clock ( clock),
		.reset ( reset)

);

//register to generate screenClock
always @ (posedge clock or posedge reset) begin
	if (reset) begin
		screenClockWidth=1;
		regScreenClock=1'b0;
	end else begin
		screenClockWidth = screenClockWidth+1;

		if (screenClockWidth >= 12500000) begin
			regScreenClock=~regScreenClock;
			screenClockWidth=1;
		end	
	end
end

//Instantiate the direction module
Direction Dir0 (
	
	.keysHW ( keys),
	.clock ( clock),
	.reset (reset),
	.direction (direction)
);


//Instantiate Apple generator module
Apple_Gen AppleGen0 (

	.appleEaten ( appleEaten),
	.reset ( reset),
	.clock ( clock),
	.snakeLocX ( snakeLocX),
	.snakeLocY ( snakeLocX),
	.size ( size),
	.appleLocX ( appleLocX),
	.appleLocY ( appleLocY)

);

//Instantiate collision detector module
Collision_Detector # (
	
	.SegWidth (10),
	.SegHeight (10),
	.BorderThickness (10),
	.DisplayWidth (240),
	.DisplayHeight (320),
	.AppleWidth (10),
	.AppleHeight (10)
	
) CollDet0 (
	
	.snakeLocX ( snakeLocX),
	.snakeLocY ( snakeLocY),
	.size ( size),
	.appleLocX ( appleLocX),
	.appleLocY ( appleLocY),
	.clock ( clock),
	.screenClock( screenClock ),
	.reset ( reset),
	.appleEaten ( appleEaten),
	.collision ( collision)
);

//Instantiate Snake Module
Snake # (
	
	.SegWidth (10)
	
) Snake0 (
	
	.clock ( clock),
	.reset ( reset),
	.screenClock (screenClock),
	.appleEaten ( appleEaten),
	.direction ( direction),
	
	.snakeLocX ( snakeLocX),
	.snakeLocY ( snakeLocY),
	.size ( size)
	
);


//Instantiate Scoreboard module
Scoreboard ScrBrd0 (

	.screenClock ( screenClock),
	.size ( size),
	.reset ( reset),
	
	.seg0 ( seg0),
	.seg1 ( seg1),
	.seg2 ( seg2)
	
);

//Instantiate the screenwriter module
ScreenWriter Write0 (
	
	//inputs
	.clock ( clock),
	.reset ( reset),
	.appleX ( appleLocX),
	.appleY ( appleLocY),
	.snakeX ( snakeLocX),
	.snakeY ( snakeLocY),
	
	//outputs
	.LT24Wr_n ( LT24Wr_n),
	.LT24Rd_n ( LT24Rd_n),
	.LT24CS_n ( LT24CS_n),
	.LT24RS ( LT24RS),
	.LT24Reset_n ( LT24Reset_n),
	.LT24Data ( LT24Data),
	.LT24LCDOn ( LT24LCDOn)
	
);

//Test Ouputs
assign directionDown = direction [0];
assign directionUp = direction [1];
assign directionRight = direction [2];
assign directionLeft = direction [3];
assign collisionHigh = collision;
assign appleEatenHigh = appleEaten;
assign resetHigh = reset;
assign screenClockHigh = screenClock;


endmodule