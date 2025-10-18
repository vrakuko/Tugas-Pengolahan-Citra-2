function imgOut = applyNotchFilter(img, points_x, points_y, radius)
    % Fungsi ini membuat dan menerapkan notch filter berdasarkan titik yang dipilih.
    [M, N] = size(img);
    F = fftshift(fft2(im2double(img)));
    
    % Buat mask filter, awalnya semua bernilai 1 (melewatkan semua)
    H = ones(M, N);
    
    % Titik pusat spektrum
    centerX = N/2;
    centerY = M/2;
    
    [U, V] = meshgrid(1:N, 1:M);
    
    for i = 1:length(points_x)
        % Titik yang dipilih pengguna
        u_k = points_x(i);
        v_k = points_y(i);
        
        % Titik simetrisnya
        u_k_sym = 2*centerX - u_k;
        v_k_sym = 2*centerY - v_k;
        
        % Buat lingkaran notch di sekitar titik utama dan simetrisnya
        D_k = sqrt((U - u_k).^2 + (V - v_k).^2);
        D_k_sym = sqrt((U - u_k_sym).^2 + (V - v_k_sym).^2);
        
        % Set nilai mask menjadi 0 di dalam radius lingkaran
        H(D_k <= radius) = 0;
        H(D_k_sym <= radius) = 0;
    end
    
    % Terapkan filter
    G = F .* H;
    
    % Lakukan Inverse FFT
    g = ifft2(ifftshift(G));
    imgOut = im2uint8(mat2gray(real(g)));
end