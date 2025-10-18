function imgOut = filterHomomorphic(img)
    % Fungsi ini menerapkan filter homomorfik pada citra input.

    % --- Parameter Filter ---
    % Cutoff frequency untuk Gaussian high-pass filter
    % D0 = 30;
    % Gamma L dan Gamma H untuk mengontrol atenuasi dan penguatan
    gammaL = 0.5; % Kurang dari 1 untuk menekan frekuensi rendah
    gammaH = 2.0; 
    c = 1;

    [M, N, C] = size(img);
    D0 = min(M,N)/8 ;
    imgOut = zeros(M, N, C);

    % Buat grid frekuensi
    [U, V] = meshgrid(1:N, 1:M);
    D_sq = (U - ceil(N/2)).^2 + (V - ceil(M/2)).^2;

    % Buat Gaussian High-Pass Filter yang dimodifikasi
    H = (gammaH - gammaL) * (1 - exp(-c * D_sq / (D0^2))) + gammaL;

    % Proses setiap channel jika citra berwarna
    for channel = 1:C
        % 1. Transformasi Logaritma (tambah 1 untuk menghindari log(0))
        imgLog = log(img(:,:,channel) + 1);

        % 2. Transformasi Fourier
        imgFFT = fftshift(fft2(imgLog));

        % 3. Terapkan Filter
        imgFilteredFFT = H .* imgFFT;

        % 4. Transformasi Fourier Invers
        imgIFFT = ifft2(ifftshift(imgFilteredFFT));

        % 5. Transformasi Eksponensial
        imgExp = exp(real(imgIFFT)) - 1;
        
        % Normalisasi hasil ke rentang [0,1]
        imgOut(:,:,channel) = mat2gray(imgExp);
    end
    
    % Jika input adalah grayscale, pastikan output juga grayscale
    if C == 1
        imgOut = imgOut(:,:,1);
    end
end