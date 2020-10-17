`timescale 1ns/1ps

module VGA_Controller(
	input  CLK,
	input  RESET,
	input  [4*9-1:0] CONTROL_ARRAY,
	output reg PIXEL_VALUE,
	output HSYNC,
	output VSYNC
);

//parameter H_ACTIVE = 800;
//parameter H_FRONT = 40;
//parameter H_SYNC = 128;
//parameter H_BACK = 88;
//
//parameter V_ACTIVE = 600;
//parameter V_FRONT = 1;
//parameter V_SYNC = 4;
//parameter V_BACK = 23;

parameter H_ACTIVE = 4*3;
parameter H_FRONT = 1;
parameter H_SYNC = 2;
parameter H_BACK = 1;

parameter V_ACTIVE = 5*3;
parameter V_FRONT = 1;
parameter V_SYNC = 3;
parameter V_BACK = 2;

parameter PICT_WIDTH = 4;
parameter PICT_WIDTH_BLACK = 1;
parameter PICT_HIGHT = 5;

integer idx;
reg [9:0] V_Counter;
reg [9:0] H_Counter;
reg [3:0] ctrl_array[8:0];
reg [3:0] ctrl_vector;

reg [15:0] MEM_ADDR_H;
reg [15:0] MEM_ADDR_V;
reg [15:0] MEM_ADDR;

wire cross_mem_val;
wire zero_mem_val;

// защелкивание сигнала управления только в начале кадра
always @(posedge CLK)
	if (V_Counter == 0 && H_Counter == 0)
		for(idx=0; idx<9; idx=idx+1)
			ctrl_array[idx] <= CONTROL_ARRAY[idx*4+:4];
	
// счетчики координат пикселей
always @(posedge CLK)
	if(RESET) begin
		V_Counter <= 0;
		H_Counter <= 0;
	end else begin
		H_Counter <= H_Counter + 1;
		// обнуление счетчика столбцов
		if(H_Counter == H_ACTIVE+H_FRONT+H_SYNC+H_BACK-1) begin
			H_Counter <= 0;
			V_Counter <= V_Counter + 1;
			// обнуление счетчика строк
			if(V_Counter == V_ACTIVE+V_FRONT+V_SYNC+V_BACK-1)
				V_Counter <= 0;	
		end
	end

// пересчет счетчиков координат в адрес для памяти
always @(*) begin
	MEM_ADDR_V = V_Counter % PICT_HIGHT; 
	MEM_ADDR_H = H_Counter % PICT_WIDTH;
	MEM_ADDR = MEM_ADDR_V*PICT_WIDTH + MEM_ADDR_H;
end

// выбор вектора управления по счетчикам пикселей
always @(posedge CLK) begin
	// первая строка квадратов
	if(V_Counter < PICT_HIGHT)
		if(H_Counter < PICT_WIDTH)
			ctrl_vector <= ctrl_array[0];
		else if(H_Counter < 2*PICT_WIDTH)
			ctrl_vector <= ctrl_array[1];
		else if(H_Counter < 3*PICT_WIDTH-PICT_WIDTH_BLACK)
			ctrl_vector <= ctrl_array[2];
		else
			ctrl_vector <= 4'hF;
		
	// вторая строка квадратов
	else if(V_Counter < 2*PICT_HIGHT)
		if(H_Counter < PICT_WIDTH)
			ctrl_vector <= ctrl_array[3];
		else if(H_Counter < 2*PICT_WIDTH)
			ctrl_vector <= ctrl_array[4];
		else if(H_Counter < 3*PICT_WIDTH-PICT_WIDTH_BLACK)
			ctrl_vector <= ctrl_array[5];
		else
			ctrl_vector <= 4'hF;
		
	// третья строка квадратов
	else
		if(H_Counter < PICT_WIDTH)
			ctrl_vector <= ctrl_array[6];
		else if(H_Counter < 2*PICT_WIDTH)
			ctrl_vector <= ctrl_array[7];
		else if(H_Counter < 3*PICT_WIDTH-PICT_WIDTH_BLACK)
			ctrl_vector <= ctrl_array[8];
		else
			ctrl_vector <= 4'hF;	
end


// выбор памяти и выдача пикселя на выход
always @(posedge CLK) begin
	case(ctrl_vector)
		0:        PIXEL_VALUE <= cross_mem_val;
		default:  PIXEL_VALUE <= 0;
	endcase
end

	
// блоки памяти с изображениями
test_mem 
#(
	.DEPTH(20),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Test_Imag.txt")
)
cross_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(cross_mem_val)
);	

endmodule