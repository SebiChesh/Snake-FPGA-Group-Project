/*=========================================================
 * Scoreboard Display Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 31 March 2024
 *
 *=========================================================
 *Description
 *---------------------------------------------------------
 * This module takes clock, a display refresh clock, size, 
 * apple locations, a debug switch, level indication, game
 * over, and reset signals as inputs.
 * Generates a scrolling display with three different modes 
 * depending on the state of the game and user requirement. 
 * An additional feature is integration of a debugging mode 
 * wheredesired values (in this condition appleLocX and Y) 
 * are displayed on the board. This module uses a Finite 
 * State Machine to determine the desired display mode.
 *
 * Inputs:
 * -> clock: Main clock signal
 * -> screenClock: Slower clock signal for scrolling display
 * -> size: score value to display (snake size -1 )
 * -> appleLocX: apple x-location for debugging
 * -> appleLocY: apple y-location for debugging
 * -> debugMode: signal from Sliding switch 8
 * -> reset: reset signal from reset switch module
 * -> gameOver: gameOver signal from game over module
 * -> level: level switch value (000 to 111)
 *
 * Outputs:
 * -> seg0, seg1, seg2, seg3, seg4, seg5: Output to 7-segment
										  display
 *----------------------------------------------------------
*/

//----------------------------------------------------------
// Module declaration
//----------------------------------------------------------
module Scoreboard (
	
	//......................................................
	// inputs
	//......................................................
	input clock,
	input screenClock,
	input [7:0] size,
	input [7:0] appleLocX,				//For debugging
	input [8:0] appleLocY,				//For debugging
	input debugMode,					//Sliding switch 8 input for debugging
	input reset,
	input gameOver,
	input [2:0] level,
	
	//......................................................
	// outputs
	//......................................................
	output [6:0] seg0,
	output [6:0] seg1,
	output [6:0] seg2,
	output [6:0] seg3,
    output [6:0] seg4,
    output [6:0] seg5

);

wire [11:0] digitConverted;

//--------------------------------------------------------------------
// BCD conversion of apple loc X
// Parameter N is instantiated with a value of 8 which is the size of
// score value
//--------------------------------------------------------------------
DoubleDabber_calc # (
	.N(8)
) Dub_1 (
	.a (size),
	.digit (digitConverted)
);


wire [6:0] hexDigit0; wire [6:0] hexDigit1; wire [6:0] hexDigit2;
wire [6:0] hexLevel;

//--------------------------------------------------------
// Instantiate Seven Segment display
//--------------------------------------------------------
HexTo7Segment #(
	.INVERT_OUTPUT(1)
) Hex_Conv1 (
	.HexVal (digitConverted [3:0]),
	.SevenSeg (hexDigit0)
);
HexTo7Segment #(
	.INVERT_OUTPUT(1)
) Hex_Conv2 (
	.HexVal (digitConverted [7:4]),
	.SevenSeg (hexDigit1)
);
HexTo7Segment #(
	.INVERT_OUTPUT(1)
) Hex_Conv3 (
	.HexVal (digitConverted [11:8]),
	.SevenSeg (hexDigit2)
);

HexTo7Segment #(
	.INVERT_OUTPUT(1)
) Hex_Conv4 (
	.HexVal ({1'b0,level}),
	.SevenSeg (hexLevel)
);

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// Parameters to be displayed for troubleshooting calculated below.
// Code for converting apple location values to the Decimal values and 
// the subsequent Hex to 7 segment conversion is as below. 
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
wire [11:0] digitConverted1;
wire [11:0] digitConverted2;
wire [6:0] hexDigit1_0; wire [6:0] hexDigit1_1; wire [6:0] hexDigit1_2;
wire [6:0] hexDigit2_0; wire [6:0] hexDigit2_1; wire [6:0] hexDigit2_2;

//--------------------------------------------------------------------
// BCD conversion of apple loc X
// Parameter N is instantiated with a value of 8 which is the size of
// appleLocX
//---------------------------------------------------------------------
DoubleDabber_calc # (
	.N(8)
) Dub_2 (
	.a (appleLocX),
	.digit (digitConverted1)
);

//--------------------------------------------------------------------
// BCD conversion of apple loc X
// Parameter N is instantiated with a value of 9 which is the size of
// appleLocY
//---------------------------------------------------------------------
DoubleDabber_calc # (
	.N(9)
) Dub_3 (
	.a (appleLocY),
	.digit (digitConverted2)
);


//-------------------------------------------------------------
// Instantiate Seven Segment display for apple X location
//-------------------------------------------------------------
HexTo7Segment #(								//Digit 1
	.INVERT_OUTPUT(1)
) Hex_Conv1_1 (
	.HexVal (digitConverted1 [3:0]),
	.SevenSeg (hexDigit1_0)
);

HexTo7Segment #(								//Digit 2	
	.INVERT_OUTPUT(1)
) Hex_Conv1_2 (
	.HexVal (digitConverted1 [7:4]),
	.SevenSeg (hexDigit1_1)
);

HexTo7Segment #(								//Digit 3
	.INVERT_OUTPUT(1)
) Hex_Conv1_3 (
	.HexVal (digitConverted1 [11:8]),
	.SevenSeg (hexDigit1_2)
);


//-------------------------------------------------------------
// Instantiate Seven Segment display for apple Y location
//-------------------------------------------------------------
HexTo7Segment #(								//Digit 1
	.INVERT_OUTPUT(1)
) Hex_Conv2_1 (
	.HexVal (digitConverted2 [3:0]),
	.SevenSeg (hexDigit2_0)
);

HexTo7Segment #(								//Digit 2
	.INVERT_OUTPUT(1)
) Hex_Conv2_2 (
	.HexVal (digitConverted2 [7:4]),
	.SevenSeg (hexDigit2_1)
);

HexTo7Segment #(								//Digit 3
	.INVERT_OUTPUT(1)
) Hex_Conv2_3 (
	.HexVal (digitConverted2 [11:8]),
	.SevenSeg (hexDigit2_2)
);

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//End of section generating of debugging signals for appleLoc
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//-------------------------------------------------------------------
// The 7 segment values corresponding to all the required alphabets in
// the display are assigned to wires as below. These values will be 
// used later for creating the sentence for display.
//-------------------------------------------------------------------
wire [6:0] alphaL = 7'b1000111;					//Alphabet L
wire [6:0] alphaE = 7'b0000110;					//Alphabet E
wire [6:0] alphaV = 7'b1000001;					//Alphabet V
wire [6:0] alphaS = 7'b0010010;					//Alphabet S
wire [6:0] alphaT = 7'b0000111;					//Alphabet T
wire [6:0] alphaA = 7'b0001000;					//Alphabet A
wire [6:0] alphaG = 7'b1000010;					//Alphabet G
wire [6:0] alphaC = 7'b1000110;					//Alphabet C
wire [6:0] alphaO = 7'b1000000;					//Alphabet O
wire [6:0] alphaR = 7'b0101111;					//Alphabet R
wire [6:0] alphaD = 7'b0100001;					//Alphabet D
wire [6:0] alphaH = 7'b0001001;					//Alphabet H
wire [6:0] alphaN = 7'b0101011;					//Alphabet N
wire [6:0] alphaI = 7'b1111001;					//Alphabet I
wire [6:0] alphaP = 7'b0001100;					//Alphabet P
wire [6:0] dash = 7'b0111111;					//Display dash
wire [6:0] space = 7'b1111111;					//Display space


//---------------------------------------------------------------------
// Instantiate Hex_DIsplay_Mode module for determining display state
//---------------------------------------------------------------------
wire [2:0] displayMode;			//Display mode is the output from the state machine 				

Hex_Display_Mode Hex_Disp1 (

	.clock ( clock),
	.reset ( reset),
	.gameOver ( gameOver),
	.debugMode ( debugMode),
	.displayMode ( displayMode)
);


//--------------------------------------------------------------------
// In this section, sentences to be displayed corresponding to each 
// display mode will be calculated. 
//--------------------------------------------------------------------
reg [139:0] allVals;
reg [139:0] tempVals;
reg tempReset;				//This register acts as a temporary reset for scrolling display when there is a state change

//---------------------------------------------------------------------
// Parameters for the state outputs from the FSM, will be used in 
// case statements for selection of sentence to display
//---------------------------------------------------------------------
localparam NORMAL = 3'b001;
localparam GAMEOVER = 3'b010;
localparam DEBUG = 3'b100;

//----------------------------------------------------------------------
// In every clock cycles, value of displayMode will be checked and 
// corresponding sentence will be assigned to allVals register.
//----------------------------------------------------------------------
always @ (posedge clock) begin

	case(displayMode) 

		//..............................................................
		// Display: "Level (Level value) Score (size-1)"
		//..............................................................
		NORMAL: allVals <= {alphaL,alphaE,alphaV,alphaE,alphaL,space,hexLevel,space,alphaS,alphaC,alphaO,
							alphaR,alphaE,space,hexDigit2,hexDigit1,hexDigit0,space,space,space};

		//..............................................................
		// Display: "APPLE LOC - (Apple x-coordinate) - (Apple y-coordinate)"
		//..............................................................				
		DEBUG: allVals <= {alphaA,alphaP,alphaP,alphaL,alphaE,space,alphaL,alphaO,alphaC,space,dash,
							space,hexDigit1_2,hexDigit1_1,hexDigit1_0,space,dash,hexDigit2_2,hexDigit2_1,hexDigit2_0};

		//..............................................................
		// Display: "Press reset to start"
		//..............................................................
		GAMEOVER: allVals <= {alphaP,alphaR,alphaE,alphaS,alphaS,space,alphaR,alphaE,
							alphaS,alphaE,alphaT,space,alphaT,alphaO,space,alphaS,alphaT,
							alphaA,alphaR,alphaT};
	
	endcase	

end

//--------------------------------------------------------------------
// Logic for temporary reset input whenever state changes
// This is to make sure display always starts from the beginning in 
// the event of a state change.
//--------------------------------------------------------------------
always @ (posedge screenClock or posedge reset) begin
	
	//................................................................
	// The temporary reset value will be assigned a value of 0 on reset.
	// tempVal will be assigned the value of allVal
	//................................................................
	if (reset) begin

		tempReset <= 1'b0;
		tempVals = allVals;

	end else begin

		//............................................................
		// tempReset will be assigned zero when tempVals and allVals 
		// are the same. When allVals change due to changes in display
		// mode, the conditional statement output will be false, which
		// then executes the else statement wo assign tempReset to 1 
		// and allVals value to tempVal
		//............................................................
		if(tempVals==allVals) begin

			tempReset <= 1'b0;

		end else begin

			tempReset <= 1'b1;
			tempVals = allVals;

		end
	end


end

//-------------------------------------------------------------
// Instantiate the scrolling display module 
// The output ports to Scoreboard module are directly connected 
// to the output from display slider module. 
//-------------------------------------------------------------
Display_Slider #(

	.VarLength(140)				//Sentence length kept as 140 bits

) DispSlid0 (

	//
	// Module inputs
	//
	.clock ( screenClock),					// screenClock input used for scrolling speed
	.reset ( tempReset | reset),			// tempReset or reset whichever is high will trigger reset logic
	.allVals ( allVals),		

	//
	// Module outputs to 7 segment display
	//
	.seg0 (seg0),
	.seg1 (seg1),
	.seg2 (seg2),
	.seg3 (seg3),
	.seg4 (seg4),
	.seg5 (seg5)

);


endmodule