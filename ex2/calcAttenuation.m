% Calculate attenuation map according to Phi function in Gradient Domain High
% Dynamic Range Compression article.
% input: Log of luminance image map
% output: Attenuation map, Phi
function [ atten ] = calcAttenuation(H, alpha, beta)

H = H ./ 2;

Hdx = imfilter(H, [-1, 1], 'replicate');
Hdy = imfilter(H, [-1, 1]', 'replicate');
gradientH = sqrt((Hdx .^ 2) + (Hdy .^ 2));

atten_k = (gradientH ./ alpha) .^ (beta - 1);
atten_k(gradientH < alpha) = 1;

if (min(size(H)) < 32)
    atten = atten_k;
else 
    reduce_k = imresize(H, 0.5, 'bilinear');
    atten_reduce_k = calcAttenuation(reduce_k, alpha, beta);
    expand_k = imresize(atten_reduce_k, size(H), 'bilinear');
    atten = atten_k .* expand_k;
end 
end

