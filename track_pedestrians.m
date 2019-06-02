function [finalPedestrians, pedestriansToShow] = track_pedestrians(outputPedestrians,a,frame)
    finalPedestrians = [];
    pedestriansToShow = [];
    for i=1:1:length(outputPedestrians)
        [color,ID] = detect_ids(outputPedestrians(i),a,frame);
        s = struct('Area',outputPedestrians(i).Area,'Centroid',outputPedestrians(i).Centroid,'Numb',ID,'BoundingBox',outputPedestrians(i).BoundingBox, 'Color', color);
        finalPedestrians = [finalPedestrians; s];
        pedestriansToShow = [pedestriansToShow, s];
    end;
end

function [color,ID] = detect_ids(currentPed,a,frame)
    R = 30;
    xC = currentPed.Centroid(1);
    yC = currentPed.Centroid(2);
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