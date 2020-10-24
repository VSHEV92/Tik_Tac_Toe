`timescale 1ns/1ps

module Game_FSM(
	input                CLK,
	input                RESET,
	input      [2:0]     KEY_VALUE,
	input                KEY_VALID,
	output reg [4*9-1:0] CONTROL_ARRAY
);

reg [1:0] cross_circle_flag = 0;
reg [4*9-1:0] game_plane = 36'h000000000;
reg [3:0] current_position = 4;
reg [3:0] FSM_State = 0;

integer idx; 

// конечный автомат управления игрой
always @(posedge CLK)
begin
	if (RESET) begin 
		cross_circle_flag <= 0;
		game_plane <= 36'h000000000;
		current_position <= 4;
		FSM_State <= 0;
	end 
	else
		case(FSM_State)
			// нальное состояние, сбрасываем все регистры 
			0: begin
				cross_circle_flag <= 0;
				game_plane <= 36'h000000000;
				current_position <= 4;
				FSM_State <= 1;
			end
			
			// проверка условаия окончания игры
			1: begin
				// победа крестиков
				if(
				(game_plane[0*4+:4] == 3 && game_plane[1*4+:4] == 3 && game_plane[2*4+:4] == 3) ||
				(game_plane[3*4+:4] == 3 && game_plane[4*4+:4] == 3 && game_plane[5*4+:4] == 3) ||
				(game_plane[6*4+:4] == 3 && game_plane[7*4+:4] == 3 && game_plane[8*4+:4] == 3) ||
				(game_plane[0*4+:4] == 3 && game_plane[3*4+:4] == 3 && game_plane[6*4+:4] == 3) ||
				(game_plane[1*4+:4] == 3 && game_plane[4*4+:4] == 3 && game_plane[7*4+:4] == 3) ||
				(game_plane[2*4+:4] == 3 && game_plane[5*4+:4] == 3 && game_plane[8*4+:4] == 3) ||
				(game_plane[0*4+:4] == 3 && game_plane[4*4+:4] == 3 && game_plane[8*4+:4] == 3) ||
				(game_plane[2*4+:4] == 3 && game_plane[4*4+:4] == 3 && game_plane[6*4+:4] == 3) 
				) begin 
					FSM_State <= 8;
					cross_circle_flag <= 2;
				end
				
				// победа ноликов
				else if(
				(game_plane[0*4+:4] == 6 && game_plane[1*4+:4] == 6 && game_plane[2*4+:4] == 6) ||
				(game_plane[3*4+:4] == 6 && game_plane[4*4+:4] == 6 && game_plane[5*4+:4] == 6) ||
				(game_plane[6*4+:4] == 6 && game_plane[7*4+:4] == 6 && game_plane[8*4+:4] == 6) ||
				(game_plane[0*4+:4] == 6 && game_plane[3*4+:4] == 6 && game_plane[6*4+:4] == 6) ||
				(game_plane[1*4+:4] == 6 && game_plane[4*4+:4] == 6 && game_plane[7*4+:4] == 6) ||
				(game_plane[2*4+:4] == 6 && game_plane[5*4+:4] == 6 && game_plane[8*4+:4] == 6) ||
				(game_plane[0*4+:4] == 6 && game_plane[4*4+:4] == 6 && game_plane[8*4+:4] == 6) ||
				(game_plane[2*4+:4] == 6 && game_plane[4*4+:4] == 6 && game_plane[6*4+:4] == 6) 
				) begin
					FSM_State <= 9;
					cross_circle_flag <= 2;
				end
				
				// ничья
				else if(
				(game_plane[0*4+:4] != 0 && game_plane[1*4+:4] != 0 && game_plane[2*4+:4] != 0) &&
				(game_plane[3*4+:4] != 0 && game_plane[4*4+:4] != 0 && game_plane[5*4+:4] != 0) &&
				(game_plane[6*4+:4] != 0 && game_plane[7*4+:4] != 0 && game_plane[8*4+:4] != 0) 
				) begin
					FSM_State <= 10;
					cross_circle_flag <= 2;
				end
				
				// игра не закончена
				else
					FSM_State <= 2;
					
			end
			
			// ожидание команды с клавиатуры
			2: begin 
				if(KEY_VALID)
					case(KEY_VALUE)
						1:			 FSM_State <= 5;
						2: 		 FSM_State <= 3;
						3: 		 FSM_State <= 6;
						4:			 FSM_State <= 4;
						5:			 FSM_State <= 7;
						default : FSM_State <= 1;
					endcase
			end
			
			// стрелка вверх
			3: begin 
				if (current_position != 0 &&
					 current_position != 1 &&
					 current_position != 2)
					 current_position <= current_position - 3;
				FSM_State <= 2;	 
			end
			
			// стрелка вниз
			4: begin 
				if (current_position != 6 &&
					 current_position != 7 &&
					 current_position != 8)
					 current_position <= current_position + 3;
				FSM_State <= 2;	 
			end
			
			// стрелка влево
			5: begin 
				if (current_position != 0 &&
					 current_position != 3 &&
					 current_position != 6)
					 current_position <= current_position - 1;
				FSM_State <= 2;
			end
			
			// стрелка вправо
			6: begin
				if (current_position != 2 &&
					 current_position != 5 &&
					 current_position != 8)
					 current_position <= current_position + 1;
				FSM_State <= 2;	
			
			end
			
			// стрелка пробел
			7: begin 
				if (game_plane[current_position*4+:4] == 0)
					if (cross_circle_flag == 0) begin
						game_plane[current_position*4+:4] <= game_plane[current_position*4+:4] + 3;
						cross_circle_flag <= 1;
						FSM_State <= 1;
					end
					else begin
						game_plane[current_position*4+:4] <= game_plane[current_position*4+:4] + 6;
						cross_circle_flag <= 0;
						FSM_State <= 1;
					end
				else
					FSM_State <= 1;	
			end
			
			// крестики выиграли
			8: begin 
				for(idx=0; idx<9; idx=idx+1)
					game_plane[idx*4+:4] <= 4;
					
				// начало новой игры при нажатии на пробел	
				if (KEY_VALID && KEY_VALUE == 5)
					FSM_State <= 0;
				else
					FSM_State <= 8;
			end
			
			// нолики выиграли
			9: begin 
				for(idx=0; idx<9; idx=idx+1)
					game_plane[idx*4+:4] <= 8;
					
				// начало новой игры при нажатии на пробел	
				if (KEY_VALID && KEY_VALUE == 5)
					FSM_State <= 0;
				else
					FSM_State <= 9;
			end
			
			// ничья
			10: begin 
				for(idx=0; idx<9; idx=idx+2)
					game_plane[idx*4+:4] <= 4;
					
				for(idx=1; idx<9; idx=idx+2)
					game_plane[idx*4+:4] <= 8;	
					
				// начало новой игры при нажатии на пробел	
				if (KEY_VALID && KEY_VALUE == 5)
					FSM_State <= 0;
				else
					FSM_State <= 10;
			end
			
			// непредвиденное состояние
			default: begin
				cross_circle_flag <= 0;
				game_plane <= 36'h000000000;
				current_position <= 4;
				FSM_State <= 0;
			end
		endcase
end

// формирование управляющего сигнала
always @(posedge CLK)
	for(idx=0; idx<9; idx=idx+1)
		if(idx == current_position)
			// если сейчас ставится крестик
			if(cross_circle_flag == 0)
				CONTROL_ARRAY[idx*4+:4] <= game_plane[idx*4+:4] + 1;
			// если сейчас ставится нолик
			else if(cross_circle_flag == 1)
				CONTROL_ARRAY[idx*4+:4] <= game_plane[idx*4+:4] + 2;
			else
				CONTROL_ARRAY[idx*4+:4] <= game_plane[idx*4+:4];
		else
			// поле не выбрано
			CONTROL_ARRAY[idx*4+:4] <= game_plane[idx*4+:4];

endmodule