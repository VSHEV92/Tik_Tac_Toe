`timescale 1ns/1ps

module VGA_Controller(
	input  CLK,
	input  RESET,
	input  [4*9-1:0] CONTROL_ARRAY,
	output reg PIXEL_VALUE,
	output     PIXEL_VALID,
	output reg HSYNC,
	output reg VSYNC
);

parameter H_ACTIVE = 800;
parameter H_FRONT = 40;
parameter H_SYNC = 128;
parameter H_BACK = 88;

parameter V_ACTIVE = 600;
parameter V_FRONT = 1;
parameter V_SYNC = 4;
parameter V_BACK = 23;

parameter PICT_WIDTH = 280;
parameter PICT_WIDTH_BLACK = 40;
parameter PICT_HIGHT = 215;
parameter PICT_HIGHT_BLACK = 45;

integer idx;
reg [12:0] V_Counter;
reg [12:0] H_Counter;
reg [3:0] ctrl_array[8:0];
reg [3:0] ctrl_vector;

reg [15:0] MEM_ADDR_H;
reg [15:0] MEM_ADDR_V;
reg [15:0] MEM_ADDR;

reg [2:0] pixel_valid_reg;

wire cross_mem_val;
wire cross_circle_mem_val;
wire cross_cross_mem_val;

wire circle_mem_val;
wire circle_circle_mem_val;
wire circle_cross_mem_val;

wire empty_mem_val;
wire empty_circle_mem_val;
wire empty_cross_mem_val;


reg Vsync_delay;

// формирование сигнала валидности данных
always @(posedge CLK)
	if(RESET)
		pixel_valid_reg <= 1;
	else
		pixel_valid_reg[2:1] <= pixel_valid_reg[1:0];

assign PIXEL_VALID = pixel_valid_reg[2]; 
		
	
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
	else if(V_Counter < 3*PICT_HIGHT-PICT_HIGHT_BLACK)
		if(H_Counter < PICT_WIDTH)
			ctrl_vector <= ctrl_array[6];
		else if(H_Counter < 2*PICT_WIDTH)
			ctrl_vector <= ctrl_array[7];
		else if(H_Counter < 3*PICT_WIDTH-PICT_WIDTH_BLACK)
			ctrl_vector <= ctrl_array[8];
		else
			ctrl_vector <= 4'hF;
	else
		ctrl_vector <= 4'hF;	
end


// выбор памяти и выдача пикселя на выход
always @(posedge CLK) begin
	case(ctrl_vector)
		0:        PIXEL_VALUE <= empty_mem_val;
		1:        PIXEL_VALUE <= empty_cross_mem_val;
		2:        PIXEL_VALUE <= empty_circle_mem_val;
		3:        PIXEL_VALUE <= cross_mem_val;
		4:        PIXEL_VALUE <= cross_cross_mem_val;
		5:        PIXEL_VALUE <= cross_circle_mem_val;
		6:        PIXEL_VALUE <= circle_mem_val;
		7:        PIXEL_VALUE <= circle_cross_mem_val;
		8:        PIXEL_VALUE <= circle_circle_mem_val;
		default:  PIXEL_VALUE <= 0;
	endcase
end

//	формироание сигнала строчной синхронизации
always @(posedge CLK)
	if (H_Counter > H_ACTIVE+H_FRONT && H_Counter<=H_ACTIVE+H_FRONT+H_SYNC)
		HSYNC <= 0;
	else	
		HSYNC <= 1;

//	формироание сигнала кадровой синхронизации
always @(posedge CLK) begin
	if (V_Counter > V_ACTIVE+V_FRONT-1 && V_Counter<=V_ACTIVE+V_FRONT+V_SYNC-1)
		Vsync_delay <= 0;
	else	
		Vsync_delay <= 1;
	VSYNC <= Vsync_delay;
end	
		
// блоки памяти с изображениями
test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Circle.txt")
)
circle_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(circle_mem_val)
);	

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Circle_Circle.txt")
)
circle_circle_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(circle_circle_mem_val)
);	

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Circle_Cross.txt")
)
circle_cross_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(circle_cross_mem_val)
);

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Cross.txt")
)
cross_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(cross_mem_val)
);	

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Cross_Cross.txt")
)
cross_cross_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(cross_cross_mem_val)
);	

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Cross_Circle.txt")
)
cross_circle_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(cross_circle_mem_val)
);	

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Empty.txt")
)
empty_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(empty_mem_val)
);	

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Empty_Circle.txt")
)
empty_circle_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(empty_circle_mem_val)
);	

test_mem 
#(
	.DEPTH(64900),
	.FILE_NAME("D:/Tik_Tac_Toe/source/matlab/Empty_Cross.txt")
)
empty_cross_mem
(
	.CLK(CLK),
	.ADDR(MEM_ADDR),
	.Q(empty_cross_mem_val)
);		
endmodule