function show_trajectories (path, stepN, N, alfa, imgName, bkg, img, truthMatrix)

    pastFrame_pedestrians = {};

    pastFrame_shownPedestrians = {};

    for n = 1 : stepN : N
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));
        bkg = alfa * double(img1) + (1-alfa) * double(bkg);
    end
    
    figure;
    imshow(uint8(bkg));title('Trajectories');

    dotArray = [];
    [height, width, colors] = size(img);

    for n = 1 : stepN : N
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));

        [lb num] = pedestrian_detection(bkg,img1);
        

        %plot the detected regions    
        pedestrians = area_validation(lb, num);

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

        pastFrame_pedestrians{n} = finalPedestrians;
        pastFrame_shownPedestrians{n} = pedestriansToShow;


        if(~isempty(pedestriansToShow))
            for j=1:length(pedestriansToShow)
                BB = pedestriansToShow(j).BoundingBox;

                row = round(BB(2)+BB(4));
                column = round(BB(1)+BB(3)/2);

                dotXY = [column, row]; % column = x, row = y
                if 1 < column && column < width && row < height && 1 < row
                    hold on;
                    plot(column,row,'g.','MarkerSize', 10);
                end

                drawnow;
            end
        end
        
        
        
    end

end


