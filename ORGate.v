/******************************************************************
* Description
*		This is an OR gate:
* Version:
*	1.0
* Author:
*	Dr. Psiquiatra y Rey Místico
* email:
*	
* Date:
*	01/03/2014
******************************************************************/
module ORGate
(
	input A,
	input B,
	output reg C
);

always@(*)
	C = A | B;

endmodule
//andgate