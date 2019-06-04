function show_evaluation (path, stepN, N, alfa, imgName, bkg, img, truthMatrix)

    pastFrame_pedestrians = {};

    pastFrame_shownPedestrians = {};

    dotArray = {};

    gtDotArray = [];
    
    metrics = [];
    
    for n = 1 : stepN : N
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));
        bkg = alfa * double(img1) + (1-alfa) * double(bkg);
    end

    dotArray = [];
    [height, width, colors] = size(img);
    heatmap = zeros(height, width);

    for n = 1 : stepN : N
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));
        disp([num2str(n*100/N) '%']);
        [lb num] = pedestrian_detection(bkg,img1);
        
        subplot(1,2,1);imshow(uint8(img1));title('Ground Truth and Pedestrian Detection');
        gtFrameDetections = [];
        %plot the ground truth
        firstLine = truthMatrix(1,:);
        while(firstLine(1) == n)
            rectangle('Position',...
              [firstLine(3),...
               firstLine(4),...
               firstLine(5),...
               firstLine(6)],...
              'EdgeColor',[0 0 0],...
              'FaceColor',[1 1 0 0.05]);

            row = round(firstLine(4)+firstLine(6));
            column = round(firstLine(3)+firstLine(5)/2);

            dotXY = [column, row]; % column = x, row = y
            if 1 < column && column < width && row < height && 1 < row
                gtDotArray = vertcat(gtDotArray, dotXY);
            end
            
            gtFrameDetections = vertcat(gtFrameDetections, firstLine);
            truthMatrix(1,:) = [];
            [r, c] = size(truthMatrix);
            if r ~= 0
                firstLine = truthMatrix(1,:);
            else
                break;
            end;
        end
%         [r,c] = size(gtDotArray);
%         for i = 1 : r
%             line = gtDotArray(i,:);
%             plot(line(1),line(2),'.','Color','yellow','MarkerSize', 10);
%         end

        gtNumberOfDetections = numel(gtFrameDetections);
        falsepos = 0;
        truepos = 0;
        falseneg = 0;
        
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

        subplot(1,2,2);imshow(lb);title('Processed image detection');
        hold on;
        drawnow;
    end
    
    figure;
    precisions = [];
    recalls = [];
    
    [r, ~] = size(metrics);
    for i=1:r
        frame = metrics(i,:);
        precision = frame(1)/(frame(1) + frame(2));
        recall = frame(1)/(frame(1) + frame(3));
        
        precisions = [precisions precision];
        recalls = [recalls recall];
    end
    
    [recalls, sortedIndexes] = sort(recalls);
    precisions = precisions(sortedIndexes);
    plot(recalls, precisions);
    xlabel('Recall'); ylabel('Precision');
end