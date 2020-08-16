function dist_measure = distance_measure(dct_patch_one,patch_two, threshold, ws)
%DISTANCE_MEASURE Summary of this function goes here
%   Detailed explanation goes here
% THe patch one and patch two are compared using a L2 norm of hard
% thresholded transformed difference.
% The hard threshold here is "threshold"
% Normalized transformation is just a normalized 2D matrix sampled from
% normal distribution N(0,1).
% The distance is scaled by the total number of window elements.
%disp("p1 = "+num2str(size(patch_one)));
%disp("p2 = "+num2str(size(patch_two)));
%tic;
tmp = wthresh(double(dct_patch_one),'h',threshold)- ...
                    wthresh(double(patch_two),'h',threshold);
%tmp = reshape(tmp, [ws ws]);
tmp = norm(tmp,2)^2;
dist_measure = tmp/(ws^2);
%disp("Dist time = "+num2str(toc));
end

