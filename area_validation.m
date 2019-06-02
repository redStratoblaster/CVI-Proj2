
function outputPedestrians = area_validation(lb)
    %Amax = 10000;
    %confirms that blob doesn't touch image boundary
    %dilatedImg = imdilate(binaryImage,strel('disk',6));
    %dilatedImg = imclose(dilatedImg, strel('disk',6));
    %imshow(dilatedImg);
    %[lb, num]=bwlabel(dilatedImg);
    
    outputPedestrians = [];
    stats = regionprops(lb,'Area','Centroid','BoundingBox');
    
    pedestrianObj = find([stats.Area] > 59);
    pedestrians = stats(pedestrianObj);
    
    numPedestrians = numel(pedestrianObj);
    
    for i=1:1:numPedestrians
        if(distanceObject(i,pedestrians,numPedestrians))
            outputPedestrians = [outputPedestrians, pedestrians(i)];
        end;
    end;
end

function distanceBool = distanceObject(i,pedestrians,num)
    R = 30;
    distanceBool = true;
    for x=1:1:num
        if(i~=x)
            x1 = pedestrians(i).Centroid(1);
            x2 = pedestrians(x).Centroid(1);
            y1 = pedestrians(i).Centroid(2);
            y2 = pedestrians(x).Centroid(2);
            distance = num2str(sqrt((x2-x1)^2+(y2-y1)^2));
            if (distance<R)
                distanceBool = false;                
                return;                
            end
        end;
    end;
end