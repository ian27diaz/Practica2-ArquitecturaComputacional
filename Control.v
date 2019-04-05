/******************************************************************
* Description
*	This is control unit for the MIPS processor. The control unit is 
*	in charge of generation of the control signals. Its only input 
*	corrponds to opcode from the instruction.
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module Control
(
	input [5:0]OP,
	
	output RegDst,
	output BranchEQ,
	output BranchNE,
	output MemRead,
	output MemtoReg,//esta señal va a la mux del write data del register file
	output MemWrite,
	output ALUSrc,
	output RegWrite,
	output Jump,
	output Jal,
  output [3:0]ALUOp

);
//Se pone el opcode
localparam R_Type = 0;
localparam I_Type_ADDI = 6'h08;
localparam I_Type_ORI =  6'h0d;
localparam I_Type_ANDI = 6'h0c;
localparam I_Type_LUI =  6'h0f;

localparam I_Type_SW =  6'h2b;
localparam I_Type_LW =  6'h23;

localparam I_Type_BEQ =  6'h04;
localparam I_Type_BNE =  6'h05;
localparam J_Type_JUMP=  6'h02;
localparam J_Type_JAL =  6'h03;

  reg [13:0] ControlValues;

always@(OP) begin
	casex(OP)
		R_Type:       ControlValues= 14'b001_001_00_00_1111; //Los ultimos tres bits son la ALUOP
		I_Type_ADDI:  ControlValues= 14'b000_101_00_00_1000;
		I_Type_ORI:	  ControlValues= 14'b000_101_00_00_1010;
		I_Type_ANDI:  ControlValues= 14'b000_101_00_00_1100;
		I_Type_LUI:	  ControlValues= 14'b000_101_00_00_0010;
		I_Type_BEQ:	  ControlValues= 14'b000_101_00_01_0100; //Modificacion BEQ
		I_Type_BNE:	  ControlValues= 14'b000_101_00_10_0111;
    I_Type_SW:	  ControlValues= 14'b000_100_01_00_0110;
		I_Type_LW:	  ControlValues= 14'b000_111_10_00_1110;
		J_Type_JUMP:  ControlValues= 14'b010_000_00_00_0000;
		J_Type_JAL:   ControlValues= 14'b111_101_00_00_0000; //Tipo R para el AluControl
											  
		default:
			ControlValues= 14'b000_000_00_00_0000;
		endcase
end	

  assign Jal = ControlValues[13];
  assign Jump = ControlValues[12];
  assign RegDst = ControlValues[11]; //Tal vez se ocupe cambiar
  assign ALUSrc = ControlValues[10];
  assign MemtoReg = ControlValues[9];
  assign RegWrite = ControlValues[8];
  assign MemRead = ControlValues[7];
  assign MemWrite = ControlValues[6];
  assign BranchNE = ControlValues[5];
  assign BranchEQ = ControlValues[4];
  assign ALUOp = ControlValues[3:0];	

endmodule
//control

