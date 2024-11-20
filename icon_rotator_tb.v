`timescale 1 ns/100 ps

module icon_rotator_tb;

	reg [3:0]direction;
	reg clock;
	reg [7:0]address;
	wire [15:0]pixelData;


	icon_rotator icon_rotator_tb(
		.direction (direction),
		.clock (clock),
		.address (address),
		.pixelData (pixelData)
		
	);


	initial begin
		clock <= 0;
		address <= 00000000;
		#10;
		direction <= 4'b0001;
		#500;
		direction <= 4'b0100;
		#500;
		direction <= 4'b0010;
		#500;
		direction <= 4'b1000;
		#500;
		
	end


	always begin
	   #10;
		clock <= ~clock;
		
	end
endmodule