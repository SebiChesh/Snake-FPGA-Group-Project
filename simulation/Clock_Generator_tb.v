/*=========================================================
 * Clock generator test bench
 *---------------------------------------------------------
 * Created by-
 * Shibin Hamza Achambat, 17 April 2024
 *
 *=========================================================
 *Description
 *---------------------------------------------------------
 * This is a test bench module to check the functionality 
 * of the clock generator module. The clock signal will be
 * varied for 100x10^6 clock cycles to capture generation
 * of the output clock signal for different values of level.
 *----------------------------------------------------------
*/

//----------------------------------------------------------
// Timescale derivative
//----------------------------------------------------------
`timescale 1 ns/100 ps

//----------------------------------------------------------
// Module Declaration
//----------------------------------------------------------
module Clock_Generator_tb;

//----------------------------------------------------------
// Declaration of module inputs and outputs
//----------------------------------------------------------
reg clock;              //Main clock
reg reset;              //Reset signal
reg [2:0] level;        //Level input based on the sliding switch

wire newClock;          //Output clock

//----------------------------------------------------------
//Instantiate dut
//----------------------------------------------------------
Clock_Generator #(
    .speedVal(2)
) Clock_Generator_dut (

    .clock ( clock),
    .reset ( reset),
    .level ( level),
    .newClock ( newClock)
);


integer i;          //Integer that will be used in the test bench logic

//-----------------------------------------------------------
// Test bench logic
//-----------------------------------------------------------
initial begin

    $display("Simulation has started at %d ns",$time);      //Simulation start indication

    //...............................................................
    // Print the critical values to display for verification
    //...............................................................
    $monitor("%d clock cycles clock=%b reset=%b level=%d newClock=%b",
                (1+i/2),clock,reset,level,newClock);

    //.................................................................
    //Initialization of input ports
    //.................................................................
    reset=1; clock=0; level = 3'b0;
    #10; reset = 0; #10; clock = 1; 

    //.................................................................
    // The testing will be done for 100x10^6 clock cycles and hence 
    // there will be 200x10^6 iterations inverting the signal. To check 
    // the effect of level values, the same will be incremented by 1 
    // after every 25x10^6 iterations. Thus, effect of every values of
    // level can be captured.
    //.................................................................
    for(i=0; i<200000000; i=i+1) begin

        #10; clock=~clock;

        //
        // The conditional statement to check for iteration number 
        // for incrementing level value
        //
        if (i%25000000==0) begin

            level = level + 1;                            // Level value added by 1                            

        end
    end

    $display("Simulation has ended at %d ns",$time);      //Simulation end indication
end

endmodule
