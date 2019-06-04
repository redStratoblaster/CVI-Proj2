%project 2 main

clear all, close all
path = '3DMOT2015/train/PETS09-S2L1/img1/';
%path = '3DMOT2015/test/AVG-TownCentre/img1/';

stepN = 1;
alfa = 0.005;
N=436;
imgName = sprintf('%.6d.jpg', 1);
img = imread(strcat(path, imgName));
bkg = img;
Bkg = rgb2gray(img);

truthMatrix = [];

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

while true
    prompt = 'Select an action:\n 1- Show Pedestrians;\n 2- Show Heatmap;\n 3- Show Trajectories;\n 4- Show map of trajectories;\n 5- Show Evaluation; \n 6- Exit; \n';
    x = input(prompt)
    if(x == 1)
        show_pedestrians(path, stepN, N, alfa, imgName, bkg, img, truthMatrix);
    elseif(x == 2)
        show_heatmap(path, stepN, N, alfa, bkg, img);
    elseif(x == 3)
        show_trajectories(path, stepN, N, alfa, imgName, bkg, img, truthMatrix);
    elseif(x == 4)
        show_trajectories_map(path, stepN, N, alfa, imgName, bkg, img, truthMatrix);
    elseif(x == 5)
        show_evaluation(path, stepN, N, alfa, imgName, bkg, img, truthMatrix);
    elseif(x == 6)
        break;
    end
end