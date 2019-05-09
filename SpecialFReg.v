module SpecialFReg (clk, RST, data, Read_In, Load_Out, Load_DIR);
	input clk, RST;										//Clock and Reset
	input Read_In, Load_Out, Load_DIR;				//Load signals
	input [15:0] data;									//Data Bus
	
	wire [15:0] D;											//Allows for data to be bi-directional
	wire [15:0] IO;
	wire [15:0] OUT;
	wire [15:0] LOAD;
	wire [15:0] Read_Data, DIR_Out, Load_Out;		//Output of INX
	
	reg VCC = 1'b1;
	
	assign D = Read_Data ? Read_In : data;
	
	Register32bit InstReg (ContUnit, D[31:0], IL, RST, clock);
	Register16bit INX (D, IO, VCC, RST, clk);
	Register16bit OUTX (OUT, D, Load_Out, RST, clk);
	Register16bit DIRX (LOAD, D, Load_DIR, RST, clk);

endmodule
	