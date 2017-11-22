% Compress HDR or LDR image function dynamic range using gradient domain.
% inputs: imagePath
% sat - saturation factor
% alpha, beta - attenuation factors
% gamma - gamma correction factor
% output: compressed image
function [ CompressedImage ] = GDHDRcompress( imagePath, sat, alpha, beta, gamma, altAtt, gaus_rad, disk)

% imagePath = 'inputs/belg-half.hdr';

split = regexp(imagePath, '\.', 'split');
extension = split(2);
fileName = split{1};

if(strcmp(extension, 'hdr'))
    I = hdrread(imagePath);
else
    I = im2double(imread(imagePath));
    I = I .^ 2.2;
end;

% lum
lumI = (1/3) * (I(:,:,1) + I(:,:,2) + I(:,:,3));
epsilon = 0.0001;
lumI = lumI + epsilon;


% log
H = log(lumI);

% grad
Hdx = imfilter(H, [-1, 1, 0], 'replicate');
Hdy = imfilter(H, [-1, 1, 0]', 'replicate');

% phi
if altAtt
    phi = altAttenuation(lumI, gaus_rad, disk);
    
    
    
    Gx = Hdx;
    Gy = Hdy;
    mx = median(Gx(:));
    my = median(Gy(:));
    Gx(phi < 0.7) = mx;
    Gy(phi < 0.7) = my;
else
    phi = calcAttenuation(H, alpha, beta);
    Gx = Hdx .* phi;
    Gy = Hdy .* phi;
end


% divG
Gxdx = imfilter(Gx, [0,-1, 1], 'replicate');
Gydy = imfilter(Gy, [0,-1, 1]', 'replicate');

divG = Gxdx + Gydy;

% pois
lapOp = sparseLaplaceOp(size(divG,1), size(divG,2)); 

% solve pois eq
attenLumI = lapOp\sparse(double(divG(:)));

%% Discarding highest and lowest values from log image
k = 0.05;
attenLumI = attenLumI - (min(attenLumI(:)) - k);
attenLumI = attenLumI ./ (max(attenLumI(:)) + k);

% def: 0.05

attenLumI = min(attenLumI, 1);
attenLumI = max(attenLumI, 0);

%%

attenLumI = full(attenLumI);
attenLumI = exp(attenLumI);

attenLumI = reshape(attenLumI, size(divG));


attenLumI = attenLumI - min(attenLumI(:));
attenLumI = attenLumI ./ max(attenLumI(:));

attenLumI = 1 - attenLumI;


CompressedImage = I;
CompressedImage(:,:,1) = ((I(:,:,1) ./ lumI).^ sat ) .* attenLumI;
CompressedImage(:,:,2) = ((I(:,:,2) ./ lumI).^ sat ) .* attenLumI;
CompressedImage(:,:,3) = ((I(:,:,3) ./ lumI).^ sat ) .* attenLumI;


CompressedImage = CompressedImage .^ (gamma);

imshow(CompressedImage,[]);

name2 = strcat(fileName, '_c.png');
% name2 = 'belg-half_c.png';
% name2 = sprintf('%s_c.png', fileName);
imwrite(CompressedImage, name2, 'compression', 'none');

end

