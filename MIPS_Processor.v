/******************************************************************
* Description
*	This is the top-level of a MIPS processor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor w-as made for computer organization class at ITESO.
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 64
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/
assign  PortOut = 0;

//******************************************************************/
//******************************************************************/
// Data types to connect modules
wire BranchNE_wire;
wire BranchEQ_wire;
wire RegDst_wire;
wire NotZeroANDBrachNE;  						/********* SIN USAR **********/
wire ZeroANDBrachEQ;								/********* SIN USAR **********/
wire ORForBranch;									
wire ALUSrc_wire;
wire RegWrite_wire;
wire Zero_wire;
wire [3:0] ALUOp_wire;
wire [3:0] ALUOperation_wire;
wire [4:0] WriteRegister_wire;//salida del primer mux
wire [31:0] MUX_PC_wire;					
wire [31:0] PC_wire;
wire [31:0] Instruction_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] InmmediateExtend_wire;
wire [31:0] ReadData2OrInmmediate_wire;
wire [31:0] ALUResult_wire;
wire [31:0] PC_4_wire;
wire [31:0] InmmediateExtendAnded_wire; 	
wire [31:0] PCtoBranch_wire;					/********* SIN USAR **********/
integer ALUStatus;
//Wires añadidos
wire PCSrc;
wire [31:0] InmmediateExtend_SL2_wire;
  
wire [31:0] ramDataWire;
wire MemtoRegWire;
wire [31:0]MuxALUsrcORRamDataWire;
wire [31:0]salidaMuxALUsrc;
wire MemReadWire;
wire MemWriteWire;

wire [31:0] jumpAddress;
wire [31:0] jumpAddressAux;
wire [31:0] Super_MUX_PC_wire;	
wire jump_wire;

wire jal_wire;
wire [4:0] WriteRegisterAux_wire;
wire [31:0] ALUResult_Or_PC_4;

wire jr_wire;

wire [31:0] Final_MUX_PC_wire;
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Control
ControlUnit
(
	.OP(Instruction_wire[31:26]),
	.RegDst(RegDst_wire),
	.BranchNE(BranchNE_wire),
	.MemRead(MemReadWire),
	.BranchEQ(BranchEQ_wire),
	.MemWrite(MemWriteWire),
	.MemtoReg(MemtoRegWire),
	.ALUOp(ALUOp_wire),
	.ALUSrc(ALUSrc_wire),	
	.RegWrite(RegWrite_wire),
	.Jump(jump_wire),
	.Jal(jal_wire)
);

//Implementación de la RAM

DataMemory 
#(	
	.DATA_WIDTH(),
	.MEMORY_DEPTH()

)
RamMemory
(
	.WriteData(ReadData2_wire),
	.Address(ALUResult_wire),
	.MemWrite(MemWriteWire),
	.MemRead(MemReadWire),
	.clk(clk),
	//salidas
	.ReadData(ramDataWire)
);


//Implementación de la RAM FIN

PC_Register
#(
 .N(32)
)
PC_Register_b
(
	.clk(clk),
	.reset(reset),
	.NewPC(Final_MUX_PC_wire),
	.PCValue(PC_wire)
);

ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROMProgramMemory
(
	.Address(PC_wire),
	.Instruction(Instruction_wire)
);

Adder32bits
PC_Puls_4
(
	.Data0(PC_wire),
	.Data1(4),
	
	.Result(PC_4_wire)
);



//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Multiplexer2to1
#(
	.NBits(5)
)
MUX_ForRTypeAndIType //MUX para elegir en que registro guardar, toma en cuenta si es I o R
(
	.Selector(RegDst_wire),
	.MUX_Data0(Instruction_wire[20:16]),
	.MUX_Data1(Instruction_wire[15:11]),
	
	.MUX_Output(WriteRegisterAux_wire)

);

//JAL
Multiplexer2to1
#(
	.NBits(5)
)
Mux_ForJalOrWriteRegisterAux //MUX para elegir el camino normal o en caso de ser jal, escribir en RA
(
	.Selector(jal_wire),
	.MUX_Data0(WriteRegisterAux_wire),
	.MUX_Data1(5'b11111),
	
	.MUX_Output(WriteRegister_wire)

);


Multiplexer2to1 //Mux de hasta la derecha del diagrama.
#(
	.NBits()
)
MuxALUsrcORRamData //
(
	.Selector(MemtoRegWire),
	.MUX_Data0(ALUResult_wire),
	.MUX_Data1(ramDataWire),
	
	.MUX_Output(MuxALUsrcORRamDataWire)

);

//Multiplexer for PCPlus4OrALUResult, PARA JAL TAMBIEN
Multiplexer2to1 //Este mux decide si mandar lo del MUX de hasta la derecha O el PC_4wire, en caso de ser jal,
#(						// para escribir en RA el PC_4_Wire
	.NBits(32)
)
Mux_ForAluResult_Or_PC_plus_4 
(
	.Selector(jal_wire),
	.MUX_Data0(MuxALUsrcORRamDataWire),
	.MUX_Data1(PC_4_wire),
	
  .MUX_Output(ALUResult_Or_PC_4) ////////////////////////////////////////////////////////////

);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(RegWrite_wire),
	.WriteRegister(WriteRegister_wire),
	.ReadRegister1(Instruction_wire[25:21]),
	.ReadRegister2(Instruction_wire[20:16]),
	.WriteData(ALUResult_Or_PC_4), //Si es JAl, sera PC_4
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(Instruction_wire[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1 //Este es el mux entre la ALU y el Register Files
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ALUSrc_wire),
	.MUX_Data0(ReadData2_wire),
	.MUX_Data1(InmmediateExtend_wire),
	
	.MUX_Output(salidaMuxALUsrc)

);


ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(ALUOp_wire),
	.ALUFunction(Instruction_wire[5:0]),
	.ALUOperation(ALUOperation_wire)
);



ALU
ArithmeticLogicUnit 
(
	.ALUOperation(ALUOperation_wire),
  .rs(ReadData2_wire),
	.A(ReadData1_wire),
	.B(salidaMuxALUsrc), //Si es immediate o lo de Register File
	.shamt(Instruction_wire[10:6]),
	.Zero(Zero_wire),
	.isJR(jr_wire), //Como JR es tipo R, aqui decido el cable jr.
	.ALUResult(ALUResult_wire)
);

/******* Logica para los cables branches ***********/
ANDGate
ZeroAndBranchEQ_AND
(
	.A(BranchEQ_wire),
	.B(Zero_wire),
	.C(ZeroANDBrachEQ)
);


ANDGate
NotZeroAndBranchNE_AND
(
	.A(BranchNE_wire),
	.B(~Zero_wire),
	.C(NotZeroANDBrachNE)
);

ORGate
ORGate_BranchNE_BranchEQ
(
	.A(ZeroANDBrachEQ),
	.B(NotZeroANDBrachNE),
	.C(PCSrc)
);
/****************************************************/

ShiftLeft2 //Este dato es el que es la direccion de branch
SL2_SignExtend
(
	.DataInput(InmmediateExtend_wire),
	.DataOutput(InmmediateExtend_SL2_wire)
);

Adder32bits //Este es el adder del PC_4_Wire y el dato inmediato<<2
PC4_Immediate
(
	.Data0(PC_4_wire),
	.Data1(InmmediateExtend_SL2_wire),
	.Result(InmmediateExtendAnded_wire)
);

Multiplexer2to1 //Este multiplexor es el que decide si mandar branchAddr o el PC_4_Wire, debe ser el primer mux
#(
	.NBits(32)
)
Mux_PC4Wire_ImmediateExtendedAndedWire
(
	.Selector(PCSrc),
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(InmmediateExtendAnded_wire),
	
	.MUX_Output(MUX_PC_wire)

);


//FOR JUMP INSTRUCTION
ShiftLeft2 //Logica para la JumpAddr
J_Address_SL2
(
	.DataInput({6'b0, Instruction_wire[25:0]}),
	.DataOutput(jumpAddressAux)
);

Adder32bits //Logica para la JumpAddr
Address_plus_PC4Wire
(
	.Data0({PC_4_wire[31:28], 28'b0}),
	.Data1(jumpAddressAux),
	.Result(jumpAddress)
);


Multiplexer2to1 //Este es el segundo mux del PC, decide si mandar lo de BranchAddr/Pc_4_wire o la jumpAddr
#(
	.NBits(32)
)
MUX_MuxPCWire_JumpAddress
(
	.Selector(jump_wire),
	.MUX_Data0(MUX_PC_wire),
	.MUX_Data1(jumpAddress - 4194304),
	
	.MUX_Output(Super_MUX_PC_wire)

);

Multiplexer2to1 //Este mux pretende escribir entre (BranchAddr/Pc_4_wire)/jumpAddr o el AluResult, que deberia de
#(					 //ser lo que esta guardado en RA, que es el PC que se almacenó en el JAL
	.NBits(32)
)
MUX_SuperMUXPC_JR_PC8
(
	.Selector(jr_wire),
	.MUX_Data0(Super_MUX_PC_wire),
	.MUX_Data1(MuxALUsrcORRamDataWire), //hardcoded, probably wrong but it works
	
	.MUX_Output(Final_MUX_PC_wire)

);

assign ALUResultOut = ALUResult_wire;

endmodule

