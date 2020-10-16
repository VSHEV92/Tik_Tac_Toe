clc
clear

bmp_file_name = 'Frame_Imag.bmp';
bmp_file_size = [4 5];
txt_file_name = 'Test_Imag.txt';

% считываем текстовый файл с пикселями
pixel_array = dlmread(txt_file_name);

% переводим строку пикселей в матрицу и пишим в файл
frame = reshape(pixel_array, bmp_file_size)';
imwrite(frame,bmp_file_name)
