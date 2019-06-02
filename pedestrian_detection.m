%imgbk -> standard image
%imgfr -> actual frame images
function [lb num] = pedestrian_detection(imgbg,imgfr)
    thr = 30;
    
    imgdif = (abs(double(imgbg(:,:,1))-double(imgfr(:,:,1)))>thr) | ...
             (abs(double(imgbg(:,:,2))-double(imgfr(:,:,2)))>thr) | ...
             (abs(double(imgbg(:,:,3))-double(imgfr(:,:,3)))>thr); 
         
     binaryImage = imerode(imgdif, strel('disk',4));
     binaryImage = imdilate(binaryImage, strel('disk',2));
     binaryImage = imerode(imgdif, strel('disk',3));
    [lb num] = bwlabel(binaryImage);
end