%% GaussianFilter function

function G=GaussianFilter(N,sigma,FSize)
  h=fspecial('gaussian',FSize,sigma); %% FSize represents the kernel size
  G=imfilter(N,h,0); 
end
