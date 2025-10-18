% SKRIP UNTUK MENGUJI DAN MEMBANDINGKAN FUNGSI KONVOLUSI CUSTOM

clear;
clc;
close all;

nama_citra_gray_1 = '../imageUji/img1a.png'; 
nama_citra_warna_1 = '../imageUji/img1b.png'; 
nama_citra_gray_2 = '../imageUji/img1c.png'; 
nama_citra_warna_2 = '../imageUji/img1d.png'; 

% Membaca citra
try
    citra_gray_1 = imread(nama_citra_gray_1);
    citra_warna_1 = imread(nama_citra_warna_1);
    citra_gray_2 = imread(nama_citra_gray_2);
    citra_warna_2 = imread(nama_citra_warna_2);
catch ME
    disp('Error: Gagal memuat citra. Pastikan nama file dan path sudah benar.');
    disp(ME.message);
    return;
end

% --- DEFINISI MASK ---
mask_gaussian_3x3 = (1/16) * [1 2 1; 2 4 2; 1 2 1];
mask_laplacian_4 = [0 -1 0; -1 4 -1; 0 -1 0];
mask_gaussian_7x7 = (1/140) * [1 1 2 2 2 1 1; 
                               1 2 2 4 2 2 1; 
                               2 2 4 8 4 2 2; 
                               2 4 8 16 8 4 2; 
                               2 2 4 8 4 2 2; 
                               1 2 2 4 2 2 1; 
                               1 1 2 2 2 1 1];
mask_sharpen = [-1 -1 -1; -1 17 -1; -1 -1 -1];

% Kernel tambahan
kernel_mean = ones(7, 7) / (7 * 7);
kernel_gaussian = fspecial('gaussian', [7 7], 3);

% UJI 1: CITRA GRAYSCALE (img1a) DENGAN MASK LAPLACIAN (DETEKSI TEPI)
fprintf('--- UJI 1: Citra Grayscale (%s) dengan Mask Laplacian 3x3 ---\n', nama_citra_gray_1);
uji_dan_tampilkan(citra_gray_1, kernel_mean, 'Uji 1: Grayscale - Laplacian');

% UJI 2: CITRA BERWARNA (img1b) DENGAN MASK GAUSSIAN BLUR 3x3
fprintf('\n--- UJI 2: Citra Berwarna (%s) dengan Mask Gaussian Blur 3x3 ---\n', nama_citra_warna_1);
uji_dan_tampilkan(citra_warna_1, kernel_mean, 'Uji 2: Berwarna - Gaussian Blur 3x3');

% UJI 3: CITRA GRAYSCALE TAMBAHAN (img1c) DENGAN MASK SHARPEN
fprintf('\n--- UJI 3: Citra Grayscale (%s) dengan Mask Sharpen ---\n', nama_citra_gray_2);
uji_dan_tampilkan(citra_gray_2, kernel_gaussian, 'Uji 3: Grayscale - Sharpen');

% UJI 4: CITRA BERWARNA TAMBAHAN (img1d) DENGAN MASK GAUSSIAN BLUR 7x7
fprintf('\n--- UJI 4: Citra Berwarna (%s) dengan Mask Gaussian Blur 7x7 ---\n', nama_citra_warna_2);
uji_dan_tampilkan(citra_warna_2, kernel_gaussian, 'Uji 4: Berwarna - Gaussian Blur 7x7');

% FUNGSI HELPER UNTUK MENJALANKAN TES DAN MENAMPILKAN HASIL
function uji_dan_tampilkan(citra_uji, mask_uji, nama_figure)
    fprintf('size citra: %d %d %d \n', size(citra_uji));
    
    % Menjalankan fungsi buatan dan mengukur waktu
    tic;
    hasil_custom = konvolusiCitra(citra_uji, mask_uji);
    waktu_custom = toc;
    fprintf('Waktu eksekusi fungsi buatan: %.4f detik\n', waktu_custom);
    
    % Menjalankan fungsi built-in Matlab dan mengukur waktu
    tic;
    hasil_matlab = imfilter(citra_uji, mask_uji, 'replicate');
    waktu_matlab = toc;
    fprintf('Waktu eksekusi fungsi Matlab (imfilter): %.4f detik\n', waktu_matlab);
    
    % Menampilkan hasil perbandingan
    figure('Name', nama_figure, 'NumberTitle', 'off');
    
    subplot(2, 2, 1);
    imshow(citra_uji);
    title('Citra Asli');
    
    subplot(2, 2, 2);
    imshow(hasil_custom);
    title(sprintf('Hasil Fungsi Buatan (%.4fs)', waktu_custom));
    
    subplot(2, 2, 3);
    imshow(hasil_matlab);
    title(sprintf('Hasil Matlab imfilter (%.4fs)', waktu_matlab));
end
