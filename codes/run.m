search_space = 39;
window_size = 8;
N_hard = 8;
l2 = 0;
l3 = 2.8;
sigma=0.2;
orig_ima = imread('lena.jpg');
orig_ima = orig_ima(500:900,470:770, :);
orig_ima = imresize(orig_ima,[256-search_space,256-search_space]);
for inp_channel = 1:3
img = padarray(orig_ima(:,:,inp_channel), [(search_space+1)/2, (search_space+1)/2], 0,'both');
noisy = imnoise(img, 'gaussian', 0, sigma*sigma);
noisy_img(:,:,inp_channel) = noisy;
basic_result(:,:,inp_channel) = fs(noisy, sigma, window_size, search_space, l2*sigma, l3*sigma, N_hard);
end
noisy_img = noisy_img(search_space+1:end-search_space, ...
    search_space+1:end-search_space,:);
basic_result = uint8(basic_result);
imwrite(noisy_img,['output/lena_noisy_image_',num2str(sigma),'.jpg']);
imwrite(basic_result,['output/lena_res_phase1_',num2str(sigma),'.jpg']);

f1 = figure();
subplot(1,2,1);
imshow(noisy_img);
title("Noisy Original");
subplot(1,2,2);
imshow(basic_result);
title({"Denoised image with ", "sigma = "+num2str(sigma)});
saveas(f1, "output/lena_compare_"+num2str(sigma)+".jpg");

f2 = figure();
imshow(noisy_img-basic_result);
title("Difference");
saveas(f2, "output/lena_difference_"+num2str(sigma)+".jpg");


test = orig_ima((search_space-1)/2+1:end-(search_space-1)/2,(search_space-1)/2+1:end-(search_space-1)/2,:);
test_ = single(test);
%PSNR and SSIM calculation
%PSNR and SSIM of noisy image
peaksnr_noisy = psnr(noisy_img, test);
ssim_noisy = ssim(noisy_img, test);

% BM3D L1 output
peaksnr_basic_op = psnr(basic_result, test);
ssim_basic_op = ssim(basic_result, test);