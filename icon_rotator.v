/*
 * Icon Rotator Module
 * ----------------------------
 * By: Thomas Birkbeck
 * For: University of Leeds
 * Date: 26th April 2024
 *
 * Description
 * ------------
 * This module instaniates the 4 rotations of the snake head icon, and outputs the respective pixelData based on 
 * the current direction the snake is travelling in, such that the head of the snake always points in the 
 * directoin of travel
 * 
 * Inputs:
 * 	direction:		 1 bit numbers which describes the current snake driection
 *		clock:			 1 bit number for clock input
 *		address: 		 7 bit number which selects the address of the memory to access for pixelData
 *
 *	Output:
 * 	pixelData:		 16 bit numbers which represents the RGB representation of the currently addressed pixel
 *
 *
 */

module icon_rotator (
	input [3:0] direction,
	input clock,
	input [6:0] address,
	output reg [15:0] pixelData
);



	
	// State machine variables and local declarations of states
	reg [3:0] state;
	reg [3:0] nextState;
	localparam DOWN = 4'b0001;
	localparam UP = 4'b0010;
	localparam RIGHT = 4'b0100;
	localparam LEFT = 4'b1000;
	
	
	// Pixel data registers from each possible rotation of the snake head icon
	wire [15:0] down_data;
	wire [15:0] up_data;
	wire [15:0] right_data;
	wire [15:0] left_data;
	
	
	// Instaniating the 1-port RAM memories which store the respective MIF files for each snake icon direction
	snake_head_DOWN snakeHeadDOWN(
		.address(address),
		.clock(clock),
		.q(down_data)
	);
	snake_head_UP snakeHeadUP(
		.address(address),
		.clock(clock),
		.q(up_data)
	);
	snake_head_RIGHT snakeHeadRIGHT(
		.address(address),
		.clock(clock),
		.q(right_data)
	);
	snake_head_LEFT snakeHeadLEFT(
		.address(address),
		.clock(clock),
		.q(left_data)
	);
	
	// State machine output logic, depending on which state the machine is in it will route the rescpective 
	// data on to the pixelData output register
	always @ (*) begin
		case (state)
			DOWN : begin
				pixelData <= down_data;
			end
			UP: begin
				pixelData <= up_data;
			end
			RIGHT : begin
				pixelData <= right_data;
			end
			LEFT: begin
				pixelData <= left_data;
			end
			default: begin
				pixelData <= down_data;
			end
		endcase
	end
	
	// State changing logic, we simply change state into which ever the current direction is
	always @ (posedge clock) begin
		case (direction)
			DOWN : begin
				nextState <= DOWN;
			end
			UP: begin
				nextState <= UP;
			end
			RIGHT : begin
				nextState <= RIGHT;
			end
			LEFT: begin
				nextState <= LEFT;
			end
			default: begin
				nextState <= DOWN;
			end
		endcase
		state <= nextState;
	end
endmodule