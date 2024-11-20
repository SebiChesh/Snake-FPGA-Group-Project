/*
 * Reset Switch Module
 * ----------------------------
 * By: Thomas Birkbeck
 * For: University of Leeds
 * Date: 9th April 2024
 *
 * Description
 * ------------
 * This module accesses the pin-assigned signal from the hadware reset (SW9) on the DE1 board:
 * When the slider is toggled from one state to anohter, a single reset pulse will go
 * high for one clock cycle
 * 
 * Inputs:
 * 	resetHW: 		 1 bit signal from the hardware switch
 *    clock:			 1 bt system clock signal
 *
 *	Output:
 * 	reset:		    1 bit software signal used by the rest of the FPGA logic, pulsed high for one clock cycle
 *
 *
 */

module ResetSwitch(
	input resetHW,
	input clock,
	output reg reset);
	
	// Delaying the hardware input signal by one clock cycle and performing an XOR
	// will give us a single pulse reset signal, it also debounces the hardware signal
	// as the siwtches are not debounced by default
		
	reg resetDelay;    
	

	always @ (posedge clock)begin
		resetDelay <= resetHW;
		reset <= ((resetDelay ^ resetHW));   
	end																  
endmodule