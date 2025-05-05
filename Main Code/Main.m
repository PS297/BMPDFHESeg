   clc;
   clear;
   close all;
%% Loading the image and its ground truth
   u = 12;
   srcFiles_Original = dir('Datasets\STARE\OriginalImage\*.ppm');  % the folder in which ur images exists
   srcFiles_Ground = dir('Datasets\STARE\GroundTruth\*.ppm');
   filename_Original = strcat('Datasets\STARE\OriginalImage\',srcFiles_Original(u).name);
   filename_Ground = strcat('Datasets\STARE\GroundTruth\',srcFiles_Ground(u).name);
   
   f = imread(filename_Original);
   figure,imshow(f,"Border","tight");
   Actual = imbinarize(imread(filename_Ground));
   figure,imshow(Actual,"Border","tight");
%% Parameters
   if u == 12 && contains(filename_Original, 'STARE')
       l = [5,0,260,147,10,5,0.47,70,260,0.31,250];
   elseif u == 13 && contains(filename_Original, 'DRIVE')
       l = [5,0,95,95,5,45,0.47,60,95,0.17,250];
   end    
%% Extration of channels
   R = f(:,:,1);
   G = f(:,:,2);
   B = f(:,:,3); 
   figure,imshow(R,"Border","tight");
   figure,imshow(G,"Border","tight");
   figure,imshow(B,"Border","tight");
%% Background Feature Suppresion
   RMed = medfilt2(R,[l(1,1) , l(1,1)]);
   if l(1,2) == 0
       RAdapt = R;
   else
       RAdapt = adapthisteq(R,"NumTiles",[l(1,2) , l(1,2)]);
   end 
   R1 = RMed-R;

   GMed = medfilt2(G,[l(1,3) , l(1,3)]);
   if l(1,4) == 0
       GAdapt = G;
   else
       GAdapt = adapthisteq(G,"NumTiles",[l(1,4) , l(1,4)]);
   end 
   G1 = GMed-GAdapt;

   BMed = medfilt2(B,[l(1,5) , l(1,5)]);
   if l(1,6) == 0
       BAdapt = B;
   else
       BAdapt = adapthisteq(B,"NumTiles",[l(1,6) , l(1,6)]);
   end 
   B1 = BMed-BAdapt;

   figure,imshow(R1)
   figure,imshow(G1);
   figure,imshow(B1);
    
   Normalized_R = double(R1)/255;
   Normalized_G = double(G1)/255;
   Normalized_B = double(B1)/255;

   kernel_size = 3;
   sigma = 0.5;
   Smooth_R = GaussianFilter(Normalized_R,sigma,kernel_size);
   Smooth_G = GaussianFilter(Normalized_G,sigma,kernel_size);
   Smooth_B = GaussianFilter(Normalized_B,sigma,kernel_size);
   
 %% Vessel's Feature Extraction  
   FeatureImg = L1RGB_LehmerDistance(Smooth_R,Smooth_G,Smooth_B);
   figure,imshow(FeatureImg,"Border","tight");
   Adapt = FeatureImg.^0.2;
   figure,imshow(Adapt,"Border","tight");

   BW=imbinarize(Adapt,l(1,7)); 
   D=imopen(BW,strel("disk",1));
   figure,imshow(D,"Border","tight");
   S1=bwareaopen(D,l(1,8));
   Predicted=S1;   
   figure,imshow(Predicted,"Border","tight");

%% Binary Vascular Map Enhancement by BMPDFHE Method
   labInputImage = applycform(f,makecform('srgb2lab'));
   Lbpdfhe = BMPDFHE(im2uint8(Adapt) , labInputImage(:,:,1));
   figure,imshow(labInputImage(:,:,1),"Border","tight");

   labOutputImage = cat(3,Lbpdfhe,labInputImage(:,:,2),labInputImage(:,:,3));
   rgbOutputImage = applycform(labOutputImage,makecform('lab2srgb'));
   figure,imshow(rgbOutputImage(:,:,2),"Border","tight");
   Diff = rgbOutputImage(:,:,2);
   H = medfilt2(G,[l(1,9) , l(1,9)])-Diff;
   figure,imshow(H,"Border","tight");
   H = double(H)/255;
   H1 = imbinarize(H,l(1,10)); 
   figure,imshow(H1,"Border","tight");

   Predicted_H1 = bwareaopen(H1,l(1,11));
   figure,imshow(Predicted_H1,"Border","tight");
   Predicted_H2 = Predicted | Predicted_H1;       
   Predicted_H2 = bwmorph(Predicted_H2,"fill");
   figure,imshow(Predicted_H2,"Border","tight");

   output_folder = 'Output/';  
   if ~exist(output_folder, 'dir')  
       mkdir(output_folder);
   end
    
   filename = fullfile(output_folder, sprintf('Predicted_%d.png', u));
   imwrite(Predicted_H2, filename);  % Save the image
   disp(['Image saved as: ', filename]);  % Display message

