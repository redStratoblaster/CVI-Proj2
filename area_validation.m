
function outputPedestrians = area_validation(lb, num)
    outputPedestrians = [];
    pedestrians = regionprops(lb, 'area', 'FilledImage', 'Centroid', 'BoundingBox');
    numPedestrians = length(pedestrians);
    for i=1:1:numPedestrians
        if(pedestrians(i).Area < 1000)
            outputPedestrians = [outputPedestrians, pedestrians(i)];
        end;
    end;
end