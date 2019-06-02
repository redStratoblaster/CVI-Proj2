function show_heatmap (path, stepN, N, alfa, bkg, img)
    for n = 1 : stepN : N
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));
        bkg = alfa * double(img1) + (1-alfa) * double(bkg);
    end

    figure;
    [height, width, colors] = size(img);
    heatmap = zeros(height, width);

    for n = 1 : stepN : N
        %clf('reset');
        imgName = sprintf('%.6d.jpg', n);
        img1 = imread(strcat(path, imgName));

        [lb num] = pedestrian_detection(bkg,img1);

        heatmap = heatmap + lb;
        imshow(mat2gray(heatmap)); title('Heatmap');
            colors = colormap(jet(N));

        %hold on;
        drawnow;
    end
end

