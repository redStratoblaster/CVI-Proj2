clear all, close all;

path = '3DMOT2015/test/AVG-TownCentre/img1/';
N = 450;
truthMatrix = [];

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
  
for i = 1:N
    Img=imread(sprintf(strcat(path,'%.6d.jpg'), i));
    imshow(Img); drawnow;
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
    %pause(0.01);
    hold on
end
%you have now loaded all of the data.