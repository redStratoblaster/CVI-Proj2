clear all, close all
%path = '3DMOT2015/test/PETS09-S2L2/img1/';
path = '3DMOT2015/test/AVG-TownCentre/img1/';
%fig1 = figure;
%background = axes('Position',[0.1 0.1 0.7 0.7]);
%set(gca,'Visible','off');
%foreground = axes('Position',[0.65 0.65 0.28 0.28]);

%fig2 = figure;
stepN = 1;
alfa = 0.01;
N=436;
imgName = sprintf('%.6d.jpg', 1);
img = imread(strcat(path, imgName));
bkg = img;
Bkg = rgb2gray(img);

pastFrame_pedestrians = {};

pastFrame_shownPedestrians = {};
 
dotArray = {};


for n = 1 : stepN : N
    imgName = sprintf('%.6d.jpg', n);
    img1 = imread(strcat(path, imgName));
    bkg = alfa * double(img1) + (1-alfa) * double(bkg);
end
%figure, imshow(uint8(bkg));
figure;

bkg2 = img;

dotArray = [];
[height, width, colors] = size(img);
heatmap = zeros(height, width);

for n = 1 : stepN : N
    clf('reset');
    imgName = sprintf('%.6d.jpg', n);
    img1 = imread(strcat(path, imgName));
    bkg2 = alfa * double(img1) + (1-alfa) * double(bkg2);
    imgR = img1(:,:,1);
    imgG = img1(:,:,2);
    imgB = img1(:,:,3);
    bkgR = bkg(:,:,1);
    bkgG = bkg(:,:,2);
    bkgB = bkg(:,:,3);  
%     
%     Y = (abs(double(bkgR) - double(imgR))+...
%          abs(double(bkgG) - double(imgG))+...
%          abs(double(bkgB) - double(imgB))) > 360;

    Y = pedestrian_detection(bkg,img1);
     
     
    Y = imopen(Y, strel('disk',1,8));
    Y = imclose(Y, strel('disk',8,8));
    Y = imclose(Y, strel('disk',4,8));
     
    %Y = imopen(Y, strel('disk',1,8));
    %Y = imopen(Y, strel('disk',1,8));
    %Y = imclose(Y, strel('disk',8,8));
    %Y = imopen(Y, strel('disk',1,4));
    %Y = imclose(Y, strel('disk',1,4));
    %Y = imdilate(Y, strel('disk',4,8));
    %Y = imdilate(Y, strel('disk',8,8));
    %subplot(2,2,3); imshow(Y);
    subplot(1,2,1); imshow(uint8(img1));
    hold on;
    
    pedestrians = area_validation(logical(Y));
    
    %disp(pedestrians);
    if(n~=1)
%       disp(finalPedestrians);
        [finalPedestrians, pedestriansToShow] = track_pedestrians(pedestrians,pastFrame_pedestrians,n);
    else
        finalPedestrians = [];
        pedestriansToShow = [];
        for j=1:1:length(pedestrians)
            %disp(finalPedestrians);
            color = [rand ,rand ,rand];
            s = struct('Area',pedestrians(j).Area,'Centroid',pedestrians(j).Centroid,'Numb',j,'BoundingBox',pedestrians(j).BoundingBox, 'Color', color);
            finalPedestrians = [finalPedestrians; s];
            pedestriansToShow = [pedestriansToShow, s];
        end;
        %disp(finalPedestrians);
    end;
    
    pastFrame_pedestrians{n} = finalPedestrians;
    pastFrame_shownPedestrians{n} = pedestriansToShow;
    
    if(~isempty(pedestriansToShow))
        for j=1:length(pedestriansToShow)
            color = [rand ,rand ,rand];
             %rectangle('Position',pedestriansToShow(j).BoundingBox,'EdgeColor',color,'linewidth',2);
           rectangle('Position',pedestriansToShow(j).BoundingBox,'EdgeColor',pedestriansToShow(j).Color,'linewidth',2);
        end;
    end;
    
% if(n == 10)
%         break;
%     end
    
    %regionprops(logical(Y), 'Area', 'BoundingBox', 'Centroid');
    %pedestrians = find([stats.Area] > 64);
%     for i = 1 : numel(pedestriansToShow)
%         %statsObj = stats(pedestrians);
%         boundingBoxI = pedestriansToShow(i).BoundingBox;
%         rectangle('Position',...
%         [boundingBoxI(1),...
%         boundingBoxI(2),...
%         boundingBoxI(3),...
%         boundingBoxI(4)],...
%         'EdgeColor',[0 1 0],...
%         'FaceColor',[0 1 0 0.2]);
%         
%         row = round(boundingBoxI(2)+boundingBoxI(4));
%         column = round(boundingBoxI(1)+boundingBoxI(3)/2);
%         
%         %dotXY = [column, row]; % column = x, row = y
%         %if 1 < column && column < width && row < height && 1 < row
%             %dotArray = vertcat(dotArray, dotXY);
%             %heatmap = 
%         %end
%     end
    
    heatmap = heatmap + Y;
    subplot(1,2,2); imshow(mat2gray(heatmap)); title('Heatmap');
                    colors = colormap(jet(N));
    
    %figure(fig1);
    %axes(handles.background);
    %imshow(uint8(img1));
    %axes(handles.foreground);
    %[r,c] = size(dotArray);


    %figure(fig2);
    
    hold on;
    drawnow;
    %BW = img;
    %pause(.2)
end

