/******************************************************************
* Description
*	This is the control unit for the ALU. It receves an signal called 
*	ALUOp from the control unit and a signal called ALUFunction from
*	the intrctuion field named function.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module ALUControl
(
  input [3:0] ALUOp,
	input [5:0] ALUFunction,
	output [3:0] ALUOperation
);

localparam R_Type_JR		 = 10'b1111_001000;
localparam R_Type_AND    = 10'b1111_100100;
localparam R_Type_OR     = 10'b1111_100101;
localparam R_Type_NOR    = 10'b1111_100111; //ADD y addi con el mismo alucontrolvalues
localparam R_Type_ADD    = 10'b1111_100000;
localparam R_Type_SLL	 = 10'b1111_000000;
localparam R_Type_SRL	 = 10'b1111_000010;
localparam R_Type_SUB	 = 10'b1111_100010;

localparam I_Type_ADDI   = 10'b1000_xxxxxx; //Los primeros tres bits coinciden con Control.v
localparam I_Type_ORI    = 10'b1010_xxxxxx; //En los tipos I, no importa func por lo tanto las x
localparam I_Type_ANDI   = 10'b1100_xxxxxx;
localparam I_Type_LUI	 = 10'b0010_xxxxxx; //Las de tipo i no tienen el capmo de func, por lo tanto no importa.
localparam I_Type_BEQ	 = 10'b0100_xxxxxx;
localparam I_Type_BNE	 = 10'b0111_xxxxxx;
localparam I_Type_SW		 = 10'b0110_xxxxxx;
localparam I_Type_LW		 = 10'b1110_xxxxxx;


reg [3:0] ALUControlValues;
  wire [10:0] Selector;

assign Selector = {ALUOp, ALUFunction};

always@(Selector)begin
	casex(Selector)
		R_Type_AND:    ALUControlValues = 4'b0000;
		I_Type_ANDI:	ALUControlValues = 4'b0000;
		R_Type_OR: 		ALUControlValues = 4'b0001;
		I_Type_ORI:		ALUControlValues = 4'b0001;
		R_Type_NOR:		ALUControlValues = 4'b0010;
		R_Type_ADD:		ALUControlValues = 4'b0011;
		I_Type_ADDI:	ALUControlValues = 4'b0011;
		R_Type_SUB:		ALUControlValues = 4'b0100;
		R_Type_SLL: 	ALUControlValues = 4'b0101;
		R_Type_SRL:		ALUControlValues = 4'b0110;
		I_Type_LUI:		ALUControlValues = 4'b0111;

		I_Type_SW:		ALUControlValues = 4'b0011;
		I_Type_LW:		ALUControlValues = 4'b0011;
    
		I_Type_BEQ:		ALUControlValues = 4'b1000;
		I_Type_BNE:		ALUControlValues = 4'b1000;
		R_Type_JR: 		ALUControlValues = 4'b1001;
		default: ALUControlValues = 4'b1010;

	endcase
end


assign ALUOperation = ALUControlValues;

endmodule
//alucontrol