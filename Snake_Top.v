/*=========================================================
 * Snake Top Level Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 09 April 2024
 *
 *=========================================================
 * Description
 *---------------------------------------------------------
 * This is the top module of the snake game. 
 * 
 * Inputs:
 * -> 4 Key buttons for changing snake direction of motion
 * -> Sliding Switch 0, 1 and 2 for indicating game level
 * -> Sliding Switch 9 for hard reset 
 * -> Sliding Switch 8 for activating debug display mode
 * -> 50MHz internal clock of the DE1 SoC board
 * 
 * Outputs:
 * -> LEDs display indicating critical signals for debugging
 * -> 7 segment displays from seg0 to seg 5
 * -> LT24 display outputs
 *----------------------------------------------------------
*/

//--------------------------------------------------------------
// Module Declaration 
//--------------------------------------------------------------
module Snake_Top (
	
	//...........................................................
	// Inputs to the module
	//...........................................................
	input [3:0] keys,
	input resetHW,
	input clock,
	input level1Switch,
	input level2Switch,
	input level3Switch,
	input debugMode,
	
	//...........................................................
	// Output LEDs for testing
	//...........................................................
	output directionUp,						// LED1
	output directionDown,					// LED0
	output directionLeft,					// LED3
	output directionRight,					// LED2
	output collisionHigh,					// LED8
	output resetHigh,						// LED9
	output appleEatenHigh,					// LED5
	output screenClockHigh,					// LED7
	
	//...........................................................
	// Main outputs to 7 segment display and LT24 display
	//...........................................................
	output [6:0] seg0,
	output [6:0] seg1,
	output [6:0] seg2,
	output [6:0] seg3,
	output [6:0] seg4,
	output [6:0] seg5,
	output LT24Wr_n,
	output LT24Rd_n,
	output LT24CS_n,
	output LT24RS,
	output LT24Reset_n,
	output [15:0] LT24Data,
	output LT24LCDOn
	
);

//-------------------------------------------------------------------
// Register and wires that will be need for the code will be declared 
// below.
//-------------------------------------------------------------------
wire screenClock; 					//Screen refresh cycle for updation of the snake body
wire reset, collision, appleEaten; 	//Reset, collision, appleEaten bits
wire [3:0] direction;
wire gameOver;

wire [1023:0] snakeLocX;			//Unpacked form of x-coordinate of snake body
wire [1151:0] snakeLocY;			//Unpacked form of y-coordinate of snake body
wire [7:0] size;					//size of the snake in terms of no of segments

wire [7:0] appleLocX;				//x-coordinate of the apple location
wire [8:0] appleLocY;				//y-coordinate of the apple location

//.................................................................
// Level switch inputs from the sliding switch are stored in a 
// 2-bit wire level which will then be used in the clock generator
// module to adjust speed of the snake
//.................................................................
wire [2:0] level = {level1Switch,level2Switch,level3Switch};


//-------------------------------------------------------------------
// Reset bit generator module
// This module generates the reset signal based on the inputs from the
// sliding switch and collision signal. Reset signal will be high for 
// only a limited number of clock cycles based on the input signals.
//-------------------------------------------------------------------
ResetSwitch ResetSwitch0 (
		
		.resetHW ( resetHW),
		.clock ( clock),
		.reset ( reset)

);

//------------------------------------------------------------------
// Instantiate Clock generator module for screenClock
// This module takes the clock signal and the level switch values as 
// inputs and generates a slower clock for updating the snake body.
//------------------------------------------------------------------
Clock_Generator #(
	.speedVal(2)
) Clk1 (
	.clock (clock),
	.reset (reset),
	.level (level),
	.newClock (screenClock)
);

//------------------------------------------------------------------
// Instantiate the direction module
// This module is a Finite State Machine and takes clock and reset 
// signals, button key signals as inputs and outputs the direction of 
// motion of the snake. Snake module will use the direction output 
// generated here.
//------------------------------------------------------------------
Direction Dir0 (
	
	.keysHW ( keys),
	.clock ( clock),
	.reset (reset),
	.direction (direction)
);

//------------------------------------------------------------------
// Instantiate Apple generator module
// Apple generator module takes snake body location, appleEaten, clock
// reset, screen refresh clock, and snake size signals as inputs and 
// generates output as the coordinates for the apple. Apple location 
// is updated in every clock cycle and new apple is generated at random
// location whenever appleEaten bit goes high.
//------------------------------------------------------------------
Apple_Gen #(
    .BorderThickness(10), 
    .AppleWidth(10),
    .AppleHeight(10),
	 .SegWidth(10),
	 .SegHeight(10)
)AppleGen0(

	.appleEaten ( appleEaten),
	.reset ( reset),
	.clock ( clock),
	.screenClock( screenClock),
	.snakeLocX ( snakeLocX),
	.snakeLocY ( snakeLocX),
	.size ( size),
	.appleLocX ( appleLocX),
	.appleLocY ( appleLocY)

);

//---------------------------------------------------------
// Instantiate the collision detector module
// The collision detector module will take inputs as the 
// apple location, snake body coordinates, snake size, clock
// and screenClock signals, reset signal, etc as inputs and 
// checks for collision of snake head with apple, snake body 
// or the borders of the screen. Collision signal will be 
// activated when snake head collides with the body or screen
// border. 
//---------------------------------------------------------

Collision_Detector # (
	
	//.......................................................
	// The parameters used in the collision detection module
	//.......................................................
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


//-------------------------------------------------------------
// Instantiate Snake Module
// This module takes clock, reset, Screen refresh rate, and
// snake direction as inputs and generates the xy coordinates
// of the snake as the output
//-------------------------------------------------------------
Snake # (
	
	.SegWidth (10),
	.SegHeight (10)
	
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





//-------------------------------------------------------------
// Instantiate Clock generator module for scrolling display
// Functioning of the scrolling display requires a fixed clock 
// speed rather than a level dependent clock
//-------------------------------------------------------------

wire scrollingDisplayClock;					//Clock for scrolling display speed

Clock_Generator #(
	.speedVal(2)
) Clk2 (
	.clock (clock),
	.reset (reset),
	.level (3'b100),						// Speed set to 4Hz
	.newClock (scrollingDisplayClock)
);

//----------------------------------------------------------------
// Instantiate Scoreboard module
//----------------------------------------------------------------

wire [7:0] score = size - 8'd1;   			//score value to display


Scoreboard ScrBrd0 (

	//...........................................
	// Inputs to scoreboard module
	//...........................................
	.clock ( clock),
	.screenClock ( scrollingDisplayClock),
	.size ( score),
	.gameOver (gameOver),
	.appleLocX ( appleLocX),
	.appleLocY ( appleLocY),
	.reset ( reset),
	.level ( level),
	.debugMode (debugMode),

	//...........................................
	// Outputs to scoreboard module
	//...........................................
	.seg0 ( seg0),
	.seg1 ( seg1),
	.seg2 ( seg2),
	.seg3 ( seg3),
	.seg4 ( seg4),
	.seg5 ( seg5)
	
);

//----------------------------------------------------------
//Instantiate the screenwriter module
//----------------------------------------------------------
ScreenWriter Write0 (
	
	//...........................................
	// Inputs to the module
	//...........................................
	.clock ( clock),
	.reset ( reset),
	.appleX ( appleLocX),
	.appleY ( appleLocY),
	.snakeX ( snakeLocX),
	.snakeY ( snakeLocY),
	.gameOver (gameOver),
	.direction (direction),
	
	//...........................................
	// Outputs to the module
	//...........................................
	.LT24Wr_n ( LT24Wr_n),
	.LT24Rd_n ( LT24Rd_n),
	.LT24CS_n ( LT24CS_n),
	.LT24RS ( LT24RS),
	.LT24Reset_n ( LT24Reset_n),
	.LT24Data ( LT24Data),
	.LT24LCDOn ( LT24LCDOn)
	
);

//------------------------------------------------------
//Instantiate the Game Over FSM module
//------------------------------------------------------
GameOver gameover0 (
	
	//....................
	// inputs
	// ...................
	.collision(collision),
	.reset (reset),
	.clock (clock),
	
	//....................
	// Outputs
	//...................
	.gameOver (gameOver)

);

//-------------------------------------------------------
//Test Ouputs to LEDs
//-------------------------------------------------------
assign directionDown = direction [0];
assign directionUp = direction [1];
assign directionRight = direction [2];
assign directionLeft = direction [3];
assign collisionHigh = collision;
assign appleEatenHigh = appleEaten;
assign resetHigh = reset;
assign screenClockHigh = screenClock;


endmodule