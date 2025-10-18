% =========================================================================
%       PROGRAM RESTORASI CITRA DARI MOTION BLUR DENGAN PENAPIS WIENER
% =========================================================================
% Deskripsi:
% Skrip ini melakukan simulasi motion blur pada sebuah citra, kemudian
% mencoba merestorasinya menggunakan Penapis Wiener yang diimplementasikan
% secara manual.
%
% Constraint: Tidak menggunakan fungsi deconvwnr bawaan Matlab.
%
% Cukup jalankan file ini dari Matlab.
% =========================================================================

clear;
clc;
close all;

fprintf('--- Program Uji Restorasi Citra dengan Penapis Wiener ---\n');

try
    % --- LANGKAH 1: UJI CITRA GRAYSCALE ---
    fprintf('\n[LANGKAH 1 dari 2]\n');
    [fileGray, pathGray] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih sebuah Citra Grayscale untuk Diuji');
    if isequal(fileGray, 0)
        disp('Pemilihan file dibatalkan. Skrip berhenti.');
        return;
    end
    jalankanUjiWiener(fullfile(pathGray, fileGray), 'Grayscale');

    % --- LANGKAH 2: UJI CITRA BERWARNA ---
    fprintf('\n[LANGKAH 2 dari 2]\n');
    [fileColor, pathColor] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih sebuah Citra Berwarna untuk Diuji');
    if isequal(fileColor, 0)
        disp('Pemilihan file dibatalkan. Skrip berhenti.');
        return;
    end
    jalankanUjiWiener(fullfile(pathColor, fileColor), 'Berwarna');
    
    fprintf('\n--- Pengujian Selesai ---\n');

catch ME
    fprintf('\nTERJADI ERROR FATAL:\n');
    fprintf('Pesan: %s\n', ME.message);
    fprintf('Error terjadi di file: %s, baris: %d\n', ME.stack(1).name, ME.stack(1).line);
end


% =========================================================================
%                     FUNGSI-FUNGSI PEMBANTU (LOKAL)
% =========================================================================

function jalankanUjiWiener(pathLengkapFile, tipe)
    % Fungsi ini menjalankan seluruh proses untuk satu citra.

    % --- Parameter Simulasi dan Restorasi ---
    LEN = 25;       % Panjang pergerakan blur dalam piksel
    THETA = 15;     % Sudut pergerakan dalam derajat
    NOISE_VAR = 0.0001; % Variansi derau Gaussian yang ditambahkan setelah blur
    NSR = NOISE_VAR * 10; % Estimasi Noise-to-Signal Ratio (K). INI PARAMETER PENTING UNTUK DIUBAH.

    fprintf('\nMemproses citra %s: %s\n', tipe, pathLengkapFile);
    
    % 1. Muat Citra
    imgOri = im2double(imread(pathLengkapFile)); % Langsung konversi ke double
    [M, N, C] = size(imgOri);
    fprintf('Info: Ukuran citra adalah %d x %d x %d.\n', M, N, C);

    % 2. Simulasi Degradasi (Motion Blur + Noise)
    % Buat Point Spread Function (PSF) untuk motion blur
    PSF = fspecial('motion', LEN, THETA);
    
    % Terapkan blur menggunakan konvolusi spasial
    % Opsi 'circular' penting untuk menghindari artefak pinggir saat dekonvolusi FFT
    imgBlurred = imfilter(imgOri, PSF, 'conv', 'circular');
    
    % Tambahkan sedikit derau Gaussian
    imgDegraded = imnoise(imgBlurred, 'gaussian', 0, NOISE_VAR);

    % 3. Proses Restorasi dengan Penapis Wiener
    % Dapatkan Optical Transfer Function (OTF) dari PSF
    H = psf2otf(PSF, [M N]);
    
    imgRestored = zeros(size(imgOri));
    
    if C == 3 % Jika citra berwarna, proses per channel
        fprintf('Menerapkan Penapis Wiener pada 3 channel warna...\n');
        for channel = 1:3
            imgRestored(:,:,channel) = wienerFilterManual(imgDegraded(:,:,channel), H, NSR);
        end
    else % Jika citra grayscale
        fprintf('Menerapkan Penapis Wiener pada 1 channel grayscale...\n');
        imgRestored = wienerFilterManual(imgDegraded, H, NSR);
    end
    
    % Konversi semua citra ke uint8 untuk ditampilkan
    imgOri_uint8 = im2uint8(imgOri);
    imgDegraded_uint8 = im2uint8(imgDegraded);
    imgRestored_uint8 = im2uint8(imgRestored);

    % 4. Tampilkan Hasil
    figure('Name', ['Restorasi Wiener - ' tipe], 'NumberTitle', 'off');
    subplot(2, 2, 1); imshow(imgOri_uint8); title('Citra Asli');
    subplot(2, 2, 2); imshow(imgDegraded_uint8); title(sprintf('Citra Terdegradasi (Blur+Derau)'));
    subplot(2, 2, 3); imshow(imgRestored_uint8); title(sprintf('Hasil Restorasi Wiener (K=%.4f)', NSR));
    subplot(2, 2, 4); imshow(PSF, [], 'InitialMagnification', 'fit'); title(sprintf('Kernel Blur (LEN=%d, THETA=%d)', LEN, THETA));
    sgtitle(['Uji Penapis Wiener pada Citra ' tipe], 'FontSize', 14, 'FontWeight', 'bold');
end

