/*
 * Screen Writer Module
 * ----------------------------
 * By: Thomas Birkbeck
 * For: University of Leeds
 * Date: 9th April 2024
 *
 * Description
 * ------------
 * This module instaniates the LT24 display IP and iterfaces directly to the LT24 hardware
 * Additionally this module determines the pixelData which should be outputted to each pxiel on the screen,
 * this is done through combinatorial logic and 1-port RAM memory IPs for images
 * 
 * Inputs:
 *		clock:			 1 bit number for clock input
 *		screenClock:	 1 bit clock signal for updating the actual appearence of the screen
 *		reset:			 User-diven reset signal
 *		appleX:		    8 bit number for current apple X location
 *		appleY:			 9 bit number for current apple Y location
 *		snakeX:			 1024 bit register containing every X location of all 127 segments of the snake
 *		snakeY:			 1152 bit register containing every Y location of all 127 segments of the snake
 *		gameOver:		 1 bit signal, high when the logic is in a gameOver state
 *		direction:		 4 bit signal which contains the current direction that the snake is moving in
 *		
 *
 *	Outputs:
 *
 *		All of the outputs are pin-assigned hardware signals necessary for communicating with the LT24
 *		peripheral, none of these signals are accessed in the rest of the FPGA logic
 *		they are:
 *	
 *		LT24Wr_n
 *		LT24Rd_n
 *		LT24CS_n
 *		LT24RS
 *		LT24Reset_n
 *		LT24Data
 *		LT24LCDOn
 *
 *
 *
 *		Snake start screen image sourced from Erhan Kılıç for Dev.to
 *		Accessed 2024 via: "https://dev.to/erhankilic/making-snake-game-with-javascript-51ph"
 */



module ScreenWriter #(

	parameter SegWidth = 10,
	parameter SegHeight = 10,
	parameter BorderThickness = 10,
	parameter DisplayWidth = 240,
	parameter DisplayHeight = 320,
	parameter AppleWidth = 10,
	parameter AppleHeight = 10
)(
    // - Clock and screenClock
    input              clock,
	 input   screenClock,

    // - Global Reset
    input              reset,
	 // - Apple and snake values
	 input [7:0] appleX,
	 input [8:0] appleY,
	 input [1023:0] snakeX,
	 input [1151:0] snakeY,
	 input gameOver,
	 input [3:0] direction,


    
    // LT24 Interface
    output             LT24Wr_n,
    output             LT24Rd_n,
    output             LT24CS_n,
    output             LT24RS,
    output             LT24Reset_n,
    output [     15:0] LT24Data,
    output             LT24LCDOn
);

//
// Local Variables for communicating to the LT24 display driver
//
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;
integer i,j,k,l;
reg [7:0] snakeLocXArray [127:0]; 
reg [8:0] snakeLocYArray [127:0];
reg [1:0] state,nextState;

	
wire resetApp;

//
// LCD Display driver instantiation
// *
// * By: Thomas Carpenter
// * For: University of Leeds
// * Date: 13th March 2017
//

localparam LCD_WIDTH  = DisplayWidth;
localparam LCD_HEIGHT = DisplayHeight;

LT24Display #(
    .WIDTH       (DisplayWidth  ),
    .HEIGHT      (DisplayHeight ),
    .CLOCK_FREQ  (50000000   )
) Display (
    //Clock and Reset In
    .clock       (clock      ),
    .globalReset (reset),
    //Reset for User Logic
    .resetApp    (resetApp   ),
    //Pixel Interface
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    //Use pixel addressing mode
    .pixelRawMode(1'b0       ),
    //Unused Command Interface
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    //Display Connections
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

// X Counter to address the LT24 correctly
wire [7:0] xCount;
UpCounterNbit #(
    .WIDTH    (          8),
    .MAX_VALUE(DisplayWidth-1)
) xCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (pixelReady),
    .countValue(xCount    )
);


// Y Counter to address the LT24 correctly
wire [8:0] yCount;
wire yCntEnable = pixelReady && (xCount == (DisplayWidth-1));
UpCounterNbit #(
    .WIDTH    (           9),
    .MAX_VALUE(DisplayHeight-1)
) yCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (yCntEnable),
    .countValue(yCount    )
);



// Local signals for the start screen image
reg [16:0] pixelSel;
wire [15:0] pixelVal_start;

// Instantiating the RAM which contains the start screen image
start_screen startScreen(
	.address(pixelSel),
	.clock(clock),
	.q(pixelVal_start)
);

// Local signals for the background image
wire [15:0] pixelVal_background;

// Instantiating the RAM which contains the background image
grass_background grassBackground(
	.address(pixelSel),
	.clock(clock),
	.q(pixelVal_background)
);
	
// Local signals for the apple icon
wire [15:0] pixelVal_apple;
reg [6:0] apple_icon_address;
reg [8:0] yStartApple;
reg [7:0] xStartApple;

// Instatiating the RAM which contains the apple icon image
apple_icon appleIcon(
	.address(apple_icon_address),
	.clock(clock),
	.q(pixelVal_apple)
);
	
// Local signals foor the snake head icon memory
reg [6:0] snake_icon_address;
wire [15:0] pixelVal_snake;
reg [8:0] yStartSnake;
reg [7:0]xStartSnake;

// Instantiating the icon_rotator FSM modules such that we draw each rotation of the 
// head icon based on the current direction
icon_rotator snakeIcon(
	.direction(direction),
	.clock(clock),
	.address(snake_icon_address),
	.pixelData(pixelVal_snake)
);
//
// Pixel Write
//

always @ (posedge clock or posedge resetApp) begin
	 // If we are in a reset then we do not update the screen
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end 
	 // Otherwise we are constantly drawing pixelData to the currently addressed pixel
	 else begin
        pixelWrite <= 1'b1;
    end
end


// Building the 2D snake location array

always @(posedge clock or posedge reset) begin
	if (reset) begin	
		snakeLocXArray[0] = 8'd50;
		snakeLocYArray[0] = 9'd50;				
		for (i=1;i<128;i=i+1) begin			
			// Builds the snakeLocXArray from snakeLocX
			for (j=0;j<8;j=j+1) begin				
				snakeLocXArray[i][j] = 1'b0;					
			end			
			// Builds the snakeLocYarray from snakeLocY
			for (k=0;k<9;k=k+1) begin				
				snakeLocYArray[i][k]= 1'b0;					
			end
		end
		
	end else begin		
		for (i=0;i<128;i=i+1) begin			
			// Builds the snakeLocXArray from snakeLocX
			for (j=0;j<8;j=j+1) begin				
				snakeLocXArray[i][j] = snakeX[i*8+j];					
			end			
			// Builds the snakeLocYarray from snakeLocY
			for (k=0;k<9;k=k+1) begin				
				snakeLocYArray[i][k]= snakeY[i*9+k];
			end
		end
	end
end


always @ (posedge clock or posedge resetApp) begin

	 // On reset app we dont write anything to the screen
	 
    if (resetApp) begin
        pixelData           <= 16'b0;
        xAddr               <= xCount;
        yAddr               <= yCount;
		  
    end 
	 
	 // Same with user-driven hardware reset
	 
	 else if (reset) begin
        pixelData           <= 16'b0;
        xAddr               <= xCount;
        yAddr               <= yCount;
		  
    end 
	 
	 // In our gameOver state (and when the board is first launched) we output a start screen prompting the user
	 // to press reset to begin playing
	 
	 else if (gameOver) begin                
		  xAddr               <= xCount;
        yAddr               <= yCount;
		  pixelSel <= (xCount*320) + yCount;
		  pixelData <= pixelVal_start;
	 end
	 
	 // If we are ready to write a pixel then we continue and determine the correct
	 // RGB pixelData to write
	 
	 else if (pixelReady) begin
	 
		  // Increment X value with a counter and loop
		  xAddr <= xCount;
		  
		  // Increment Y value with a counter and loop
		  yAddr <= yCount;
		 
		  // We default to drawing the grass background
		  // This is accessed from the memory which stores the background image
		  pixelSel <= (xCount*320)+ yCount;
		  pixelData <= pixelVal_background;
		  
		  
		  // Border detection is a simple logical operation
		  if (xCount < BorderThickness || xCount >= (DisplayWidth-BorderThickness) || yCount < BorderThickness || yCount >= (DisplayHeight-BorderThickness)) begin
				pixelData[4:0] <= 5'b01000;
				pixelData[10:5] <= 6'b100000;        //Yellow for border
				pixelData[15:11] <= 5'b11111;
		  end
		  
		  // Apple detection based on apple coordinates
		  else if (xCount == appleX && yCount == appleY) begin 
			
					// If we are at the top left of the apple we must store these values, 
					// this is necessarry for correctly working out the index address to access 
					// to obtain the image of the apple
					
					xStartApple<=xCount;
					yStartApple<=yCount;
		  end
		  else if (xCount >= appleX && xCount < (appleX+AppleWidth) && yCount >= appleY && yCount < (appleY+AppleHeight)) begin
		  
					// If we are in the apple, access it with our current offset from the top-left coordinate
					// of the icon, write this pixelData on the screen
					
					apple_icon_address <= ((xCount-xStartApple)*10)+ (yCount-yStartApple);
					pixelData <= pixelVal_apple;	
					
		  end 
		  
		  
		  // Snake detection in a loop for the whole length of the snake
		  else begin
			  // If at the top-left of the head, store the coordinate for indexing the memory correctly
		     if (xCount == snakeLocXArray[0] && yCount == snakeLocYArray[0]) begin
					xStartSnake <= xCount;
					yStartSnake <= yCount;
			  end 
			  
			  // Loop through the whole body, if out pixel is within the snake draw it purple
			  for (l=0;l<127;l=l+1) begin
					if (xCount > snakeLocXArray[l] && xCount < (snakeLocXArray[l]+SegWidth) && yCount > snakeLocYArray[l] && yCount < (snakeLocYArray[l]+SegHeight)) begin
						pixelData[4:0] <= 5'b10000;   //B
						pixelData[10:5] <= 6'b0;  //G    
						pixelData[15:11] <= 5'b10000; //R
						
						// When l=0 we are at the snake's head, so we draw pxielData from the head memory,
						// accessed using the offset from the top-left pixel of the snake's head
						if (l==0) begin
							snake_icon_address <= ((xCount-xStartSnake)*10)+ (yCount-yStartSnake);
							pixelData <= pixelVal_snake;
																					
						end
					end					                     
			  end
		  end 
    end
end

endmodule







