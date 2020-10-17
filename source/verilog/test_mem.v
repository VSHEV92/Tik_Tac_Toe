`timescale 1ns/1ps

module test_mem
#(
	parameter DEPTH,
	parameter FILE_NAME
)
(
	input        CLK,
	input [15:0] ADDR,
	output reg   Q
);

reg MEM_VALUE[65535:0];
integer idx, data_file;

// считываем содержимое файла в память
initial begin
	$readmemb(FILE_NAME, MEM_VALUE);
end

// считывание из памяти по заданному адресу
always @(posedge CLK)
	Q <= MEM_VALUE[ADDR];

endmodule