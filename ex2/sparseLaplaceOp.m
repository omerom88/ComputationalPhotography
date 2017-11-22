% Calculate laplacian operator.
% input: image size -  height , width.
% returns: A sparse representation the laplacian operator.
function [ sparseLaplace ] = sparseLaplaceOp( height, width )

H = height;
W = width;

laplace = cell(W, W);

center_mat = eye(H)*4;
temp = eye(H+1)*-1;
temp = temp(2:H+1,1:H);
center_mat = center_mat + temp;
temp = eye(H+1)*-1;
temp = temp(1:H,2:H+1);
center_mat = center_mat + temp;

side_mat = eye(H)*-1;

center_indxs = eye(W);

indxs1 = eye(W+1);
indxs1 = indxs1(2:W+1,1:W);

indxs2 = eye(W+1);
indxs2 = indxs2(1:W,2:W+1);

zeros_indexs = 1 - (center_indxs + indxs1 + indxs2);
laplace(center_indxs == 1) = {sparse(center_mat)};
laplace(indxs1 == 1) = {sparse(side_mat)};
laplace(indxs2 == 1) = {sparse(side_mat)};

laplace(zeros_indexs == 1) = {sparse(zeros(H))};
laplace = cell2mat(laplace);

sparseLaplace = sparse(laplace);

end
