%% GaussianFilter function

function G=GaussianFilter(N,sigma,FSize)
  h=fspecial('gaussian',FSize,sigma);
  G=imfilter(N,h,0);
end