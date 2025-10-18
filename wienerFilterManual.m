
function imgRestored = wienerFilterManual(imgDegraded, H, K)

    G = fft2(imgDegraded);
    
    % Terapkan formula Wiener Filter
    H_conj = conj(H);
    H_mag_sq = abs(H).^2;
    
    F_hat = (H_conj ./ (H_mag_sq + K)) .* G;
    
    % Lakukan Inverse FFT untuk mendapatkan citra restorasi
    f_hat = real(ifft2(F_hat));
    
    % Normalisasi hasil ke rentang [0,1]
    imgRestored = mat2gray(f_hat);
end