clc
clear

bmp_file_name = 'Test_Imag.bmp';
txt_file_name = 'Test_Imag.txt';

% ��������� ���� � ��������� ��� ������
image = imread(bmp_file_name, 'bmp');
imsize = size(image);

% ������� ������� � ������ � ����� � ����
pixel_array = zeros(imsize(1)*imsize(2),1);
for row = 1:imsize(1)
    for col = 1:imsize(2)
       pixel_array((row-1)*imsize(2) + col) = image(row,col); 
    end
end
dlmwrite(txt_file_name,pixel_array);