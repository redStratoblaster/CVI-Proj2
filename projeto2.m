clear all, close all;

path = '3DMOT2015/test/AVG-TownCentre/img1/';
N = 450;
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


fid = fopen('det.txt','rt');
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
bkg=imread(sprintf(strcat(path,'%.6d.jpg'), i));
for i = 1:N
    img = imread(sprintf(strcat(path,'%.6d.jpg'), i));
    bkg = alfa * double(img) + (1-alfa) * double(bkg);
end

imgName = sprintf('%.6d.jpg', 1);
img = imread(strcat(path, imgName));

for i = 1:N
    clf('reset');
    img = imread(sprintf(strcat(path,'%.6d.jpg'), i));
    imshow(img);
    
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
        truthMatrix(1,:) = [];
        firstLine = truthMatrix(1,:);
    end
    
    %plot the detected regions
    imgR = img(:,:,1);
    imgG = img(:,:,2);
    imgB = img(:,:,3);
    bkgR = bkg(:,:,1);
    bkgG = bkg(:,:,2);
    bkgB = bkg(:,:,3);
    Y = (abs(double(bkgR) - double(imgR))+...
         abs(double(bkgG) - double(imgG))+...
         abs(double(bkgB) - double(imgB))) > 100;
    Y = imopen(Y, strel('disk',1,8));
    Y = imclose(Y, strel('disk',8,8));
    Y = imclose(Y, strel('disk',4,8));
    stats = regionprops(logical(Y), 'Area', 'BoundingBox');
    objIndex = find([stats.Area] > 1000);
    for n = 1 : numel(objIndex)
        statsObj = stats(objIndex);
        boundingBoxI = statsObj(n).BoundingBox;
        rectangle('Position',...
        [boundingBoxI(1),...
        boundingBoxI(2),...
        boundingBoxI(3),...
        boundingBoxI(4)],...
        'EdgeColor',[0 1 0],...
        'FaceColor',[0 1 0 0.2]);
    end
    
    drawnow;
    pause(0.01);
    hold on
end
%you have now loaded all of the data.