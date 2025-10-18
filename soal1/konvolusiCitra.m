function outImg = konvolusiCitra(img, kernel)

img = im2double(img);
[imgH, imgW, nChannel] = size(img);


[kernelH, kernelW] = size(kernel);

padY = floor(kernelH / 2);
padX = floor(kernelW / 2);

outimg = zeros(size(img));

for c = 1 : nChannel
    
    currentChannel = img(:, :, c);

    channel_padded = padarray(currentChannel, [padY, padX], 'replicate');

    
    for i = 1:imgH
        for j = 1:imgW
            neighborhood = channel_padded(i:(i + kernelH - 1), j:(j + kernelW - 1));

            nilai_konvolusi = sum(sum(neighborhood .* kernel));
            
            outimg(i, j, c) = nilai_konvolusi;
        end
    end
end

outImg = cast(outimg, class(img));


end