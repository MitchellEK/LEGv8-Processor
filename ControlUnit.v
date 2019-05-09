module ControlUnit(I, status, NState, ContW);
	input [31:0] I;
	input [3:0] status;
	output [100:0] ContW;
	
	input NState;
	
	wire [100:0] AI_CW, AR_CW, LI_CW, LR_CW;
	wire [100:0] UJ_CW, CB_CW, IW_CW, D_CW;
	
	ARITH_I AI (I, AI_CW);
	ARITH_R AR (I, AR_CW);
	LOGIC_I LI (I, LI_CW);
	LOGIC_R LR (I, LR_CW);
	DATA_TRANSFER_D DD (I, D_CW);
	DATA_TRANSFER_IW DIW (I, IW_CW);
	DATA_TRANSFER_CB CB (I, CB_CW, status);
	DATA_TRANSFER_UJ UJ (I, UJ_CW);
	
	reg CCW;
	reg [2:0] S;
	
	Mux8to1100bit InMux (ContW, S, AI_CW, AR_CW, LI_CW, LR_CW, UJ_CW, CB_CW, IW_CW, D_CW);
	//Control Signals for Mux			000	001	010		011	100	101		110	111

	//Case statement to set the value of S to multiplex between Control Words
	always@(I) begin
		if ( ( ~I[29] & I[28] & ~I[27] & I[26] ) & ( ~( I[31] | I[30] ) | ( I[31] & ~I[30] ) | ( I[31] & I[30] ) ) ) 
			//Must be Unconditional Jump: 
			S <= 3'b100;
			
		else if ( ( I[28] & ~I[27] & I[26] ) & ( ( ~I[31] & I[30] ) | ( I[31] & ~I[30] ) ) )
			//Must be Conditional Branch:    
			S <= 3'b101;
		
		else if ( I[25] & ~I[24] & I[23] )
			//Must be Data Transfer: Format IW
			S <= 3'b110;
			
		else if ( I[28] & I[27] )
			//Must be Data Transfer: Format D
			S <= 3'b111;
			
		else if ( ( I[31] & ~I[26] & I[25] & ~I[23] ) & ( ( I[28] & ~I[27] ) | ~I[24] ) ) begin
			//Must be Logic
			if ( ~I[28] | ( I[28] & ~I[27] & I[24] ) ) begin
				//Must be Format R
				S <= 3'b011;
			end else begin 
				// Must be Format I
				S <= 3'b010;
			end
		end
		
		else if ( ( I[31] & ~I[26] & I[24] & ~I[23] & ~I[22] ) & ~( I[29] & ~I[28] & ~I[27] ) ) begin
			//Must be Arithmetic     
			if ( ~I[28] ) begin
				//Must be Format R
				S <= 3'b001;
			end else begin
				// Must be Format I
				S <= 3'b000;
			end
		end
		
		else begin
			//Must be custom words
			CCW <= 1'b1;
		end
	end
	
endmodule

module ARITH_I (I, ContW);
	input [31:0] I;
	output [100:0] ContW;
	
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, En_PC, En_PC_Addr, C_in, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = I[4:0];
	assign AA = I[9:5];
	assign BA = 5'b0;
	assign K = {52'b0, I[21:10]};
	assign PS = 2'b01;
	assign IL = 1'b0;
	assign En_B = 1'b0;
	assign En_Addr = 1'b0;
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign PC_SEL = 1'b0;
	assign W_En = 1'b0;
	assign O_En = 1'b0;
	assign CS = 1'b0;
	assign En_ALU = 1'b1;
	assign WR = 1'b1;
	assign B_SEL  = 1'b1;
	assign C_in = I[30];
	assign NState = 1'b0;
	
	assign En_Stat = I[29];
	assign FS[0] = I[30];
	assign FS[1] = 1'b0;
	assign FS[2] = 1'b0;
	assign FS[3] = 1'b1;
	assign FS[4] = 1'b0;
	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};
						
endmodule

module ARITH_R (I, ContW);
	input [31:0] I;
	output [100:0] ContW;
	
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, En_PC, En_PC_Addr, C_in, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = I[4:0];
	assign AA = I[20:16];
	assign BA = I[9:5];
	assign K = {58'b0, I[15:10]};
	assign PS = 2'b01;
	assign IL = 1'b0;
	assign En_B = 1'b0;
	assign En_Addr = 1'b0;
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign B_SEL = 1'b0;
	assign PC_SEL = 1'b0;
	assign W_En = 1'b0;
	assign O_En = 1'b0;
	assign CS = 1'b0;
	assign En_ALU = 1'b1;
	assign WR = 1'b1;
	assign C_in = I[30];
	assign NState = 1'b0;
	
	assign En_Stat = I[29];
	assign FS[0] = I[30];
	assign FS[1] = 1'b0;
	assign FS[2] = 1'b0;
	assign FS[3] = 1'b1;
	assign FS[4] = 1'b0;
	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};
						
endmodule

module LOGIC_I (I, ContW);
	input [31:0] I;
	output [100:0] ContW;
	
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, En_PC, En_PC_Addr, C_in, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = I[4:0];
	assign AA = I[9:5];
	assign BA = 5'b0;
	assign K = {52'b0, I[21:10]};
	assign PS = 2'b01;
	assign IL = 1'b0;
	assign En_B = 1'b0;
	assign En_Addr = 1'b0;
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign C_in = 1'b0;
	assign PC_SEL = 1'b0;
	assign W_En = 1'b0;
	assign O_En = 1'b0;
	assign CS = 1'b0;
	assign En_ALU = 1'b1;
	assign WR = 1'b1;
	assign B_SEL  = 1'b1;
	assign NState = 1'b0;
	
	assign En_Stat = I[31] & I[30] & I[29];
	assign FS[0] = 1'b0;
	assign FS[1] = 1'b0;
	assign FS[2] = ~I[30] & I[29] | I[30] & ~I[29];
	assign FS[3] = I[30] & ~I[29];
	assign FS[4] = 1'b0;
	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};
						
endmodule

module LOGIC_R (I, ContW);
	input [31:0] I;
	output [100:0] ContW;
	
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, En_PC, En_PC_Addr, C_in, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = I[4:0];
	assign AA = I[20:16];
	assign BA = I[9:5];
	assign K = {58'b0, I[15:10]};
	assign PS = 2'b01;
	assign IL = 1'b0;
	assign En_B = 1'b0;
	assign En_Addr = 1'b0;
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign C_in = 1'b0;
	assign PC_SEL = 1'b0;
	assign W_En = 1'b0;
	assign O_En = 1'b0;
	assign CS = 1'b0;
	assign En_ALU = 1'b1;
	assign WR = 1'b1;
	assign B_SEL = I[24];
	assign NState = 1'b0;
	
	assign En_Stat = I[29];
	assign FS[0] = 1'b0;
	assign FS[1] = 1'b0;
	assign FS[2] = ~I[30] & I[29] & ~I[28] & I[27] & ~I[24] & ~I[22] & ~I[21] | I[30] & ~I[29] & ~I[28] & I[27] & ~I[24] & ~I[22] & ~I[21] | I[30] & ~I[29] & I[28] & ~I[27] & I[24] & I[22] & ~I[21];
	assign FS[3] = I[30] & ~I[29] & ~I[28] & I[27] & ~I[24];
	assign FS[4] = I[24];

	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};
						
endmodule

module DATA_TRANSFER_D (I, ContW); 

	input [31:0] I;
	output [100:0] ContW;
	
	//Pieces of the output control word
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, En_PC, En_PC_Addr, C_in, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = I[22] ? I[4:0] : 5'b00000;
	assign AA = I[9:5]; 
	assign BA = I[4:0];
	assign K = {55'b0, I[20:12]};
	assign FS = 5'b01000;
	assign PS = 2'b01;
	assign IL = 1'b0;
	assign En_B = ~I[22];
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign C_in = 1'b0;
	assign PC_SEL = 1'b0;
	assign CS = 1'b1;
	assign B_SEL = 1'b1;
	assign NState = 1'b0;
	assign En_Stat = 1'b0;
	
	assign WR = I[22];
	assign O_En = I[22];
	assign En_ALU = 1'b0;
	assign W_En = ~I[22];
	assign En_Addr = 1'b1;
	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};
						
						
endmodule 

module DATA_TRANSFER_IW (I, ContW);

	input [31:0] I;
	output [100:0] ContW;
	
	//Pieces of the output control word
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, En_PC, En_PC_Addr, C_in, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = I[4:0];
	assign BA = 5'b0;
	assign IL = 1'b0;
	assign En_B = 1'b0;
	assign En_Addr = 1'b0;
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign C_in = 1'b0;
	assign PC_SEL = 1'b0;
	assign W_En = 1'b0;
	assign O_En = 1'b0;
	assign CS = 1'b0;	
	assign En_ALU  = 1'b1;
	assign En_Stat = 1'b0;
	
	assign NState = I[29];
	assign AA = ~I[29] ? 5'b11111 : 5'b0;
	assign K = ~I[29] ? {48'b0, I[20:5]} : 64'hFFFFFFFFF00000000;
	assign PS = ~I[29] ? 2'b01 : 2'b00;
	assign WR = ~I[29] ? 1'b1 : 1'b0;
	assign B_SEL = ~I[29] ? 1'b1 : 1'b0;

	assign FS[0] = 1'b0;
	assign FS[1] = 1'b0;
	assign FS[2] = ~I[29];
	assign FS[3] = 1'b0;
	assign FS[4] = 1'b0;
	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};						
						
endmodule 

module DATA_TRANSFER_CB (I, ContW, status); 

	input [31:0] I;
	input[3:0] status;
	output [100:0] ContW;
	
	//10110100 CBZ
	//10110101 CBNZ
	//01010100 B.cond, currently not implemented

	//Pieces of the output control word
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = 5'b11111;
	assign AA = I[4:0];
	assign BA = 5'b11111;
	//allows K to be negative
	assign K[63:32] = 32'b0;
	assign K[18:0] = I[23:5];
	assign K[31] = I[23];
	assign K[30] = I[23];
	assign K[29] = I[23];
	assign K[28] = I[23];
	assign K[27] = I[23];
	assign K[26] = I[23];
	assign K[25] = I[23];
	assign K[24] = I[23];
	assign K[23] = I[23];
	assign K[22] = I[23];
	assign K[21] = I[23];
	assign K[20] = I[23];
	assign K[19] = I[23];
	assign PS[0] = 1'b1;
	assign PS[1] = ~status[0];
	assign PC_SEL = status[0];
	
	assign IL = 1'b0;
	assign En_B = 1'b0;
	assign En_Addr = 1'b0;
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign W_En = 1'b0;
	assign O_En = 1'b0;
	assign CS = 1'b0;
	assign En_ALU = 1'b0;
	assign WR = 1'b0;
	assign B_SEL  = 1'b0;
	assign C_in = 1'b0;
	assign NState = 1'b0;
	assign En_Stat = 1'b0;
	assign FS = 5'b01000;
	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};
						
						
endmodule 

module DATA_TRANSFER_UJ (I, ContW); 

	input [31:0] I;
	output [100:0] ContW;
	//Does not work for BR
	
	//Pieces of the output control word
	wire [4:0] DA, AA, BA, FS;
	wire [63:0] K;
	wire [1:0] PS;
	wire WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, NState;
	
	assign DA = 5'b0;
	assign AA = 5'b0; 
	assign BA = 5'b0;
	
	//assign K = {38'b0, I[25:0]};
	//allows K to be negative
	assign K[25:0] = I[25:0];
	assign K[31] = I[25];
	assign K[30] = I[25];
	assign K[29] = I[25];
	assign K[28] = I[25];
	assign K[27] = I[25];
	assign K[26] = I[25];
	assign K[63:32] = 32'b0;
	assign FS = 5'b00000;
	assign En_ALU = 1'b0;
	assign IL = 1'b0;
	assign En_B = 1'b0;
	assign C_in = 1'b0;
	assign En_PC = 1'b0;
	assign En_PC_Addr = 1'b0;
	assign CS = 1'b0;
	assign W_En = 1'b0;
	assign O_En = 1'b0;
	assign En_Addr = 1'b0;
	assign NState = 1'b0;
	assign En_Stat = 1'b0;
	assign PC_SEL = 1'b1;
	assign WR = 1'b0;
	assign B_SEL = 1'b0;
	assign PS = 2'b11;
	
	assign ContW = {NState, K, WR, IL, En_ALU, En_B, En_Addr, C_in, En_PC, En_PC_Addr, 
						B_SEL, PC_SEL, W_En, O_En, CS, En_Stat, PS, FS, BA, AA, DA};
						
						
endmodule
