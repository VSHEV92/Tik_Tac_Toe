`timescale 1ns/1ps

module PS2_Controller(
	input  CLK,
	input  RESET,
	inout  PS2_CLK,
	inout  PS2_DATA,
	output reg [2:0] KEY_VALUE,
	output reg       KEY_VALID
);

parameter PS2_DELAY_10000 = 10000000/25; // 10 мс при тактовой частоте 40 МГц 
parameter PS2_DELAY_500 = 500000/25; // 500мкс при тактовой частоте 40 МГц
 
reg [32:0] delay_counter;
reg [1:0] command_counter;

reg [10:0] PS2_DATA_Shift_reg;
reg [3:0]  PS2_DATA_Counter;
integer i;

reg [7:0] Scan_Value;
reg       Scan_Valid;

reg [3:0] parity_bits = 3'b000;

// F0 - переключить scan set
// 03 - номер scan set
// F9 - отключить break и repeat
reg [23:0] command_value = 24'hF903F0;

reg [2:0] state_flag;	// 000 - clk в z, data в z
								// 001 - clk в 0, data в z
								// 010 - clk в 0, data в 0
								// 011 - clk в z, data в 0
								// 100 - clk в z, data - команда
								// 101 - clk в z, data - бит четности
								// 110 - clk в z, data z, прием ack
								// 111 - clk в z, data - z, прием данных
					
reg ps2_clk_oe, ps2_data_oe;
wire ps2_clk_in, ps2_data_in;

reg [2:0] p2_clk_reg; 
reg [1:0] p2_data_reg;

reg ps2_data_sync, ps2_clk_falling;

reg com_transfer_done;
					
// двунаправленные буферы для сигнала тактов и данных		
IO_BUF_iobuf_bidir_30p IO_BUF_PS2_CLK
( 
	.datain(1'b0),
	.dataio(PS2_CLK),
	.dataout(ps2_clk_in),
	.oe(ps2_clk_oe)
) ;

IO_BUF_iobuf_bidir_30p IO_BUF_PS2_DATA
( 
	.datain(1'b0),
	.dataio(PS2_DATA),
	.dataout(ps2_data_in),
	.oe(ps2_data_oe)
) ;

// регистры сдвига для защиты от метастабильности
always @(posedge CLK)
begin
	p2_clk_reg <= {p2_clk_reg[1:0], PS2_CLK};
	ps2_clk_falling <= p2_clk_reg[2] & ~p2_clk_reg[1];	
	
	p2_data_reg <= {p2_data_reg[0], PS2_DATA};
	ps2_data_sync <= p2_data_reg[1];
end

// ------------------------------------------------------------------------
// загрузка команда управления 
always @(posedge CLK)
begin
	if(RESET) begin
		state_flag <= 3'b000;
		ps2_clk_oe <= 1'b0;
		ps2_data_oe <= 1'b0;
		delay_counter <= 0;
		command_counter <= 0;
		com_transfer_done <= 1'b0;
	end	
	else
		case (state_flag)
			// начальное состояние, выходы в Z, задержка после включение платы
			3'b000 : begin 
				delay_counter <= delay_counter + 1;
				
				if (delay_counter == PS2_DELAY_10000) begin 
					delay_counter <= 0;
					state_flag <= 3'b001;
				end
			end
			
			// дергаем clk в ноль и запрещаем передачу
			3'b001 : begin
				ps2_clk_oe <= 1'b1;
				delay_counter <= delay_counter + 1;
				
				if (delay_counter == PS2_DELAY_500) begin 
					delay_counter <= 0;
					state_flag <= 3'b010;
				end
			end
			
			// дергаем data в ноль, указывая, что сейчас будет передача
			3'b010 : begin
				ps2_data_oe <= 1'b1;
				delay_counter <= delay_counter + 1;
				
				if (delay_counter == PS2_DELAY_500) begin 
					delay_counter <= 0;
					state_flag <= 3'b011;
				end
			end
			
			// отпускаем тактовый сигнал и ждем его спада
			3'b011 : begin
				ps2_clk_oe <= 1'b0;
				
				if (ps2_clk_falling)
					state_flag <= 3'b100;
			end
			
			// выдаем биты команда на выход
			3'b100 : begin
				ps2_data_oe <= ~command_value[command_counter*8+delay_counter];
				if (ps2_clk_falling) begin
					delay_counter <= delay_counter + 1;
					if (delay_counter == 7) begin
						state_flag <= 3'b101;
						delay_counter <= 0;
					end
				end
			end
			
			// выдаем бит четности
			3'b101 : begin
				ps2_data_oe <= 1'b0;
				if (ps2_clk_falling) 
					state_flag <= 3'b110;			
			end		
		
			// принимаем бит подтверждения
			3'b110 : begin
				ps2_data_oe <= 1'b0;
				if (ps2_clk_falling) begin  
					command_counter <= command_counter + 1;
					
					if (command_counter == 2)
						state_flag <= 3'b111;
					else
						state_flag <= 3'b000;
						
				end			
			end	
			
			// конченое состояние, остаемся в нем постоянно
			3'b111 : begin				
					state_flag <= 3'b111;
					com_transfer_done <= 1'b1;
			end
			
			// при нештатно ситуации
			default : begin
				ps2_clk_oe <= 1'b0;
				ps2_data_oe <= 1'b0;
				state_flag <= 3'b000;
				com_transfer_done <= 1'b0;
			end
			
		endcase
		
end


// ---------------------------------------------------------------------------
// прием данных от клавиатуры

// регистр сдвига и счетчик для защелкивания данных 
always @(posedge CLK) 
begin
   Scan_Valid <= 0;
   if (RESET) begin
		PS2_DATA_Shift_reg <= 0;
		PS2_DATA_Counter <= 0;
	end
	else if(ps2_clk_falling & com_transfer_done) begin
		PS2_DATA_Shift_reg[10] <= ps2_data_sync;
		
		for(i=0; i<10; i= i+1)
			PS2_DATA_Shift_reg[i] <= PS2_DATA_Shift_reg[i+1];
		
		PS2_DATA_Counter <= PS2_DATA_Counter + 1;
		
		if (PS2_DATA_Counter == 10) begin
			PS2_DATA_Counter <= 0;
			Scan_Value <= PS2_DATA_Shift_reg[9:2];
			Scan_Valid <= 1;
		end
			
	end
end


// кодирование перед выдачей данных
always @(posedge CLK) 
begin
   KEY_VALID <= 0;
	if (RESET) begin
		KEY_VALUE <= 3'b000;
		KEY_VALID <= 0;
	end else	if(Scan_Valid) begin
	   // меняем флаг нажатия, чтобы не защелкнуть данные при отпускании клавиши 
		case (Scan_Value)
			8'h61: begin  // стрелка влево
				KEY_VALUE <= 3'b001;
				KEY_VALID <= 1;
			end
			8'h63: begin  // стрелка вверх 
				KEY_VALUE <= 3'b010;
				KEY_VALID <= 1;
			end
			8'h6A: begin  // стрелка вправо
				KEY_VALUE <= 3'b011;
				KEY_VALID <= 1;  
			end
			8'h60: begin  // стрелка вниз
				KEY_VALUE <= 3'b100;
				KEY_VALID <= 1;
			end
			8'h29: begin  // пробел 
				KEY_VALUE <= 3'b101;
				KEY_VALID <= 1;
			end
			default: begin
				KEY_VALUE <= 3'b000;
				KEY_VALID <= 0;
			end
		endcase
	end
end

endmodule