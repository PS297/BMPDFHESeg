%% Applying the pre-aggregation function for getting the feature image for color image
function FeatureImg = L1RGB_LehmerDistance(Smooth_R , Smooth_G , Smooth_B)
  
  [a , b]=size(Smooth_R);
  FeatureImg=zeros(a,b);
  G_Sum=0;
  for i=2:a-1
      for j=2:b-1
          VR=Smooth_R(i-1:i+1,j-1:j+1);
          VG=Smooth_G(i-1:i+1,j-1:j+1);
          VB=Smooth_B(i-1:i+1,j-1:j+1);     
          R_Vector=zeros(1,9);
          v=1;
          for c1=1:3
              for c2=1:3
                      V=(abs(VR(c1,c2)-VR(2,2))+abs(VG(c1,c2)-VG(2,2))+abs(VB(c1,c2)-VB(2,2)));
                      R_Vector(1,v)=V;  
                      v=v+1;
              end
          end
          R_Vector=sort(R_Vector,'descend');
              for l1=1:8
                  for l2=1:8
                      if(l1~=l2)
                          if (R_Vector(1,l1)~=0 || R_Vector(1,l2)~=0)
                                  G_Sum=G_Sum+((R_Vector(1,l1)^2+R_Vector(1,l2)^2)/(R_Vector(1,l1)+R_Vector(1,l2)));
                          else
                              G_Sum=G_Sum+0;
                          end
                      end
                  end   
              end
              SUM = G_Sum/(56);
              FeatureImg(i,j)=(SUM);
              G_Sum=0;
      end
  end
end  
  