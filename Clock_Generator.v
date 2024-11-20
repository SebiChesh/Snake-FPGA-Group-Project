/*=========================================================
 * Clock generator Module
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 09 April 2024
 *
 *=========================================================
 *Description
 *---------------------------------------------------------
 * This module generates clock signals with the default input 50MHz clock
 *Output as slower clock depending on the parameter input.
 * 
 * Parameters: 
 * -> speedVal: Indicates number of clock cycles per second
 *
 * Inputs:
 * -> clock: Main clock signal
 * -> reset: reset signal from reset switch module
 * -> level: 3-bit input indicating speed level
 * 
 * Output:
 * newClock: the slower clock output as per requirement
 *----------------------------------------------------------
*/

//----------------------------------------------------------
// Module declaration
//----------------------------------------------------------
module Clock_Generator #(
    parameter speedVal = 2
) (
    input clock,
    input reset,
    input [2:0] level,

    output reg newClock 

);

//------------------------------------------------
// Define all necessary parameters and variables
//------------------------------------------------
parameter frequencyDefault = 50000000/(2*speedVal);  //parameter to be used for clock shifting
reg [24:0] screenClockWidth;
reg [24:0] reqFrequency;

//----------------------------------------------------------------------
// Procedural block to generate screenClock frequency shifting frequency
//----------------------------------------------------------------------
always @ (posedge clock or posedge reset) begin
    
    //.................................................
    // On reset, the default frequency corresponding 
    // to 2Hz will be assigned to reqFrequency register.
    //.................................................
    if (reset) begin

        reqFrequency = frequencyDefault;                

    end else begin

        //.........................................................
        // Different levels of speed will be achieved based on the 
        // level value. Higher the level value, higher the speed.
        //.........................................................
        case (level)

            3'b000: reqFrequency = frequencyDefault;            // Speed of 2Hz
            3'b001: reqFrequency = 10000000;                    // Speed of 2.5Hz
            3'b010: reqFrequency = 9000000;                     // Speed of 2.78Hz   
            3'b011: reqFrequency = 7500000;                     // Speed of 3.33Hz
            3'b100: reqFrequency = 6250000;                     // Speed of 4Hz
            3'b101: reqFrequency = 5000000;                     // Speed of 5Hz
            3'b110: reqFrequency = 1562500;                     // Speed of 16Hz
            3'b111: reqFrequency = 781250;                      // Speed of 32Hz
            default: reqFrequency = frequencyDefault;           // Default speed 2Hz

        endcase
    end
end

//----------------------------------------------------------------
// Procedural block for the generation of the output clock signal
// A new register screenClockWidth is used as a counter which is  
// incremented by a value of 1 in every clock cycle and gets reset
// to 1 on reset or when it reaches the reqFrequency value from
// the above procedural block.
//----------------------------------------------------------------
always @ (posedge clock or posedge reset) begin
	
    //...................................................
    // On reset, output clock will start from zero and 
    // screenClockWidth will start from 1.
    //...................................................
    if (reset) begin

		screenClockWidth=25'b1;
		newClock=1'b0;

	end else begin

		screenClockWidth = screenClockWidth+25'b1;              //Increment by 1

        //...............................................
        //Below condition will check if the counter has
        // has reached the desired frequency or not.
        //...............................................
		if (screenClockWidth >= reqFrequency) begin

			newClock=~newClock;                         // Invert the newclock signal
			screenClockWidth=25'b1;                     // Reset the counter to 1

		end	
	end
end


endmodule