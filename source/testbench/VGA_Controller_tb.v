`timescale 1ns/1ps

module VGA_Controller_tb();

// константы для моделирования
time clk_period = 10;

reg clk = 0;
reg reset;

wire pixel_value;

always
	clk = #(clk_period/2) ~clk;

VGA_Controller UUT(
	.CLK(clk),
	.RESET(reset),
	.CONTROL_ARRAY(0),
	.PIXEL_VALUE(),
	.HSYNC(),
	.VSYNC()
);
 
//Tik_Tac_Toe UUT(
//	.clk(clk),
//	.address(address),
//	.q(q)
//); 
 
initial begin
	reset = 1; 
	#10;
	reset = 0; 
	#1000;
	$stop;
end

endmodule