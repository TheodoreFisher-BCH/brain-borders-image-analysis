


[filename,pathname]=uigetfile('*.tif','registration2');
Base= imread(fullfile(pathname,filename), 'tif'); 
imshow(Base);


%B220 
[filename,pathname]=uigetfile('*.tif','bcelltest1');
Float_1= imread(fullfile(pathname,filename), 'tif'); 
Float1= rot90(Float_1,-1) 
imshow(Float1);

%adjust contrast tool (input values ) 
imtool(Float1);
J = imadjust(Float1,[0.0 0.2])
imshow(J) %J=contrasted image for comparison 
 
%point-based registration to base image 
% possible to load in fixed points 

fixedPoints = [[1093.68965517241,2.48275862068977;1450.58620689655,5.58620689655186;1168.17241379310,539.379310344828;1304.72413793103,623.172413793104;1158.86206896552,706.965517241379;1071.96551724138,1243.86206896552;1419.55172413793,1237.65517241379;16.7931034482760,548.689655172414;16.7931034482760,691.448275862069]];
movingPoints = [[16381.7589445438,2976.28577817530;18810.9718246869,2976.28577817530;15201.8555456172,8945.20885509838;17769.8805903399,9535.16055456171;14854.8251341682,10333.3305008945;16451.1650268336,16961.6113595707;18810.9718246869,16614.5809481216;5033.86449016100,8806.39669051878;5033.86449016100,10541.5487477639]]
cpselect(J,Base,movingPoints,fixedPoints);

%if fine tune needed use cpcorr
% transform based of reg points B220
tform = fitgeotrans(movingPoints1,fixedPoints1,'similarity')

%view B220 
B220registered = imwarp(Float1,tform,'OutputView',imref2d(size(Base)));
imshowpair(Base,B220registered)

%import CD45 + 
[filename,pathname]=uigetfile('*.tif','bcelltest1');
Float_2= imread(fullfile(pathname,filename), 'tif'); 
Float2= rot90(Float_2,-1) 
imshow(Float2);
J2 = imadjust(Float1,[0.0 0.2])
imshow(J2)
%register CD45 
tform = fitgeotrans(movingPoints1,fixedPoints1,'similarity')

%view CD45 
CD45registered = imwarp(Float2,tform,'OutputView',imref2d(size(Base)));
imshowpair(Base,CD45registered)

%register contrast map for B220 as new base 
Jregistered = imwarp(J,tform,'OutputView',imref2d(size(Base)));
imshowpair(Base,J)


CD45regcontrast = imadjust(CD45registered,[0 0.2])
imshow(CD45regcontrast)


%B220 processing 
%binary filtering at level x 

BW = im2bw(B220registered,0.07) 
imshowpair(BW,J) 

%edge analysis w/fudge 

[~,threshold] = edge(BW,'sobel',[]);
fudgeFactor = 0.9;
BWs = edge(Jregistered,'sobel',threshold * fudgeFactor);

imshow(BWs)
imshow(labeloverlay(Jregistered,BWs))

%dilate image and fill cells check parameters 

se90 = strel('line',1,90);
se0 = strel('line',1,0);

BWsdil = imdilate(BWs,[se90 se0]);
imshow(BWsdil)

BWdfill = imfill(BWsdil,'holes');
imshow(BWdfill)

BWnobord = imclearborder(BWdfill,4);
imshow(BWnobord)
imshow(labeloverlay(Jregistered,BWnobord))


%higher strel can be used to separate big clusters 
seD = strel(1);
BWfinal = imerode(BWnobord,seD);
%%BWfinal = imerode(BWfinal,seD);
imshow(BWfinal)
imshow(labeloverlay(Jregistered,BWfinal))


%save B220


%CD45
%binary filtering at level x 

BW45 = im2bw(CD45registered,0.07) 
imshowpair(BW45,CD45regcontrast) 

%edge analysis w/fudge 

[~,threshold] = edge(BW45,'sobel',[]);
fudgeFactor = 2;
BWs45 = edge(CD45regcontrast,'sobel',threshold * fudgeFactor);

imshow(BWs45)
imshow(labeloverlay(CD45regcontrast,BWs45))

%dilate image and fill cells check parameters 

se90 = strel('line',1,90);
se0 = strel('line',1,0);

BWsdil45 = imdilate(BWs45,[se90 se0]);
imshow(BWsdil45)

BWdfill45 = imfill(BWsdil45,'holes');
imshow(BWdfill45)

BWnobord45 = imclearborder(BWdfill45,4);
imshow(BWnobord45)
imshow(labeloverlay(Jregistered,BWnobord45))


%higher strel can be used to separate big clusters 
seD = strel(1);
BWfinal45 = imerode(BWnobord45,seD);
BWfinal45 = imerode(BWfinal45,seD);
imshow(BWfinal45)
imshow(labeloverlay(CD45regcontrast,BWfinal45))


%sub
B220 = mean(BWfinal,3)
CD45 = mean(BWfinal45,3)
imshow(labeloverlay(B220,CD45))
C = imfuse(B220,CD45,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
imshow(C)


Finalcellmap = BWfinal - BWfinal45
im_021620_1 = Finalcellmap
imshow(Finalcellmap)
imshow(labeloverlay(Finalcellmap,BWfinal))

montage({BWfina,CD45},'Size',[1 3])
