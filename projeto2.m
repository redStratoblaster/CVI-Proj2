clear all, close all;

path = '3DMOT2015/test/PETS09-S2L2/img1/';
%path = '3DMOT2015/test/AVG-TownCentre/img1/';
imgName = sprintf('%.6d.jpg', 1);
N = 436;
truthMatrix = [];
stepN = 1;
alfa = 0.01;


% Ground truth data format
% 1 - Frame number - Indicate at which frame the object is present
% 2 - Identity number - Each pedestrian trajectory is identified by a unique ID (?1 for detections)
% 3 - Bounding box left - Coordinate of the top-left corner of the pedestrian bounding box
% 4 - Bounding box top - Coordinate of the top-left corner of the pedestrian bounding box
% 5 - Bounding box width - Width in pixels of the pedestrian bounding box
% 6 - Bounding box height - Height in pixels of the pedestrian bounding box
% 7 - Confidence score - Indicates  how  confident  the  detector  is  that  this  instance  is  a  pedestrian.  
%     For  the  ground  truth  and results, it acts as a flag whether the entry is to be considered.
% 8 - x - 3D x position of the pedestrian in real-world coordinates (?1 if not available)
% 9 - y - 3D y position of the pedestrian in real-world coordinates (?1 if not available)
%10 - z - 3D z position of the pedestrian in real-world coordinates (?1 if not available)

gtFile = '../det/det.txt';
filename = strcat(path, gtFile);
fid = fopen(filename,'rt');
while true
  thisline = fgetl(fid);
  if ~ischar(thisline); break; end  %end of file
  parsedLine = strsplit(thisline,',');
  parsedArray = [];
  for i = 1:10
      cell = parsedLine(i);
      str = cell{1};
      value = str2num(str);
      parsedArray = [parsedArray value];
  end
  truthMatrix = vertcat(truthMatrix, parsedArray);
end
  fclose(fid);

%calculate background
bkg = imread(strcat(path, imgName));
for i = 1:N
    img = imread(sprintf(strcat(path,'%.6d.jpg'), i));
    bkg = alfa * double(img) + (1-alfa) * double(bkg);
end


Img = imread(strcat(path, imgName));
[height, width, colors] = size(img);
heatmap = zeros(height, width);
dotArray = [];
gtDotArray = [];
pastFrame_pedestrians = {};
pastFrame_shownPedestrians = {};

for i = 1:N
    clf('reset');
    img = imread(sprintf(strcat(path,'%.6d.jpg'), i));
    imshow(img);
    hold on;
    
    %plot the ground truth
    firstLine = truthMatrix(1,:);
    while(firstLine(1) == i)
        box1 = rectangle('Position',...
              [firstLine(3),...
               firstLine(4),...
               firstLine(5),...
               firstLine(6)],...
              'EdgeColor',[1 1 0],...
              'FaceColor',[1 1 0 0.05]);
          
        row = round(firstLine(4)+firstLine(6));
        column = round(firstLine(3)+firstLine(5)/2);
        
        dotXY = [column, row]; % column = x, row = y
        if 1 < column && column < width && row < height && 1 < row
            gtDotArray = vertcat(gtDotArray, dotXY);
        end
        
        truthMatrix(1,:) = [];
        [r, c] = size(truthMatrix);
        if r ~= 0
            firstLine = truthMatrix(1,:);
        else
            break;
        end;
    end
    
    %plot the detected regions
    imgR = img(:,:,1);
    imgG = img(:,:,2);
    imgB = img(:,:,3);
    bkgR = bkg(:,:,1);
    bkgG = bkg(:,:,2);
    bkgB = bkg(:,:,3);
    Y = pedestrian_detection(bkg,img);
    Y = imopen(Y, strel('disk',1,8));
    Y = imclose(Y, strel('disk',8,8));
    Y = imclose(Y, strel('disk',4,8));
    
    
    pedestrians = area_validation(logical(Y));
    
    if(i~=1)
        [finalPedestrians, pedestriansToShow] = track_pedestrians(pedestrians,pastFrame_pedestrians,i);
    else
        finalPedestrians = [];
        pedestriansToShow = [];
        for j=1:1:length(pedestrians)
            color = [rand ,rand ,rand];
            s = struct('Area',pedestrians(j).Area,'Centroid',pedestrians(j).Centroid,'Numb',j,'BoundingBox',pedestrians(j).BoundingBox, 'Color', color);
            finalPedestrians = [finalPedestrians; s];
            pedestriansToShow = [pedestriansToShow, s];
        end;
    end;
    
    pastFrame_pedestrians{i} = finalPedestrians;
    pastFrame_shownPedestrians{i} = pedestriansToShow;
    
    if(~isempty(pedestriansToShow))
        for j=1:length(pedestriansToShow)
            BB = pedestriansToShow(j).BoundingBox;
            color = [rand ,rand ,rand];
            rectangle('Position',BB,'EdgeColor',pedestriansToShow(j).Color,'linewidth',2);
        
            row = round(BB(2)+BB(4));
            column = round(BB(1)+BB(3)/2);

            dotXY = [column, row]; % column = x, row = y
            if 1 < column && column < width && row < height && 1 < row
                dotArray = vertcat(dotArray, dotXY);
            end
        end
    end
    
    heatmap = heatmap + Y;
    
    drawnow;
    pause(0.01);
    
end

figure, imshow(Img);
hold on;
[r,c] = size(gtDotArray);
for i = 1 : r
    line = gtDotArray(i,:);
    plot(line(1),line(2),'.','Color','yellow','MarkerSize', 10);
end

figure, imshow(Img);
hold on;
[r,c] = size(dotArray);
for i = 1 : r
    line = dotArray(i,:);
    plot(line(1),line(2),'g.','MarkerSize', 10);
end


figure, imshow(mat2gray(heatmap)); 
title('Heatmap');
colors = colormap(jet(N));
%you have now loaded all of the data.