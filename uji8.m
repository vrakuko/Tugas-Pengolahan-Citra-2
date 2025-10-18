% =========================================================================
%       PROGRAM DEKONVOLUSI UNTUK UNKNOWN BLUR (OUT-OF-FOCUS)
% =========================================================================
% Deskripsi:
% Skrip ini mencoba merestorasi citra yang mengalami out-of-focus blur
% dengan mengestimasi PSF berbentuk disk dan menggunakan Penapis Wiener.
% =========================================================================

clear;
clc;
close all;

fprintf('--- Program Dekonvolusi untuk Out-of-Focus Blur ---\n');

% --- LANGKAH 1: PILIH CITRA ---
[file, path] = uigetfile({'*.png';'*.jpg';'*.tif';'*.bmp';'*.*'}, 'Pilih Citra Blur yang Akan Direstorasi');
if isequal(file, 0)
    disp('Pemilihan file dibatalkan. Skrip berhenti.');
    return;
end
pathLengkapFile = fullfile(path, file);
imgBlurred = im2double(imread(pathLengkapFile));

% --- LANGKAH 2: LOOP INTERAKTIF UNTUK MENCOBA PARAMETER ---
radius = 5; % Nilai awal untuk radius blur
NSR = 0.001; % Nilai awal untuk Noise-to-Signal Ratio

while true
    fprintf('\nMencoba restorasi dengan Radius = %d dan NSR = %.4f\n', radius, NSR);

    % 1. Buat estimasi PSF berbentuk disk
    PSF = fspecial('disk', radius);

    % 2. Dapatkan OTF dari PSF
    [M, N, ~] = size(imgBlurred);
    H = psf2otf(PSF, [M N]);

    % 3. Terapkan Penapis Wiener (dengan asumsi input sudah 3D/1D)
    imgRestored = zeros(size(imgBlurred));
    for c = 1:size(imgBlurred, 3)
        imgRestored(:,:,c) = wienerFilterManual(imgBlurred(:,:,c), H, NSR);
    end

    % 4. Tampilkan hasil sementara
    hFig = figure(1);
    clf; % Hapus isi figure sebelumnya
    subplot(1, 2, 1); imshow(imgBlurred); title('Citra Blur Asli');
    subplot(1, 2, 2); imshow(im2uint8(imgRestored)); title(sprintf('Hasil Restorasi (Radius=%d)', radius));
    sgtitle('Eksperimen Dekonvolusi');
    
    % 5. Minta input dari pengguna
    fprintf('Hasil ditampilkan di Figure 1.\n');
    prompt = 'Masukkan radius baru (angka), atau ketik "stop" untuk selesai: ';
    userInput = input(prompt, 's');

    if strcmpi(userInput, 'stop')
        disp('Selesai.');
        break;
    end
    
    newRadius = str2double(userInput);
    if ~isnan(newRadius) && newRadius > 0
        radius = newRadius;
    else
        fprintf('Input tidak valid. Coba lagi.\n');
    end
end

% Fungsi Wiener Filter dari Soal 7 (diletakkan di sini untuk kemudahan)
