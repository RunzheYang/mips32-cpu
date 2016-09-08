/**
 * Memory
 */
`define	AddrStart	32'h00000000

/**
 * instruction Constants
 */
`define SPECIAL		6'b000000
	`define AND 	6'b100100
	`define OR 		6'b100101
	`define XOR 	6'b100110
	`define NOR 	6'b100111

	`define SLL		6'b000000
	`define SRL		6'b000010
	`define SRA		6'b000011
	`define SLLV	6'b000100
	`define SRLV	6'b000110
	`define SRAV	6'b000111

	`define SYNC	6'b001111

	`define MOVZ	6'b001010
	`define MOVN	6'b001011
	`define MFHI	6'b010000
	`define MTHI	6'b010001
	`define MFLO	6'b010010
	`define MTLO	6'b010011

	`define ADD 	6'b100000
	`define ADDU 	6'b100001
	`define	SUB 	6'b100010
	`define	SUBU 	6'b100011
	`define SLT		6'b101010
	`define SLTU	6'b101011

	`define MULT 	6'b011000
	`define MULTU	6'b011001

	`define DIV 	6'b011010
	`define DIVU 	6'b011011

	`define JR		6'b001000
	`define JALR	6'b001001

`define ANDI		6'b001100
`define	ORI			6'b001101
`define XORI		6'b001110
`define LUI			6'b001111

`define PREF		6'b110011

`define ADDI		6'b001000
`define ADDIU		6'b001001
`define SLTI		6'b001010
`define SLTIU		6'b001011

`define J			6'b000010
`define JAL			6'b000011

`define BEQ			6'b000100
`define BGTZ		6'b000111
`define BLEZ		6'b000110
`define BNE			6'b000101

`define SPECIAL2	6'b011100
	`define CLZ		6'b100000
	`define CLO		6'b100001
	`define MUL 	6'b000010
	`define MADD	6'b000000
	`define MADDU	6'b000001
	`define MSUB	6'b000100
	`define MSUBU	6'b000101

`define REGIMM 		6'b000001
	`define BLTZ    5'b00000
	`define BLTZAL 	5'b10000
	`define BGEZ 	5'b00001
	`define BGEZAL 	5'b10001

`define LB 			6'b100000
`define LBU			6'b100100
`define LH 			6'b100001
`define LHU			6'b100101
`define LW 			6'b100011
`define LWL			6'b100010
`define LWR			6'b100110
`define SB 			6'b101000
`define SH 			6'b101001
`define SW 			6'b101011
`define SWL			6'b101010
`define SWR			6'b101110

`define LL 			6'b110000
`define SC 			6'b111000

//ALU operaiton type
`define AND_OP		8'b00100100
`define OR_OP		8'b00100101
`define XOR_OP		8'b00100110
`define NOR_OP		8'b00100111
`define	SLL_OP		8'b00000000
`define SRL_OP		8'b00000010
`define SRA_OP		8'b00000011

`define MOVZ_OP		8'b00001010
`define MOVN_OP		8'b00001011
`define MFHI_OP		8'b00010000
`define MTHI_OP		8'b00010001
`define MFLO_OP		8'b00010010
`define MTLO_OP		8'b00010011

`define ADD_OP 		8'b00100000
`define ADDU_OP 	8'b00100001
`define	SUB_OP		8'b00100010
`define	SUBU_OP 	8'b00100011
`define SLT_OP		8'b00101010
`define SLTU_OP		8'b00101011

`define MULT_OP 	8'b00011000
`define MULTU_OP	8'b00011001
`define DIV_OP 		8'b00011010
`define DIVU_OP		8'b00011011

`define JR_OP 		8'b00001000
`define JALR_OP		8'b00001001

`define ADDI_OP		8'b10001000
`define ADDIU_OP	8'b10001001

`define CLZ_OP      8'b01100000
`define CLO_OP      8'b01100001
`define MUL_OP      8'b01100010
`define MADD_OP		8'b01000000
`define MADDU_OP	8'b01000001
`define MSUB_OP		8'b01000100
`define MSUBU_OP	8'b01000101

`define J_OP		8'b10000010
`define JAL_OP		8'b10000011

`define BEQ_OP		8'b10000100
`define BGTZ_OP		8'b10000111
`define BLEZ_OP		8'b10000110
`define BNE_OP		8'b10000101

`define BLTZ_OP    	8'b11000000
`define BLTZAL_OP 	8'b11010000
`define BGEZ_OP 	8'b11000001
`define BGEZAL_OP 	8'b11010001

`define LB_OP 		8'b10100000
`define LBU_OP		8'b10100100
`define LH_OP 		8'b10100001
`define LHU_OP		8'b10100101
`define LW_OP 		8'b10100011
`define LWL_OP		8'b10100010
`define LWR_OP		8'b10100110
`define SB_OP 		8'b10101000
`define SH_OP 		8'b10101001
`define SW_OP 		8'b10101011
`define SWL_OP		8'b10101010
`define SWR_OP		8'b10101110

`define LL_OP 		8'b10110000
`define SC_OP 		8'b10111000

`define NOP_OP		8'b00000000

//ALU result selection
`define RES_LOGIC		3'b001
`define RES_SHIFT		3'b010
`define RES_MOVE		3'b011
`define RES_ARITHMETIC	3'b100
`define RES_MUL			3'b101
`define RES_JUMP_BRANCH	3'b110
`define RES_LOAD_STORE	3'b111
`define RES_NOP			3'b000


/**
 * Global Marco Constants
 */
`define ZeroWord		32'h00000000
`define True			1'b1
`define False			1'b0
`define	RstEnable		1'b1
`define	RstDisable		1'b0
`define ChipEnable		1'b1
`define ChipDisable		1'b0
`define WriteEnable		1'b1
`define WriteDisable	1'b0
`define ReadEnable		1'b1
`define ReadDisable		1'b0
`define AluOpBus		7:0
`define AluSelBus		2:0
`define InstValid		1'b0
`define InstInvalid		1'b1
`define Stop 			1'b1
`define NoStop 			1'b0
`define Branch 			1'b1 
`define NotBranch		1'b0
`define InDelaySlot 	1'b1
`define NotInDelaySlot	1'b0

/**
 * ROM Constants
 */
`define InstAddrBus 		31:0		// width of ROM Address Bus
`define InstBus 			31:0 		// width of ROM data Bus
`define InstMemNum 			1023		// size of ROM
`define InstMemNumLog2		10

/**
 * RAM Constants
 */
`define DataAddrBus 		31:0		// width of ROM Address Bus
`define DataBus 			31:0 		// width of ROM data Bus
`define DataMemNum 			1023		// size of ROM
`define DataMemNumLog2		10
`define ByteWidth			7:0


/**
 * Register Constants	
 */
`define RegAddrBus			4:0
`define RegBus 				31:0
`define DoubleRegBus		63:0
`define RegWidth 			32
`define RegNum  			32
`define RegNumLog2 			5
`define NOPRegAddr 			5'b00000

/**
 * Division Constant
 */
`define DivFree          	2'b00  
`define DivByZero        	2'b01  
`define DivOn            	2'b10  
`define DivEnd           	2'b11  
`define DivResultReady   	1'b1  
`define DivResultNotReady	1'b0  
`define DivStart         	1'b1  
`define DivStop          	1'b0  
