% Calculate attenuation map according to our alternative implementation for discarding hard shadows.
% input: lumI - luminance image
% gaus_rad - blur image factor before threshold
% disk - dilation size
% output: Attenuation map, Phi
function [ atten ] = altAttenuation(lumI, gaus_rad, disk)

lumI = lumI - min(lumI(:));
lumI = lumI ./ max(lumI(:));

%%
% Gaussian for threshold
% def: [5 5]
% jump: 10 10
%%
G = fspecial('gaussian',[ceil(gaus_rad) ceil(gaus_rad)],4);
blured_lumI = imfilter(lumI,G,'same');


m = median(blured_lumI(:))./2;
blured_lumI(blured_lumI > m) = 1;
blured_lumI(blured_lumI < m) = 0;

gbdx = conv2(blured_lumI, [-1, 1], 'same');
gbdy = conv2(blured_lumI, [-1, 1]', 'same');
% figure;imshow(gbdy);
gmag = sqrt(gbdx.^2 + gbdy.^2);

%% Gui parameter
% belg-house: 4
% jumping man: 7
%pupik 5
se = strel('disk',ceil(disk));        

%%
mask = imdilate(gmag,se);
G = fspecial('gaussian',[5 5],2);
mask = imfilter(mask,G,'same');

% figure;imshow(mask);

% Hdx = imfilter(H, [-1, 1], 'replicate');
% Hdy = imfilter(H, [-1, 1]', 'replicate');
% gradientH = sqrt((Hdx .^ 2) + (Hdy .^ 2));



atten = (1 - mask);

%% Range of [0,1], maybe delete
atten = atten - min(atten(:));
atten = atten ./ max(atten(:));

m = median(atten(:))./2;
atten(atten > m) = 1;
atten(atten < m) = 0;

G = fspecial('gaussian',[5 5],1);
atten = imfilter(atten,G,'same');


%%
% atten(size(atten,1) - 10:size(atten, 1), :) = 1;
% atten(:, size(atten,2) - 10:size(atten, 2)) = 1;
% atten(1:10,:) = 1;
% atten(:,1:10) = 1;

% H = H ./ 2;
% 
% Hdx = imfilter(H, [-1, 1], 'replicate');
% Hdy = imfilter(H, [-1, 1]', 'replicate');
% gradientH = sqrt((Hdx .^ 2) + (Hdy .^ 2));
% 
% atten_k = (gradientH ./ alpha) .^ (beta - 1);
% atten_k(gradientH < alpha) = 1;
% 
% if (min(size(H)) < 32)
%     atten = atten_k;
% else 
%     reduce_k = imresize(H, 0.5, 'bilinear');
%     atten_reduce_k = calcAttenuation(reduce_k, alpha, beta);
%     expand_k = imresize(atten_reduce_k, size(H), 'bilinear');
%     atten = atten_k .* expand_k;
% end 
% 
% 
end

