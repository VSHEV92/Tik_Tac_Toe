`timescale 1ns/1ps

module Tik_Tac_Toe(
	input	 clk,
	input	[15:0] address,
	output q
);
	
test_mem
#(
	.DEPTH(20),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Test_Imag.txt")
)
UUT
(
	.CLK(clk),
	.ADDR(address),
	.Q(q)
);
	
endmodule