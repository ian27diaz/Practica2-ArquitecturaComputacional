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
	parameter MEMORY_DEPTH = 32
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
wire [2:0] ALUOp_wire;
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
wire [31:0]salidaDelSignExtends;
wire [31:0]salidaMuxALUsrc;
wire MemReadWire;
wire MemWriteWire;
/************ MODULOS SIN USAR: ******************/
		//ShiftLeft2


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
	.RegWrite(RegWrite_wire)
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

Multiplexer2to1
#(
	.NBits()
)
MuxALUsrcORRamData
(
	.Selector(MemtoRegWire),
	.MUX_Data0(ALUResult_wire),
	.MUX_Data1(ramDataWire),
	
	.MUX_Output(MuxALUsrcORRamDataWire)

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
	.NewPC(MUX_PC_wire),
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
MUX_ForRTypeAndIType
(
	.Selector(RegDst_wire),
	.MUX_Data0(Instruction_wire[20:16]),
	.MUX_Data1(Instruction_wire[15:11]),
	
	.MUX_Output(WriteRegister_wire)

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
	.WriteData(MuxALUsrcORRamDataWire),
	//salidas
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(Instruction_wire[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1
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
	.A(ReadData1_wire),
	.B(salidaMuxALUsrc),
	.shamt(Instruction_wire[10:6]),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire)
);

ANDGate
AND_Branch_ZeroWire
(
	.A(ORForBranch),
	.B(Zero_wire),
	.C(PCSrc)
);

ShiftLeft2
SL2_SignExtend
(
	.DataInput(InmmediateExtend_wire),
	.DataOutput(InmmediateExtend_SL2_wire)
);

Adder32bits
PC4_Immediate
(
	.Data0(PC_4_wire),
	.Data1(InmmediateExtend_SL2_wire),
	.Result(InmmediateExtendAnded_wire)
);

Multiplexer2to1
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

assign ALUResultOut = ALUResult_wire;

endmodule

