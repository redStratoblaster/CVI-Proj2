clear all, close all
path = '3DMOT2015/test/AVG-TownCentre/img1/';

%fig1 = figure;
%background = axes('Position',[0.1 0.1 0.7 0.7]);
%set(gca,'Visible','off');
%foreground = axes('Position',[0.65 0.65 0.28 0.28]);

%fig2 = figure;
stepN = 1;
alfa = 0.01;
N=450;
imgName = sprintf('%.6d.jpg', 1);
img = imread(strcat(path, imgName));
bkg = img;
Bkg = rgb2gray(img);




for n = 1 : stepN : N
    imgName = sprintf('%.6d.jpg', n);
    img1 = imread(strcat(path, imgName));
    bkg = alfa * double(img1) + (1-alfa) * double(bkg);
end

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
    Y = (abs(double(bkgR) - double(imgR))+...
         abs(double(bkgG) - double(imgG))+...
         abs(double(bkgB) - double(imgB))) > 100;
    %Y = imopen(Y, strel('disk',1,8));
    Y = imopen(Y, strel('disk',1,8));
    Y = imclose(Y, strel('disk',8,8));
    Y = imclose(Y, strel('disk',4,8));
    %Y = imdilate(Y, strel('disk',4,8));
    %Y = imdilate(Y, strel('disk',8,8));
    
    subplot(2,2,1); imshow(uint8(bkg));
    subplot(2,2,2); imshow(mat2gray(heatmap)); title('Heatmap');
                    colors = colormap(jet(256));
    subplot(2,2,3); imshow(Y);
    subplot(2,2,4); imshow(uint8(img1));
    hold on;
    
    stats = regionprops(logical(Y), 'Area', 'BoundingBox');
    objIndex = find([stats.Area] > 1500);
    for i = 1 : numel(objIndex)
        statsObj = stats(objIndex);
        boundingBoxI = statsObj(i).BoundingBox;
        rectangle('Position',...
        [boundingBoxI(1),...
        boundingBoxI(2),...
        boundingBoxI(3),...
        boundingBoxI(4)],...
        'EdgeColor',[0 1 0],...
        'FaceColor',[0 1 0 0.2]);
        
        row = round(boundingBoxI(2)+boundingBoxI(4));
        column = round(boundingBoxI(1)+boundingBoxI(3)/2);
        
        dotXY = [column, row]; % column = x, row = y
        if column < width && row < height
            dotArray = vertcat(dotArray, dotXY);
            heatmap(row-1,column-1) = heatmap(row-1,column-1)+1;
            heatmap(row-1,column) = heatmap(row-1,column)+1;
            heatmap(row-1,column+1) = heatmap(row-1,column+1)+1;
            heatmap(row,column-1) = heatmap(row,column-1)+1;
            heatmap(row,column) = heatmap(row,column)+2;
            heatmap(row,column+1) = heatmap(row,column+1)+1;
            heatmap(row+1,column-1) = heatmap(row+1,column-1)+1;
            heatmap(row+1,column) = heatmap(row+1,column)+1;
            heatmap(row+1,column+1) = heatmap(row+1,column+1)+1;
        end
        
        
    end
    
    
    %figure(fig1);
    %axes(handles.background);
    %imshow(uint8(img1));
    %axes(handles.foreground);
    [r,c] = size(dotArray);
    for i = 1 : r
        line = dotArray(i,:);
        plot(line(1),line(2),'g.','MarkerSize', 10);
    end
    %figure(fig2);
    
    hold on;
    drawnow;
    %BW = img;
    %pause(.2)
end