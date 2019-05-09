module LEGv8_DATAPATH_FN(clock, RST, D, PC, instruction, r0, r1, r2, r3, r4, r5, r6, r7);
//module LEGv8_DATAPATH_FN(clock, RST, r0, r1, r2, r3, r4, r5, r6, r7);

	input clock, RST;
	wire [4:0] AA, BA;
	wire [4:0] DA, FS;
	wire En_B, En_ALU, C_in, B_SEL, WR;
	wire [63:0] K;
	wire [1:0] PS;
	
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;
	wire [31:0] ContUnit;
	wire [3:0] status;
	//wire [63:0] A, B, D;
	wire [63:0] B_Out, F;
	wire [31:0] PC_in;
	//wire [31:0] PC4, PC;
	
	//RAM inouts
	wire En_Addr, W_En, O_En, CS;
	wire [31:0] Addr;
	
	//IR and PC inouts
	wire PC_SEL, IL, En_PC_Addr, En_PC;
	
	//Control Unit inouts
	//wire [31:0] instruction;
	wire En_Stat;
	wire [3:0] Stat_O;
	wire [100:0] ContW;
	wire NS;

	assign DA = ContW[4:0];
	assign AA = ContW[9:5];
	assign BA = ContW[14:10];
	assign FS = ContW[19:15];
	assign PS = ContW[21:20];
	assign En_Stat = ContW[22];
	assign CS = ContW[23];
	assign O_En = ContW[24];
	assign W_En = ContW[25];
	assign PC_SEL = ContW[26];
	assign B_SEL = ContW[27];
	assign En_PC_Addr = ContW[28];
	assign En_PC = ContW[29];
	assign C_in = ContW[30];
	assign En_Addr = ContW[31];
	assign En_B = ContW[32];
	assign En_ALU = ContW[33];
	assign IL = ContW[34];
	assign WR = ContW[35];
	assign K = ContW[99:36];
	assign NS = ContW[100];

	output [31:0] instruction;
	wire [63:0] A, B;
	output [63:0] D;
	wire [31:0] PC4;
	output [31:0] PC;

	// Register File
	RegisterFile32x64 regfile (A, B, AA, BA, D, DA, WR, RST, clock, r0, r1, r2, r3, r4, r5, r6, r7);
	
	// RAM
	ram_sp_sr_sw RAM (clock, Addr, D, CS, W_En, O_En);
	
	// Mux connecting B and K to ALU
	mux2to1_64bit MUX (B_Out, B_SEL, B, K);
	
	// ALU
	ALU_LEGv8 ALU (A, B_Out, FS, C_in, F, status);
	
	// Tri-State Buffer connecting F to Data Bus
	tribuf buf_F_D (D, F, En_ALU);
	
	// Tri-State Buffer connecting B to Data Bus
	tribuf buff_B_D (D, B, En_B);
	
	// Tri-State Buffer connecting ALU to RAM, need to fix for 32 bit address
	assign Addr = En_Addr ? F[31:0] : 32'bz;
	
//Connecting IR and PC to Datapath

	//Instruction Register
	//Register32bit InstReg (ContUnit, D[31:0], IL, RST, clock);

	//Program Counter
	ProgramCounter PrC (PC, PC4, PC_in, PS, clock, RST);
	
	// Mux connecting A and K to PC_in
	mux2to1_32bit MUX_AK (PC_in, PC_SEL, A[31:0], K[31:0]);
	
	// Tri-State Buffer connecting PC to D
	assign D = En_PC ? {32'b0,PC} : 64'bz;
	
	// Tri-State Buffer connecting Addr to PC
	assign Addr = En_PC_Addr ? PC : 32'bz;
	
//Connecting Control Unit to Datapath

	//Connecting ROM Case to Control Unit
	rom_case ROMC (instruction, PC[15:0]);

	//status buffer
	assign Stat_O = En_Stat ? status : 4'bz;
	
	//Control Unit
	ControlUnit CntU (instruction, status, NS, ContW);

endmodule
