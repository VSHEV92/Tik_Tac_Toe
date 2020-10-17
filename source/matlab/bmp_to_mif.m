clc
clear

bmp_file_name = 'Test_Imag.bmp';
mif_file_name = 'Test_Imag.mif';

% считываем файл и вычисляем его размер
image = imread(bmp_file_name, 'bmp');
imsize = size(image);

% выводим пиксели в строку
pixel_array = zeros(imsize(1)*imsize(2),1);
for row = 1:imsize(1)
    for col = 1:imsize(2)
       pixel_array((row-1)*imsize(2) + col) = image(row,col); 
    end
end

% пишим данные в файл
dlmwrite(mif_file_name, strcat('DEPTH=', num2str(imsize(1)*imsize(2)), ';'), 'delimiter', '');
dlmwrite(mif_file_name, strcat('WIDTH=1;'), 'delimiter', '', '-append');
dlmwrite(mif_file_name, strcat('ADDRESS_RADIX=DEC;'), 'delimiter', '', '-append');
dlmwrite(mif_file_name, strcat('DATA_RADIX=DEC;'), 'delimiter', '', '-append');
dlmwrite(mif_file_name, strcat('CONTENT'), 'delimiter', '', '-append');
dlmwrite(mif_file_name, strcat('BEGIN'), 'delimiter', '', '-append');

for idx = 0:imsize(1)*imsize(2)-1
    dlmwrite(mif_file_name, strcat(num2str(idx), ':', num2str(pixel_array(idx+1)), ';'), 'delimiter', '', '-append');
end

dlmwrite(mif_file_name, strcat('END;'), 'delimiter', '', '-append');

