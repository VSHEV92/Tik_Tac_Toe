clc
clear

bmp_file_name = 'Empty_Cross.bmp';
txt_file_name = 'Empty_Cross.txt';

% считываем файл и вычисляем его размер
image = imread(bmp_file_name, 'bmp');
imsize = size(image);

% выводим пиксели в строку и пишим в файл
pixel_array = zeros(imsize(1)*imsize(2),1);
for row = 1:imsize(1)
    for col = 1:imsize(2)
       pixel_array((row-1)*imsize(2) + col) = image(row,col); 
    end
end
dlmwrite(txt_file_name,pixel_array);