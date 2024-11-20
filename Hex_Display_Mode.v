/*=========================================================
 * Display Mode Selector Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 27 April 2024
 *
 *=========================================================
 * Description
 *---------------------------------------------------------
 * This module takes gameover, debug switch inputs and deploys an FSM
 * to decide the output to the 7 segment display.
 *
 * Inputs:
 * -> clock: System clock signal
 * -> reset: Reset bit from the reset generatore module
 * -> gameOver: gameOver signal from the GameOver module
 * -> debugMode: Debug signal from sliding switch 8
 * 
 * Outputs:
 * -> [2:0] displayMode: The output indicating the display mode
 *
 *----------------------------------------------------------
*/

//----------------------------------------------------------
// Module declaration
//----------------------------------------------------------
module Hex_Display_Mode (

	//...........................................................
	// Inputs and outputs to the module
	//...........................................................
    input clock,
    input reset,
    input gameOver,
    input debugMode,

    output reg [2:0] displayMode

);

//-------------------------------------
// Parameters for state output
// A one hot encode format is adopted 
// for the state parameters
//-------------------------------------
localparam NORMAL_STATE = 3'b001;
localparam GAMEOVER_STATE = 3'b010;
localparam DEBUG_STATE = 3'b100;

reg [3:0] state;                //state variable

//------------------------------------------------
// Procedural block to display output 
// The 3-bit output is the same as the parameter 
// value
//------------------------------------------------
always @(*) begin

    case (state)

        NORMAL_STATE: begin
            displayMode<=NORMAL_STATE;              
        end

        GAMEOVER_STATE: begin
            displayMode<=GAMEOVER_STATE;
        end

        DEBUG_STATE: begin
            displayMode<=DEBUG_STATE;
        end

    endcase

end

//----------------------------------------------
// Procedural block for the State logic
//----------------------------------------------
always @ (posedge clock or posedge reset) begin
   
   //..........................................
   // Reset Logic
   // State is Normal on reset
   //..........................................
    if (reset) begin

        state<=NORMAL_STATE;

    end else begin

        case (state) 

            //...........................................
            // When in normal state, a debug signal will
            // trigger change of state to DEBUG_STATE.
            // If the debug signal is low and gameOver 
            // signal goes high, state will change to 
            // GAMEOVER_STATE.
            //...........................................
            NORMAL_STATE: begin
                
                if (debugMode) begin
                    state<=DEBUG_STATE;
                end else if (gameOver) begin
                    state<=GAMEOVER_STATE;
                end 

            end

            //......................................................
            // When it is in debug state, it will always display the 
            // parameters irrespective of whether its gameover or not.
            // State will change to NORMAL_STATE when debug switch is
            // low
            //......................................................
            DEBUG_STATE: begin
                
                if (!debugMode) begin
                    state<=NORMAL_STATE;
                end

            end 

            //.......................................................
            // When in GAMEOVER_STATE, the state will change to debug 
            // when the debug switch is high even is the gameOver bit
            // is high. When gameOver and debug signals are low, the 
            // state will change to NORMAL_STATE.
            //.......................................................
            GAMEOVER_STATE: begin
                
                if (debugMode) begin
                    state<=DEBUG_STATE;
                end 

                if (!gameOver) begin
                    state<=NORMAL_STATE;
                end

            end

            default: state<=NORMAL_STATE;           //Default state is assigned as NORMAL

        endcase

    end

end

endmodule

