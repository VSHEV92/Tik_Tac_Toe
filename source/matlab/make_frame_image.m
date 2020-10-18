clc
clear

% имена файлов
png_file_name = 'Frame_Imag.png';
pixel_file_name = 'Pixels.txt';
hsync_file_name = 'Hsync.txt';
vsync_file_name = 'Vsync.txt';

H_ACTIVE = 800;
H_FRONT = 40;
H_SYNC = 128;
H_BACK = 88;

V_ACTIVE = 600;
V_FRONT = 1;
V_SYNC = 4;
V_BACK = 23;

% размеры кадра
H_Size = H_ACTIVE+H_FRONT+H_SYNC+H_BACK;
V_Size = V_ACTIVE+V_FRONT+V_SYNC+V_BACK;
Frame_Size = H_Size*V_Size;

% считываем текстовые файлы
pixel_array = dlmread(pixel_file_name);
hsync_array = dlmread(hsync_file_name);
vsync_array = dlmread(vsync_file_name);

% число принятых кадров
Frame_Num = floor(length(pixel_array)/Frame_Size);

% переформатирование кадра
frame_format = [H_Size Frame_Num*V_Size];

pixel_frame = reshape(pixel_array(1:Frame_Size*Frame_Num), frame_format)';
hsync_frame = reshape(hsync_array(1:Frame_Size*Frame_Num), frame_format)';
vsync_frame = reshape(vsync_array(1:Frame_Size*Frame_Num), frame_format)';

frame = zeros(Frame_Num*V_Size, H_Size, 3);
frame(:,:,1) = pixel_frame;
frame(:,:,2) = hsync_frame;
frame(:,:,3) = vsync_frame;

% запись результата в файл
imwrite(frame.*255, png_file_name)
