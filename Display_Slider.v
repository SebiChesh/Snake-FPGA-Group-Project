/*=========================================================
 * Display Slider Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 20 April 2024
 *
 *=========================================================
 *Description
 *------------------------------------------------------------
 * This module takes clock, reset, and a register with size 
 * based on the parameter VarLength as input. The name of 
 * the register is allVals and denotes the sentence to be 
 * printed on the seven-segment display. In every clock cycle,
 * the module outputs 6 7-bit wide registers to be displayed
 * on the seven-segment display. To achieve the functionality
 * of a scrolling display, the module shifts allVals by 7 bits
 *  and uses a temporary register to store the values in it.
 * The most significant 42 bits of the temporary register are
 * the assigned to the output.
 * 
 * Parameters: Varlength (Default value: 140)
 *
 * Inputs:
 * -> clock
 * -> reset
 * -> [VarLength-1:0] allVals 
 * 
 * Outputs:
 * -> seg0, seg1, seg2, seg3, seg4, seg5 (All 7-bit registers)
 *-------------------------------------------------------------
*/

//--------------------------------------------------------------
// Module Declaration 
//--------------------------------------------------------------
module Display_Slider # (
    parameter VarLength = 140
) (
	//...........................................................
	// Inputs to the module
	//...........................................................
    input [VarLength-1:0] allVals,
    input clock,
    input reset,
    
	//...........................................................
	// Outputs to the module
	//...........................................................
    output [6:0] seg0,
    output [6:0] seg1,
    output [6:0] seg2,
    output [6:0] seg3,
    output [6:0] seg4,
    output [6:0] seg5
    
);

//-----------------------------------------------------------
// Wires and registers needed in the module
//-----------------------------------------------------------
reg [7:0] counter;                  // Counter for checking how many bits have been shifted
reg [41:0] selectedVal;             // Most significant 42 bits from the temporary regoster
reg [VarLength-1:0] tempVal;        // Temporary register

localparam Start = VarLength - 1;   // Parameter to set counter value to zero

//-----------------------------------------------------------
// Procedural block where shifting algorithm works and 
// selects 42-bit wide register for assigning to the output
// ports.
//-----------------------------------------------------------
always @(posedge clock or posedge reset) begin

    //........................................
    // Reset Logic
    //........................................
    if (reset) begin

        counter=0;
		selectedVal <= 42'b011111101111110111111011111101111110111111;
        tempVal = allVals;

    end else begin

        if (counter>0) begin
            if (counter>=Start) begin           // Checks if counter is exceeding Start param

                counter=0;                      // Counter is reset 
                tempVal = allVals;              // Temporary register assigned the value of input

            end else begin

                counter = counter+7;            // Counter incremented by 7
                tempVal = tempVal<<7;           // Left shifting logic
                tempVal [6:0] = 7'b1111111;     // This is to ensure no output on the Hex display for these bits

            end
        end else begin

            tempVal = allVals;                  // If counter is zero
            counter = counter+7;                // Counter should add by 7

        end

        selectedVal <= tempVal[Start:Start-41]; // The selected 42-bit wide register

    end

end

//-------------------------------------------------
// Here, the continuous assignment of the output 
// ports is done. The selected 42-bit register values
// from above procedural block used.
//-------------------------------------------------
assign seg0 = selectedVal[6:0];
assign seg1 = selectedVal[13:7];
assign seg2 = selectedVal[20:14];
assign seg3 = selectedVal[27:21];
assign seg4 = selectedVal[34:28];
assign seg5 = selectedVal[41:35];


endmodule