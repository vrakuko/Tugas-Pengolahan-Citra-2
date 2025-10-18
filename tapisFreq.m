function outImg = tapisFreq(img, H)

    F = fftshift(fft2(im2double(img)));
    
    G = F .* H;

    g = ifft2(ifftshift(G));
    
    outImg = im2uint8(mat2gray(real(g)));
end