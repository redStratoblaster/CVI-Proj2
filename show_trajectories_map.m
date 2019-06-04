function show_trajectories_map (path, stepN, N, alfa, imgName, bkg, img, truthMatrix)

    pastFrame_pedestrians = {};

    pastFrame_shownPedestrians = {};

    for n = 1 : stepN : N
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));
        bkg = alfa * double(img1) + (1-alfa) * double(bkg);
    end
    
    figure; imshow(uint8(bkg)); hold on;
    disp('wait while the map is being calculated.');
    gtDotArray = [];
    dotArray = [];
    [height, width, colors] = size(img);

    for n = 1 : stepN : N
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));
        disp([num2str(n*100/N) '%']);
        
        firstLine = truthMatrix(1,:);
        while(firstLine(1) == i)
            row = round(firstLine(4)+firstLine(6));
            column = round(firstLine(3)+firstLine(5)/2);

            dotXY = [column, row]; % column = x, row = y
            if 1 < column && column < width && row < height && 1 < row
                gtDotArray = vertcat(gtDotArray, dotXY);
                %plot(column, row,'.','Color','yellow','MarkerSize', 10);
            end

            truthMatrix(1,:) = [];
            [r, c] = size(truthMatrix);
            if r ~= 0
                firstLine = truthMatrix(1,:);
            else
                break;
            end;
        end
        
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
                    dotArray = vertcat(dotArray, dotXY);
                    plot(column,row,'g.','MarkerSize', 5);
                end
            end
        end
        
        drawnow;
        pause(0.001);
    end
    
    
    
    figure, imshow(uint8(bkg));
    [r,c] = size(gtDotArray);
    for n = 1 : r
        line = gtDotArray(n,:);
        plot(line(1),line(2),'.','Color','yellow','MarkerSize', 10);
    end
    hold on;
    
    figure;
    
end


