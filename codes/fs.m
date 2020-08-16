function basic_output = fs(input_image,sigma_val, window_size, search_space, hard_threshold_dist, hard_threshold_dct, N_hard)
    %FIRST_STEP Summary of this function goes here
    % input_image : The noisy input image
    % window_size : The size of the sliding window also the patch size
    % search_space : The search space for finding the patches
    % hard_threshold_dist : Matching threshold
    % hard_threshold_dct : 3D threshold
    % N_hard : Allowed patche in block
    %   Detailed explanation goes here

    h = size(input_image,1);
    w = size(input_image,2);

    numerator = zeros(size(input_image));
    denominator = zeros(size(input_image));
    
    tic;
   
    % extract the search window for a patch p which would be the reference
    % patch and centre of the window
    % compare that patch with every patch in the search window
    % create the block
    % apply 3d dct over it and hard shrink the dct space
    % inverse dct to get the primary result
    % aggregate the result to form the basic output
    for i=1:h
        disp("i = "+num2str(i));
        for j=1:w
            % Start coordinate for the search window
            x = max(1, min(i-(search_space+1)/2, h - search_space + 1));
            y = max(1, min(j-(search_space+1)/2,w - search_space + 1));

            xcen = min(i, h+1-window_size);
            ycen = min(j, w+1-window_size);
            
            % Centre patch
            reference_block = input_image(xcen:xcen+window_size-1, ycen:ycen+window_size-1);
            
            len1 = length(x:4:x+search_space-window_size);
            dist = zeros(len1*len1,1);
            patch = zeros(len1*len1,window_size,window_size);
            img_indices = zeros(len1*len1,2);
            cnt = 1;
            
            for k =x:4:x+search_space  
                for t = y:4:y+search_space
                    % Adjusting
                    k_ = min(k, h+1-window_size);
                    t_ = min(t, w+1-window_size);
                    
                    patch(cnt,:,:) = input_image(k_:k_+window_size-1,t_:t_+window_size-1);
                    curr_patch = reshape(patch(cnt,:,:), [window_size window_size]);
                    distance = distance_measure(reference_block, curr_patch, hard_threshold_dist, window_size);
                    dist(cnt) = distance;
                    img_indices(cnt,:) = [k,t];
                    cnt = cnt+1;
                end
            end

            % Patch selection and 3D transform and 3D tresholding
            [~, indices] = sort(dist);
            indices = indices(1:N_hard);
            blocks = patch(indices,:,:);
            three_d_group = zeros([window_size window_size N_hard]); 
            for p=1:N_hard
                three_d_group(:,:,p) = blocks(p,:,:);
            end
            three_d_group = dct3(three_d_group);
            three_d_group = wthresh(three_d_group, 'h', hard_threshold_dct);
            
            if(sum(three_d_group(:)>0) >= 1)
                wp = 1/(sigma_val^2 * sum(three_d_group(:)>0));
            else
                wp = 1;
            end
            
            %Inverse 3D transform and Aggregation
            three_d_group = dct3(three_d_group, 'inverse');
            for l=1:N_hard        
                numerator(xcen:xcen+window_size-1, ycen:ycen+window_size-1) = numerator(xcen:xcen+window_size-1, ycen:ycen+window_size-1)+wp*three_d_group(:,:,l);
                denominator(xcen:xcen+window_size-1, ycen:ycen+window_size-1) = denominator(xcen:xcen+window_size-1, ycen:ycen+window_size-1)+wp;
            end
        end
    end
    timeElapsed= toc;
    disp("Time = "+num2str(timeElapsed));
    basic_result = numerator./denominator;
    basic_output = basic_result(search_space+1:end-search_space,search_space+1:end-search_space);
end

