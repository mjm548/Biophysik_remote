clear all

filepath = 'C:\Users\Owner\Google Drive\Marino\Microscopy\150624\Image_';
imgNums = 1:12;



threshMat = [];

for i=1:length(imgNums)
    
    % creates names for files; this would be better implemented by
    % extracting filenames from folder of interest
    if(i<10)
        str = strcat(filepath,'0',num2str(imgNums(i)),'.tif');
    else
        str = strcat(filepath,num2str(imgNums(i)),'.tif');
    end
    
    % cell array of images; this could also be implemented as a 3d array of
    % images for increased flexibility
    imgs{i} = imread(str);
    
    % try MATLAB built-in edge detection   
    [bwC, threshC] = edge(imgs{i},'canny');
    
    % extract single image
    temp = imgs{i};
    
    % perform correlation - this was originally intended to be used in
    % order to determine a value for area threshold for noise extraction,
    % however, another approach was preferred
    bwC_corr = autocorr2d(bwC);
    
    % linear structure elements used for dilation
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    
    % dilate black and white gradient image and fill holes
    bwC_D = imdilate(bwC, [se90 se0]);
    bwC_F = imfill(bwC_D, 'holes');
   
    % diamond shape used for erosion to compensate for original dilation
    seD = strel('diamond',1);
    
    % erode to compensate for dilation
    bwC_F = imerode(bwC_F,seD);
    bwC_F = imerode(bwC_F,seD);
    
    % extract perimeter
    edge_C = bwperim(bwC_F);
    
    % overlays edge map onto image
    edgmp_C = temp;
    edgmp_C(edge_C) = 65535;
    
%    % generates figure to compare edgemapped image with original
%     figure,
%     subplot(1,2,2),imshow(edgmp_C), title('Canny');
%     subplot(1,2,1), imshow(temp)
%     threshMat = [threshMat; threshC];
    
    % uses label matrix to calculate area of each region
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);
%     figure, RGB_label = label2rgb(labeled, 'copper', 'c', 'shuffle');
%     imshow(RGB_label, 'InitialMagnification', 'fit');
    
    pixArea = zeros(max(max(labeled)),1);
    
    for i=1:max(max(labeled))
       pixArea(i) = length(find(labeled==i));        
    end
        
    % fits Gaussian model, chi-2 or exponential may be more appropriate but
    % this worked well enough
    modl = fitdist(pixArea,'Normal');
    thresh = modl.mu+2*modl.sigma;
    
    % obtains label for objects below area threshold
    tolow = find(pixArea<thresh);
    inds_2low = [];
    for i=1:length(tolow)
       find(labeled==tolow(i));
       inds_2low = [inds_2low; find(labeled==tolow(i))];
    end
    
    % shows original image
    figure, imshow(bwC_F)
    
    % eliminates noise objects as defined above
    bwC_F(inds_2low) = 0;
      
    % shows BW image after noise removal with original image
    figure, imshow(bwC_F);
    figure, imshow(temp);
        
    pause
    
    close all
    
    end
       
%% using image stacks from 6/26

% [img1,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_399_\stack1\frame_t_0.ets');
% [img2,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_401_\stack1\frame_t_0.ets');
% [img3,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_403_\stack1\frame_t_0.ets');
% [img4,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_405_\stack1\frame_t_0.ets');
% [img5,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_407_\stack1\frame_t_0.ets');
% [img6,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_409_\stack1\frame_t_0.ets');
% [img7,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_411_\stack1\frame_t_0.ets');
% [img8,~, ~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Snapshot_20150626_413_\stack1\frame_t_0.ets');
% 
% [imgStack_1,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_398_\stack1\frame_t_0.ets');
% [imgStack_2,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_400_\stack1\frame_t_0.ets');
% [imgStack_3,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_402_\stack1\frame_t_0.ets');
% [imgStack_4,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_404_\stack1\frame_t_0.ets');
% [imgStack_5,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_406_\stack1\frame_t_0.ets');
% [imgStack_6,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_408_\stack1\frame_t_0.ets');
% [imgStack_7,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_410_\stack1\frame_t_0.ets');
% [imgStack_8,~,~] = image_stack_import('T:\Marino\Microscopy\150626\FieldScan_125deg\_Experiment_Time Lapse_20150626_412_\stack1\frame_t_0.ets');
% 
% dims = size(img1);
% dims2 = size(imgStack_2);
% fillr = zeros(dims(1), dims(2));
% 
% for i=1:size(imgStack_2,3)
% 
%     imgStack_2(:,:,i) = fliplr(imgStack_2(:,:,i));
%     imgStack_4(:,:,i) = fliplr(imgStack_4(:,:,i));
%     imgStack_6(:,:,i) = fliplr(imgStack_6(:,:,i));
%     imgStack_8(:,:,i) = fliplr(imgStack_8(:,:,i));
% 
% end
%     
% 
% imgLN_1 = reshape(imgStack_1(:),size(imgStack_1,1),10*size(imgStack_1,2));
% imgLN_1 = [fillr, imgLN_1];
%         
% imgLN_2 = reshape(imgStack_2(:),size(imgStack_2,1),10*size(imgStack_2,2));
% imgLN_2 = [fliplr(imgLN_2), img2];
%         
% imgLN_3 = reshape(imgStack_3(:),size(imgStack_3,1),10*size(imgStack_3,2));
% imgLN_3 = [img3, imgLN_3];
%         
% imgLN_4 = reshape(imgStack_4(:),size(imgStack_4,1),10*size(imgStack_4,2));
% imgLN_4 = [fliplr(imgLN_4), img4];   
% 
% imgLN_5 = reshape(imgStack_5(:),size(imgStack_5,1),10*size(imgStack_5,2));
% imgLN_5 = [img5, imgLN_5];
%         
% imgLN_6 = reshape(imgStack_6(:),size(imgStack_6,1),10*size(imgStack_6,2));
% imgLN_6 = [fliplr(imgLN_6), img6];
%         
% imgLN_7 = reshape(imgStack_7(:),size(imgStack_7,1),10*size(imgStack_7,2));
% imgLN_7 = [img7, imgLN_7];
%         
% imgLN_8 = reshape(imgStack_8(:),size(imgStack_8,1),10*size(imgStack_8,2));
% imgLN_8 = [fliplr(imgLN_8), img8];   
% 
% 
%         
% imgchk1 = [imgLN_1; imgLN_2; imgLN_3; imgLN_4; imgLN_5; imgLN_6; imgLN_7; imgLN_8];
% 
% figure(1), imshow(imgchk1), fig1_Hand = gca; 
% 
% maskX = [-1 0 1 ; -2 0 2 ; -1 0 1];
% maskY = [-1 -2 -1 ; 0 0 0 ; 1 2 1];
% 
% gradX = conv2(imgchk1,maskX);
% gradY = conv2(imgchk1,maskY);
% 
% magGrad = sqrt(gradX.^2 + gradY.^2);
% magGrad_scld = magGrad/max(max(magGrad));
% 
% figure(2), imtool(magGrad_scld);


