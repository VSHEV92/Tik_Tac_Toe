clc
clear

bmp_file_name = 'Frame_Imag.bmp';
bmp_file_size = [4 5];
txt_file_name = 'Test_Imag.txt';

% ��������� ��������� ���� � ���������
pixel_array = dlmread(txt_file_name);

% ��������� ������ �������� � ������� � ����� � ����
frame = reshape(pixel_array, bmp_file_size)';
imwrite(frame,bmp_file_name)
