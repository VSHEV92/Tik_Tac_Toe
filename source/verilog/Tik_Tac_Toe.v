`timescale 1ns/1ps

module Tik_Tac_Toe(
	input	 CLK,
	input	 RESET_N,
	output VGA_R,
	output VGA_G,
	output VGA_B,
	output VGA_HSYNC,
	output VGA_VSYNC
);
	
reg reset;
reg [1:0] resetn_shift;
wire [4*9-1:0] control_array;
wire pixel_value;

wire clk_40MHz;

// PLL для генерации тактового сигнала 40 МГц
PLL_40MHz PLL_Inst(
	.inclk0(CLK),
	.c0(clk_40MHz)
	);

// двойной триггер для защиты от метастабильности
always @(posedge clk_40MHz)
begin
	resetn_shift <= {resetn_shift[0], RESET_N};
	reset <= ~resetn_shift[1];
end	
	
// ----------------------------------------------------------------------	
//assign control_array = 36'h000000000; 

VGAC_Test_Source u0 (
	.source     (control_array),
	.source_clk (clk_40MHz)
);
// ----------------------------------------------------------------------	


// контроллер управления монитором 	
VGA_Controller VGA_Controller_Inst(
	.CLK(clk_40MHz),
	.RESET(reset),
	.CONTROL_ARRAY(control_array),
	.PIXEL_VALUE(pixel_value),
	.PIXEL_VALID(),
	.HSYNC(VGA_HSYNC),
	.VSYNC(VGA_VSYNC)
);

assign VGA_R = pixel_value;
assign VGA_G = pixel_value;
assign VGA_B = pixel_value;
	
endmodule