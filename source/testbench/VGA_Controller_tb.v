`timescale 1ns/1ps

module VGA_Controller_tb();

time clk_period = 10;

reg clk = 0;
reg reset = 1;

wire pixel_value;
wire pixel_valid;
wire hsync;
wire vsync;

integer idx;
reg [4*9-1:0] ctrl_array;

integer f_pixel, f_hsync, f_vsync;

// формирование тактового сигнала
always clk = #(clk_period/2) ~clk;

// формирование сигнала сброса
initial reset = #10 0; 

// формирование сигнала управления
initial begin
	for(idx=0; idx<9; idx=idx+1)
		ctrl_array[idx*4+:4] <= 0;
end

// тестируемый модуль
VGA_Controller UUT(
	.CLK(clk),
	.RESET(reset),
	.CONTROL_ARRAY(ctrl_array),
	.PIXEL_VALUE(pixel_value),
	.PIXEL_VALID(pixel_valid),
	.HSYNC(hsync),
	.VSYNC(vsync)
);
  
// открвываем файлы для записи выходных данных
initial begin
	f_pixel = $fopen("D:/Tik_Tac_Toe/source/matlab/Pixels.txt","w");
	f_hsync = $fopen("D:/Tik_Tac_Toe/source/matlab/Hsync.txt","w");
	f_vsync = $fopen("D:/Tik_Tac_Toe/source/matlab/Vsync.txt","w");
end

// записываем выходные данные для файлы
always @(posedge clk)
	if (pixel_valid) begin
		$fwrite(f_pixel, "%b\n", pixel_value);
		$fwrite(f_hsync, "%b\n", hsync);
		$fwrite(f_vsync, "%b\n", vsync);	
	end

// заверщение моделирования
initial begin
	# 100000;
	$fclose(f_pixel); 
	$fclose(f_hsync); 
	$fclose(f_vsync);
	$finish;	
end


endmodule