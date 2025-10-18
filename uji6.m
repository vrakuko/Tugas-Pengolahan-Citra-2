% =========================================================================
%       PROGRAM PENGHILANGAN DERAU PERIODIK DENGAN NOTCH FILTER
% =========================================================================
% Deskripsi:
% Skrip ini menghilangkan derau periodik dengan memungkinkan pengguna
% memilih titik-titik derau pada spektrum Fourier secara interaktif.
% =========================================================================

clear;
clc;
close all;

fprintf('--- Program Penghilangan Derau Periodik ---\n');

% --- LANGKAH 1: PILIH CITRA ---
[file, path] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih Citra dengan Derau Periodik');
if isequal(file, 0)
    disp('Pemilihan file dibatalkan. Skrip berhenti.');
    return;
end
pathLengkapFile = fullfile(path, file);

% --- LANGKAH 2: PROSES CITRA ---
try
    imgNoisy = imread(pathLengkapFile);
    
    % Jika berwarna, konversi ke grayscale karena derau periodik biasanya
    % dianalisis pada intensitas.
    if size(imgNoisy, 3) == 3
        imgNoisy = rgb2gray(imgNoisy);
    end

    % Tampilkan citra asli dan spektrumnya
    F = fftshift(fft2(im2double(imgNoisy)));
    S = log(1 + abs(F));

    figure('Name', 'Analisis Spektrum Fourier', 'NumberTitle', 'off');
    subplot(1, 2, 1); imshow(imgNoisy); title('Citra Berderau');
    subplot(1, 2, 2); imshow(S, []); title('Spektrum Fourier (Log Magnitude)');
    
    % Minta pengguna memilih titik-titik derau
    fprintf('\nINSTRUKSI:\n');
    fprintf('1. Klik pada titik-titik terang (derau) di jendela Spektrum Fourier.\n');
    fprintf('2. Pilih semua titik utama (pasangannya akan otomatis terdeteksi).\n');
    fprintf('3. Setelah selesai, tekan tombol Enter.\n');
    
    [x, y] = getpts; % Dapatkan koordinat dari klik pengguna
    
    % Buat dan terapkan notch filter
    radius = 10; % Radius lingkaran notch
    imgRestored = applyNotchFilter(imgNoisy, x, y, radius);
    
    % Tampilkan hasil akhir
    figure('Name', 'Hasil Penghilangan Derau', 'NumberTitle', 'off');
    subplot(1, 2, 1); imshow(imgNoisy); title('Citra Berderau');
    subplot(1, 2, 2); imshow(imgRestored); title('Hasil Setelah Notch Filter');

catch ME
    fprintf('\nTERJADI ERROR:\n');
    fprintf('Pesan: %s\n', ME.message);
end

