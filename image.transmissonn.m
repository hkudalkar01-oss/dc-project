clc;
clear;
close all;

%% END-TO-END IMAGE TRANSMISSION USING BPSK

%% STEP 1: SELECT IMAGE

[file, path] = uigetfile( ...
    {'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, ...
    'Select an Image');

if isequal(file, 0)
    disp('No image selected.');
    return;
end

img = imread(fullfile(path, file));

%% STEP 2: CONVERT IMAGE TO GRAYSCALE

if ndims(img) == 3
    img_gray = uint8( ...
        0.299 * double(img(:,:,1)) + ...
        0.587 * double(img(:,:,2)) + ...
        0.114 * double(img(:,:,3)) );
else
    img_gray = img;
end

figure;
imshow(img_gray);
title('Original Image');

%% STEP 3: GET IMAGE SIZE

[rows, cols] = size(img_gray);

fprintf('Image Size: %d x %d pixels\n', rows, cols);

%% STEP 4: CONVERT IMAGE PIXELS TO BITS

pixels = img_gray(:);

num_pixels = length(pixels);

tx_bits = zeros(num_pixels * 8, 1);

for k = 1:num_pixels
    for b = 1:8
        tx_bits((k-1)*8 + b) = bitget(pixels(k), 9-b);
    end
end

fprintf('Total transmitted bits: %d\n', length(tx_bits));

%% STEP 5: BPSK MODULATION

% Bit 0 = -1
% Bit 1 = +1

bpsk_signal = 2 * double(tx_bits) - 1;

%% STEP 6: ADD AWGN NOISE

SNR_dB = 10;

signal_power = mean(bpsk_signal.^2);

noise_power = signal_power / (10^(SNR_dB/10));

noise = sqrt(noise_power) * randn(size(bpsk_signal));

rx_signal = bpsk_signal + noise;

%% STEP 7: BPSK DEMODULATION

rx_bits = double(rx_signal >= 0);

%% STEP 8: CALCULATE BER

number_of_errors = sum(tx_bits ~= rx_bits);

BER = number_of_errors / length(tx_bits);

fprintf('\nNumber of bit errors: %d\n', number_of_errors);
fprintf('Bit Error Rate (BER): %.6f\n', BER);

%% STEP 9: CONVERT RECEIVED BITS BACK TO PIXELS

rx_pixels = zeros(num_pixels, 1, 'uint8');

for k = 1:num_pixels

    value = uint8(0);

    for b = 1:8
        if rx_bits((k-1)*8 + b) == 1
            value = bitor(value, bitshift(uint8(1), 8-b));
        end
    end

    rx_pixels(k) = value;

end

%% STEP 10: RECONSTRUCT RECEIVED IMAGE

received_image = reshape(rx_pixels, rows, cols);

%% STEP 11: DISPLAY RECEIVED IMAGE

figure;
imshow(received_image);
title('Received Image');

%% STEP 12: COMPARE ORIGINAL AND RECEIVED IMAGE

figure;

subplot(1,2,1);
imshow(img_gray);
title('Original Image');

subplot(1,2,2);
imshow(received_image);
title('Received Image');

%% STEP 13: DISPLAY TRANSMITTED BPSK SIGNAL

figure;

plot(bpsk_signal(1:min(200,length(bpsk_signal))));
grid on;

title('BPSK Transmitted Signal');
xlabel('Bit Number');
ylabel('Amplitude');

%% STEP 14: DISPLAY RECEIVED SIGNAL

figure;

plot(rx_signal(1:min(200,length(rx_signal))));
grid on;

title('Received Signal with Noise');
xlabel('Bit Number');
ylabel('Amplitude');

%% FINAL RESULTS

fprintf('\n====================================\n');
fprintf('       IMAGE TRANSMISSION RESULT\n');
fprintf('====================================\n');
fprintf('Image Size : %d x %d pixels\n', rows, cols);
fprintf('SNR        : %d dB\n', SNR_dB);
fprintf('Total Bits : %d\n', length(tx_bits));
fprintf('Bit Errors : %d\n', number_of_errors);
fprintf('BER        : %.6f\n', BER);
fprintf('====================================\n');