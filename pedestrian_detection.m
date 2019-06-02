%imgbk -> standard image
%imgfr -> actual frame image
function binaryImage = pedestrian_detection(imgbg,imgfr)
    thr = 50;
    binaryImage = (abs(double(imgbg(:,:,1))-double(imgfr(:,:,1)))>thr) | ...
             (abs(double(imgbg(:,:,2))-double(imgfr(:,:,2)))>thr) | ...
             (abs(double(imgbg(:,:,3))-double(imgfr(:,:,3)))>thr);
%     binaryImage = imclose(imgdif, strel('disk',6));
%     binaryImage = imerode(binaryImage, strel('disk',4));
end