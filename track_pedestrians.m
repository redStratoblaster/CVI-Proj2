function [finalBlobs, blobsToShow] = track_pedestrians(outputBlobs,a,frame)
    finalBlobs = [];
    blobsToShow = [];
    for i=1:1:length(outputBlobs)
        [color,ID] = blobs(outputBlobs(i),a,frame);
        s = struct('Area',outputBlobs(i).Area,'Centroid',outputBlobs(i).Centroid,'Numb',ID,'BoundingBox',outputBlobs(i).BoundingBox, 'Color', color);
        finalBlobs = [finalBlobs; s];
        %disp(a);
        blobsToShow = [blobsToShow, s];
    end;
end

function [color,ID] = blobs(actualBlob,a,frame)
    R = 50;
    %A = 300;
%     D = 4635; %diff
%     treshD = 0.5;
    %AreaDiff = 10;
    xC = actualBlob.Centroid(1);
    yC = actualBlob.Centroid(2);
    
%     Actualarea = actualBlob.Area;
   % areaC = actualBlob.Area;  
    ID = numel(a) + 1 ;
    color = [rand ,rand ,rand];
    i = frame-1;
    if(~isempty(a{i}))
        for j=1:1:length(a{i})
            b = a{i};
            xA = b(j).Centroid(1);
            yA = b(j).Centroid(2);
            distance = sqrt((xC-xA)^2+(yC-yA)^2);
            
            if(distance<R)
                ID = b(j).Numb;
                color =  b(j).Color;
            end;
        end;
    end;
end