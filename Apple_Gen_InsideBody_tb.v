`timescale 1ns / 1ps

module Apple_Gen_InsideBody_tb();

    // Parameters
    parameter SegWidth = 10;
    parameter SegHeight = 10;
    parameter BorderThickness = 10;
    parameter AppleWidth = 10;
    parameter AppleHeight = 10;
    parameter DisplayWidth = 240;
    parameter DisplayHeight = 320;

    // Signals
    reg reset;
    reg clock;
    reg [1023:0] snakeLocX;
    reg [1152:0] snakeLocY;
    reg [7:0] size;
    reg screenClock;
    reg [7:0] appleLocX;
    reg [8:0] appleLocY;
    wire appleFoundInsideBody;

    // Instantiate the module
    Apple_Gen_InsideBody #(
        .SegWidth(SegWidth),
        .SegHeight(SegHeight),
        .BorderThickness(BorderThickness),
        .AppleWidth(AppleWidth),
        .AppleHeight(AppleHeight),
        .DisplayWidth(DisplayWidth),
        .DisplayHeight(DisplayHeight)
    ) uut (
        .reset(reset),
        .clock(clock),
        .snakeLocX(snakeLocX),
        .snakeLocY(snakeLocY),
        .size(size),
        .screenClock(screenClock),
        .appleLocX(appleLocX),
        .appleLocY(appleLocY),
        .appleFoundInsideBody(appleFoundInsideBody)
    );
	 
	 task generateSnakeCoordinates;
			 integer segmentCount;
			 begin
				  segmentCount = 5; // Example number of snake segments
  
				  // Generate snake coordinates
				  for (i = 0; i < segmentCount; i = i + 1) begin
						snakeLocX[i * 8 +: 8] = i * 20; // Example X coordinate
						snakeLocY[i * 9 +: 9] = i * 20; // Example Y coordinate
				  end
			 end
    endtask

    // Initial stimulus
    initial begin
		  
		  $display("%d ns\tSimulation Started",$time);
		  $monitor("Snake is found inside body %d ", appleFoundInsideBody);
		  screenClock = 1'b0;
		  clock = 1'b0;
		  
		  snakeLocX = 1024'd0;
		  snakeLocY = 1024'd0;
		  #10
				clock = ~clock;
		  #10
				screenClock = ~screenClock;
		  
		  
		  //Example locations of apple and snake
		  
		  appleLocX = 100;
		  appleLocY = 150;
		  size =1;
		  snakeLocX = 8'd100;
		  snakeLocY = 9'd150;
		  #10
		      clock = ~clock;
		  
		  #10
				screenClock = ~screenClock;


		


		  
	 end
    
    

endmodule
