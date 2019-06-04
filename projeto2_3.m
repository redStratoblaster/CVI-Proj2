clear all, close all
path = '3DMOT2015/test/PETS09-S2L2/img1/';

stepN = 1;
alfa = 0.01;
N=436;
imgName = sprintf('%.6d.jpg', 1);
img = imread(strcat(path, imgName));
bkg = img;
truthMatrix = [];
pastFrame_pedestrians = {};
pastFrame_shownPedestrians = {};
metrics = [];

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


for n = 1 : stepN : N
    imgName = sprintf('%.6d.jpg', n);
    img1 = imread(strcat(path, imgName));
    bkg = alfa * double(img1) + (1-alfa) * double(bkg);
end



for n = 1 : stepN : N
    clf('reset');
    imgName = sprintf('%.6d.jpg', n);
    img1 = imread(strcat(path, imgName));
   
    %Y = pedestrian_detection(bkg,img1);
    
    imgR = img1(:,:,1);
    imgG = img1(:,:,2);
    imgB = img1(:,:,3);
    bkgR = bkg(:,:,1);
    bkgG = bkg(:,:,2);
    bkgB = bkg(:,:,3);
    Y = (abs(double(bkgR) - double(imgR))+...
         abs(double(bkgG) - double(imgG))+...
         abs(double(bkgB) - double(imgB))) > 256;
    Y = imopen(Y, strel('disk',1,8));
    
    subplot(1,2,2); imshow(Y);
    subplot(1,2,1); imshow(uint8(img1));
    hold on;
    
    gtFrameDetections = [];
    firstLine = truthMatrix(1,:);
    while(firstLine(1) == n)
        box1 = rectangle('Position',...
              [firstLine(3),...
               firstLine(4),...
               firstLine(5),...
               firstLine(6)],...
              'EdgeColor',[1 1 0],...
              'FaceColor',[1 1 0 0.05]);
        
        gtFrameDetections = vertcat(gtFrameDetections, firstLine);
        truthMatrix(1,:) = [];
        [r, c] = size(truthMatrix);
        if r ~= 0
            firstLine = truthMatrix(1,:);
        else
            break;
        end;
    end
    
    gtNumberOfDetections = numel(gtFrameDetections);
    falsepos = 0;
    truepos = 0;
    falseneg = 0;
    
    pedestrians = area_validation(logical(Y));
    
    if(n~=1)
        [finalPedestrians, pedestriansToShow] = track_pedestrians(pedestrians,pastFrame_pedestrians,n);
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
    
    if(~isempty(pedestriansToShow))
        for j=1:length(pedestriansToShow)
           color = [rand ,rand ,rand];
           rectangle('Position',pedestriansToShow(j).BoundingBox,'EdgeColor',pedestriansToShow(j).Color,'linewidth',2);
            
           [r, ~] = size(gtFrameDetections);
           for k=1:r
                gtDetection = gtFrameDetections(k,:);
                BBcentroidX = gtDetection(1)+gtDetection(3)/2;
                BBcentroidY = gtDetection(2)+gtDetection(4)/2;
                pedCentroidX = pedestrians(j).Centroid(1);
                pedCentroidY = pedestrians(j).Centroid(2);
                d = sqrt(power(BBcentroidX - pedCentroidX,2) + power(BBcentroidY - pedCentroidY,2));
                if d < 30
                    truepos = truepos + 1;
                    gtFrameDetections(k,:) = [];
                    break;
                end
          
                if k == r
                    falsepos = falsepos + 1;
                end
           end
            
        end;
        
        falseneg = numel(gtFrameDetections);
    end;
    
    frameMetrics = [truepos, falsepos, falseneg];
    metrics = vertcat(metrics, frameMetrics);
    
    pastFrame_pedestrians{n} = finalPedestrians;
    pastFrame_shownPedestrians{n} = pedestriansToShow;    
    
    hold on;
    drawnow;
    %BW = img;
    %pause(.2)
end

Evaluation(metrics);