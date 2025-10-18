function H = buildTapis(tipe, D0, n_butter)
% BANGUNTAPISFREKUENSI Membangun mask filter di ranah frekuensi sesuai slide.
%   INPUT:
%   M, N       - Ukuran citra ASLI.
%   tipe - String jenis filter ('GLPF', 'BHPF', dll.).
%   D0         - Frekuensi cutoff.
%   n_butter   - (Opsional) Orde untuk filter Butterworth.

    % Tentukan ukuran padding sesuai slide (Langkah 1)
    [M, N, C] = size(img)
    P = 2*M;
    Q = 2*N;

    % Buat grid untuk menghitung jarak dari pusat frekuensi
    [U, V] = meshgrid(1:Q, 1:P);
    D = sqrt((U - Q/2).^2 + (V - P/2).^2);

    % Pilih formula filter berdasarkan tipe yang diberikan
    switch upper(tipe)
        case 'ILPF'
            H = double(D <= D0); % [cite: 201]
        case 'GLPF'
            H = exp(-(D.^2) / (2 * D0^2)); % [cite: 210, 407]
        case 'BLPF'
            H = 1 ./ (1 + (D ./ D0).^(2 * n_butter)); % [cite: 425]
        case 'IHPF'
            H = double(D > D0); % atau 1 - ILPF [cite: 707]
        case 'GHPF'
            H = 1 - exp(-(D.^2) / (2 * D0^2)); % [cite: 712]
        case 'BHPF'
            % Formula ini lebih stabil secara numerik daripada 1 - BLPF
            H = 1 ./ (1 + (D0 ./ D).^(2 * n_butter)); % [cite: 710]
            H(isinf(H) | isnan(H)) = 0; % Hindari pembagian dengan nol di pusat
        otherwise
            error('Tipe filter tidak dikenal.');
    end
end