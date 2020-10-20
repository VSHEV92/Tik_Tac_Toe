`timescale 1ns/1ps

module PS2_Controller_tb();

time clk_period = 25;

reg clk = 0;
reg reset = 1;

wire ps2_clk = 1'bZ;
wire ps2_data = 1'bZ;

reg ps2_clk_oe = 1'b0;
reg ps2_data_oe = 1'b0;

// формирование тактового сигнала
always clk = #(clk_period/2) ~clk;

// формирование сигнала сброса
initial reset = #100 0; 

pullup(ps2_clk);
pullup(ps2_data);

// тестируемый модуль
PS2_Controller UUT(
	.CLK(clk),
	.RESET(reset),
	.PS2_CLK(ps2_clk),
	.PS2_DATA(ps2_data),
	.KEY_VALUE(),
	.KEY_VALID()
);

bufif1(ps2_clk, 1'b0, ps2_clk_oe);

initial begin
	#50000;
	@(posedge ps2_clk)
	#5000;
	ps2_clk_oe = 1'b1;
	
	repeat(10) begin
		#5000;
		ps2_clk_oe = 1'b0;
		#5000;
		ps2_clk_oe = 1'b1;
	end
	#5000;
	ps2_clk_oe = 1'b0;
end

initial begin
	# 3000000;
	$stop;
end

endmodule