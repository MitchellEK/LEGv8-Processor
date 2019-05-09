module DE0_LEGv8(CLOCK_50, LEDG, SW, BUTTON, GPIO0_D, GPIO1_D, HEX0, HEX1, HEX2, HEX3);
	// connection names for DE0 FPGA boad - names must match pin assignment file
	input CLOCK_50;
	input [9:0] SW;
	input [2:0] BUTTON; // sometimes called BUTTON
	inout [31:0] GPIO1_D; // sometimes called GPIO1_D
	output [31:0] GPIO0_D; // sometimes called GPIO0_D
	output [9:0] LEDG;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
	// use button 0 for reset
	wire clock, reset, pll_clock;
	LEGv8_35 pll (CLOCK_50, pll_clock);	//20Mhz clock speed
	// buttons are active low so invert them to get possitive logic
	assign clock = SW[0] ? ~BUTTON[2] : pll_clock;
	assign reset = ~BUTTON[0];
	
	// wires of outputs for visualization on GPIO Board
	wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;
	wire [31:0] instruction;
	wire [31:0] address;
	wire [63:0] data;
	
	// DIP switch input from GPIO Board
	wire [31:0] DIP_SW;
	
	// wires for 7-segment decoder outputs
	wire [6:0] h0, h1, h2, h3, h4, h5, h6, h7, hex0, hex1, hex2, hex3;
	// create 7-segment decoders (4x at a time)
	// display upper 16 bits of address on hex 7:4 (on GPIO board)
	quad_7seg_decoder address_decoder_high (address[31:16], h7, h6, h5, h4);
	// display lower 16 bits of address on hex 3:0 (on GPIO board)
	quad_7seg_decoder address_decoder_low (address[15:0], h3, h2, h1, h0);
	// display lower 16 bits of data on HEX 3:0 (on DE0 itself)
	quad_7seg_decoder data_decoder (data[15:0], hex3, hex2, hex1, hex0);
	assign HEX0 = ~hex0; // each signal must be inverted because DE0 hex's are active low
	assign HEX1 = ~hex1;
	assign HEX2 = ~hex2;
	assign HEX3 = ~hex3;
	
	// instantiate GPIO_Board module
	GPIO_Board gpio_board (
		CLOCK_50, // connect to CLOCK_50 of the DE0
		r0, r1, r2, r3, r4, r5, r6, r7, // row display inputs
		h0, 1'b0, h1, 1'b0, // hex display inputs
		h2, 1'b0, h3, 1'b0, // 0 connected to decimal point inputs
		h4, 1'b0, h5, 1'b0, 
		h6, 1'b0, h7, 1'b0, 
		DIP_SW, // 32x DIP switch output
		instruction, // 32x LED input (show the IR output)
		GPIO0_D, // (output) connect to GPIO_0
		GPIO1_D // (input/output) connect to GPIO_1
	);
	
	/////////// This line should be completely replaced with your processor and the
	/////////// connection order appropriate using the names from this file
	//LEGv8 processor (clock, reset, data, address, mem_read, mem_write, size, portA, portB, instruction, r0, r1, r2, r3, r4, r5, r6, r7);
	LEGv8_DATAPATH_FN processor (clock, reset, data, address, instruction, r0, r1, r2, r3, r4, r5, r6, r7);

endmodule
