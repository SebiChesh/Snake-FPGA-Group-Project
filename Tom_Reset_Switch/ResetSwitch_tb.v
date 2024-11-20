`timescale  1 ns/100 ps
module ResetSwitch_tb;

	
	reg resetHW;
	reg clock;
	reg collision;
	wire reset;


	
	ResetSwitch ResetSwitch_dut(
	.resetHW (resetHW),
	.clock (clock),
	.collision(collision),
	.reset (reset)
	);
	
	
	always begin
		collision = 1'b0;
		resetHW = 1'b1;
		#5098;
		resetHW = 1'b0;
		#5075;
		resetHW = 1'b1;
		#1205;
		resetHW = 1'b0;
		#1232;
		resetHW = 1'b1;
		#100
		collision = 1'b1;
		#10
		collision = 1'b0;
		#1200;
		resetHW = 1'b0;
		#10;
		collision = 1'b1;
		#10;
		collision = 1'b0;
		#10;
		
		#9909;
		resetHW = 1'b1;
		#1505;
		
	end
	

	initial begin
		 clock = 1'b0;
	end

	
	always begin
		 clock <= 1'b1;
		 #10;
		 clock <= 1'b0;
		 #10;
		 
		 
	end


endmodule