close all, clear all, clc

allFiles = dir( 'T:\Marino\Microscopy\Raw Images for Michael\compiled\*.tif' );
filenames = {allFiles.name};

timeMat = zeros(numel(filenames));



for i=1:numel(filenames)
    
    img = im2double(imread(filenames{i}));
    img = img-min(min(img));
    img = img/max(max(img));
    dims = size(img);
    
    img_resh = reshape(img, [1 dims(1)*dims(2)]);
    
    % lets try some thresholding
    
    
    img_doub = im2double(img);   
    
    tic
    threshInt = multithresh(img_doub,2);
    
    img_sg1 = img;
    img_sg1(img<max(threshInt)) = 0;
    img_sg2 = img;
    img_sg2(img < min(threshInt)) = 0;
    img_sg2(img >= max(threshInt)) = 0;
    imgbw = im2bw(img_doub,max(threshInt));
    
    % separate image into thresholded and not thresholded

    
    img_nz = img-img_sg1;
    img_sg1F = medfilt2(img_sg1, [3 3]);
    img_sg2F = medfilt2(img_sg2, [3 3]);
    
    
    imgbw = medfilt2(imgbw, [3 3]);
    
    % linear structure elements used for dilation
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    % diamond shape used for erosion to compensate for original dilation
    seD = strel('diamond',1);
    
    imgbw_D = imdilate(imgbw, [se90 se0]);
    imgbw_F = imfill(imgbw_D, 'holes');
    
    bwC_F = imerode(imgbw_F, seD);
    bwC_F = imerode(bwC_F, seD);    
        
    
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);
    
    s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
            'MinorAxisLength', 'Eccentricity', 'Centroid');
        
    k = find(cell2mat({s.MajorAxisLength})==max(cell2mat({s.MajorAxisLength})));
    
    timeMat(i) = toc;    
%     sprintf('time = %d', timeMat(i))
    
    flsPos = find(cell2mat({s.Area})<1000);
    
    for j=1:numel(flsPos)        
        bwC_F(labeled==flsPos(j)) = 0;
    end
    
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);
    
    figure(1), imshow(bwC_F)
    
    phi = linspace(0, 2*pi, 50);
    cosphi = cos(phi);
    sinphi = sin(phi);
    
    
    

    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;
    
    thetaD = s(k).Orientation;

    theta = pi*s(k).Orientation/180;
    R = [ cos(theta)    sin(theta)
          -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;

    hold on
    plot(x, y, 'r', 'LineWidth', 2)

    figure(2), imshow(img), title('Original Image')
   
    % this completes orientation determination ************************
    
    % **** now for the pattern correlation algorithm *******************
    
    pattern_temp = floures_pattern_gen(45, 70, size(img), 1);
    pattern_rotd = imrotate(pattern_temp, -(90-thetaD));
   
    figure(3), imshow(pattern_rotd);
    
    % this was a try to do without convolution, which takes too much time,
    % but the pattern matrix must be the same size. A more efficient
    % algorithm should be explored once the conv approach is demonstrated
%     img_Four = fft2(img);
%     patt_Four = fft2(pattern_rotd);
%     
%     prod_Four = img_Four.*patt_Four;
%     
%     corr_res = ifft2(prod_Four);
%     figure, imshow(corr_res);

    img_corr = conv2(img, pattern_rotd, 'same');
    
    figure(4), mesh(img_corr);
    s(k).Orientation;
    
%     thetaP = thetaD+90;
%     slpe = atan(thetaP);
%     slpe = round(slpe);
    
    if(abs(thetaD)>45)
        centerY = ceil(size(img_corr,1)/2);
        centerLin = img_corr(centerY,:);
        xVec = 1:size(img_corr,2);
    else
        centerY = ceil(size(img_corr,2)/2);
        centerLin = img_corr(:,centerY)';
        xVec = 1:size(img_corr,1);
    end

    
    xMat = repmat(xVec, size(img_corr,1), 1);
    
    dy_cent = diff(centerLin)./diff(xVec);
    zerCross = diff(sign(dy_cent), 1, 2);

    indX_up = find(zerCross>0);
    indX_down = find(zerCross<0);
    
    if(abs(thetaD)>45)  
        hold on, plot(indX_up, repmat(centerY,1,length(indX_up)), 'b*',...
                     indX_down, repmat(centerY,1,length(indX_down)), 'g*');
    else
        hold on, plot(repmat(centerY,1,length(indX_up)), indX_up, 'b*',...
                      repmat(centerY,1,length(indX_down)),indX_down, 'g*');
    end
%      % plots center line intensities and first derivative
%     figure(5),
%     subplot(1,2,1)
%     plot(1:length(dy_cent), dy_cent);
%     grid on, legend('derivative')
%     subplot(1,2,2)
%     plot(1:length(centerLin), centerLin)
%     grid on, legend('center line')
       
    if(sign(thetaD)>0)
        phiD = thetaD*pi/180;
    else
        phiD = (90+thetaD)*pi/180;
    end
    
    distsMaxes = diff(indX_down)*sin(phiD);
    distsMins = diff(indX_up)*sin(phiD);
    
    aveDistMax = mean(distsMaxes);
    aveDistMin = mean(distsMins);
    
    outStr1 = sprintf('Average distance between peaks is %d.\nAverage distance between troughs is %d.\n',...
                                        aveDistMax, aveDistMin);
    
    aveMax = mean(centerLin(indX_down));
    aveMin = mean(centerLin(indX_up));
    outStr2 = sprintf('Average Maximum value is %d.\nAverage Minimum value is %d',...
                                aveMax, aveMin);
                                    
    disp(outStr1), disp(outStr2)
    
    % alright let's figure out how to determine a line along the
    % maximum intensity value of the stripe
    
    slop = -tand(thetaD);
    
    b = s(k).Centroid(2)-slop.*s(k).Centroid(1);
    
    x=1:.002:size(img,2);
    y = slop*x+b;
    
    rnded = [round(x); round(y)]';
    x = [];
    y = [];
    datapts = unique(rnded, 'rows');
    
    % eliminate values from the line not in the image **************
    inds1 = datapts(:,1);
    inds2 = datapts(:,2);
    inds2(inds2<1) = 0;
    
    inds1((inds1>size(img,2)),:) = 0;
    inds2((inds2>size(img,1)),:) = 0;
    
    rowNums = [find(inds1==0), find(inds2==0)];
    rowNums = sort(unique(rowNums));
    
    datapts(rowNums,:) = []; 
    %**************************************************************
    
    figure(2), hold on, plot(datapts(:,1),datapts(:,2), 'b.');   
    intVals1 = zeros(size(datapts,1),1);
    intVals2 = zeros(size(datapts,1),1);

    
    
    % break this into a function to be repeated for each line in the image,
    % also needs to be adjusted for stripes that are not approximately
    % vertical
    
    

    
    %*********************************************************************
    
    % lets see how the image looks smoothed out
    
    H = fspecial('gaussian', 50, 50/6);
    
    img_sm = medfilt2(img, [2 2]);
    img_sm = imfilter(img_sm, H, 'replicate');
    
    for q=1:size(datapts,1)
       intVals1(q) = img(datapts(q,2), datapts(q,1));
       intVals2(q) = img_sm(datapts(q,2), datapts(q,1));     
    end
    
    figure, imshow(img_sm), title('smoothed image')
    figure, plot(1:length(intVals1),intVals1, 'b.',...
                    1:length(intVals2), intVals2, 'g.');
    figure, subplot(1,2,1), hist(intVals1), subplot(1,2,2), hist(intVals2)
    
    
    pause
    
    close all
    
    
end