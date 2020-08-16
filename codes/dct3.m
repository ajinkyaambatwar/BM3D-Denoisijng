function res = dct3(data, mode)
%tic;
if(nargin > 2 && mode == 'inverse')
    %{
    res = idct(data,'dim',3);
    for i = 1:size(data,3)
        res(:,:,i)=idct2(res(:,:,i));
    end
    %}
    res = idct(idct(idct(data,[],3),[],2),[],1);
else
    %{
    res=zeros(size(data));
    for i=1:size(data,3)
        res(:,:,i)=dct2(data(:,:,i));
    end
    dct(res,'dim',3);
    %}
    res = dct(dct(dct(data,[],1),[],2),[],3);
end
%disp("DCT time = "+num2str(toc));
end