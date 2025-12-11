% The 'powerspec' script is used for iEEG signal power spectrum calculation
close all

% Please fill in the directory where the target EDF files is located in the 'pathname' variable
pathname = [''];
file_list = dir(fullfile(pathname, '*.edf'));

fs = 200;                           % Sampling frequency
fre_high = 80;                 % Upper limit frequency of the spectrum analyzed
duration = 10;                     % Duration of the signal for analysis
before_time = 45;               % Start time of the signal for analysis (before)
after_time = 75;               % Start time of the signal for analysis (after)

% Process all EDF files in the directory
for i = 1:length(file_list)
    filename = file_list(i).name;
    file = fullfile(pathname, filename);
    fprintf('文件 %d/%d: %s\n', i, length(file_list), filename);
    LFP_data = ft_read_data(file);
    LFP_PSD_data_before = LFP_data(:, before_time*fs : before_time*fs+duration*fs-1);
    LFP_PSD_data_after = LFP_data(:, after_time*fs : after_time*fs+duration*fs-1);
    L = length(LFP_PSD_data_before);
    noverlap = 100;                         % Overlap length
    nfft = 128;                                % FFT length
    nF = nfft/2;
    window = hamming(nfft);      % Hamming window
    n_segments = L/nfft;

    for j = 1:2
        [p_before(j,:), f] = pwelch(LFP_PSD_data_before(j,:), window, noverlap, nfft, fs);
        [p_after(j,:), f] = pwelch(LFP_PSD_data_after(j,:), window, noverlap, nfft, fs);
    end
    index = interp1(f, 1:length(f), fre_high, 'nearest');
    PP_before = 10*log10(p_before(1,:));
    PSD_before_1(i,:) = PP_before(1:index)';
    PP_before = 10*log10(p_before(2,:));
    PSD_before_2(i,:) = PP_before(1:index)';
    PP_after = 10*log10(p_after(1,:));
    PSD_after_1(i,:) = PP_after(1:index)';
    PP_after = 10*log10(p_after(2,:));
    PSD_after_2(i,:) = PP_after(1:index)';

    POWER_before_1_all = bandpower(p_before(1,:), f, [4 80], 'psd');
    POWER_before_1(i,1) =  bandpower(p_before(1,:), f, [4 8], 'psd')/POWER_before_1_all;
    POWER_before_1(i,2) =  bandpower(p_before(1,:), f, [9 12], 'psd')/POWER_before_1_all;
    POWER_before_1(i,3) =  bandpower(p_before(1,:), f, [13 30], 'psd')/POWER_before_1_all;
    POWER_before_1(i,4) =  bandpower(p_before(1,:), f, [31 80], 'psd')/POWER_before_1_all;
    
    POWER_before_2_all = bandpower(p_before(2,:), f, [4 80], 'psd');
    POWER_before_2(i,1) =  bandpower(p_before(2,:), f, [4 8], 'psd')/POWER_before_2_all;
    POWER_before_2(i,2) =  bandpower(p_before(2,:), f, [9 12], 'psd')/POWER_before_2_all;
    POWER_before_2(i,3) =  bandpower(p_before(2,:), f, [13 30], 'psd')/POWER_before_2_all;
    POWER_before_2(i,4) =  bandpower(p_before(2,:), f, [31 80], 'psd')/POWER_before_2_all;
    
    POWER_after_1_all = bandpower(p_after(1,:), f, [4 80], 'psd');
    POWER_after_1(i,1) =  bandpower(p_after(1,:), f, [4 8], 'psd')/POWER_after_1_all;
    POWER_after_1(i,2) =  bandpower(p_after(1,:), f, [9 12], 'psd')/POWER_after_1_all;
    POWER_after_1(i,3) =  bandpower(p_after(1,:), f, [13 30], 'psd')/POWER_after_1_all;
    POWER_after_1(i,4) =  bandpower(p_after(1,:), f, [31 80], 'psd')/POWER_after_1_all;
    
    POWER_after_2_all = bandpower(p_after(2,:), f, [4 80], 'psd');
    POWER_after_2(i,1) =  bandpower(p_after(2,:), f, [4 8], 'psd')/POWER_after_2_all;
    POWER_after_2(i,2) =  bandpower(p_after(2,:), f, [9 12], 'psd')/POWER_after_2_all;
    POWER_after_2(i,3) =  bandpower(p_after(2,:), f, [13 30], 'psd')/POWER_after_2_all;
    POWER_after_2(i,4) =  bandpower(p_after(2,:), f, [31 80], 'psd')/POWER_after_2_all;
end

figure(1)
subplot(2,1,1)
f = f';
PSD_before_1_mean = mean(PSD_before_1, 1);
PSD_before_1_std = std(PSD_before_1, 0, 1) ./ sqrt(size(PSD_before_1, 1));
plot(f(1:index), PSD_before_1_mean, 'LineWidth', 2);
hold on
fill([f(1:index), fliplr(f(1:index))], [(PSD_before_1_mean + PSD_before_1_std), fliplr(PSD_before_1_mean - PSD_before_1_std)], ...
    [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
hold on
PSD_after_1_mean = mean(PSD_after_1, 1);
PSD_after_1_std = std(PSD_after_1, 0, 1);
plot(f(1:index), PSD_after_1_mean, 'LineWidth', 2);
hold on
fill([f(1:index), fliplr(f(1:index))], [(PSD_after_1_mean + PSD_after_1_std), fliplr(PSD_after_1_mean - PSD_after_1_std)], ...
    [1 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

subplot(2,1,2)
PSD_before_2_mean = mean(PSD_before_2, 1);
PSD_before_2_std = std(PSD_before_2, 0, 1) ./ sqrt(size(PSD_before_2, 1));
plot(f(1:index), PSD_before_2_mean, 'LineWidth', 2);
hold on
fill([f(1:index), fliplr(f(1:index))], [(PSD_before_2_mean + PSD_before_2_std), fliplr(PSD_before_2_mean - PSD_before_2_std)], ...
    [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
hold on
PSD_after_2_mean = mean(PSD_after_2, 1);
PSD_after_2_std = std(PSD_after_2, 0, 1);
plot(f(1:index), PSD_after_2_mean, 'LineWidth', 2);
hold on
fill([f(1:index), fliplr(f(1:index))], [(PSD_after_2_mean + PSD_after_2_std), fliplr(PSD_after_2_mean - PSD_after_2_std)], ...
    [1 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

% Frequency bands names
band_names = {'Theta', 'Alpha', 'Beta', 'Gamma'};

%% Statistical analysis: Paired t-test (comparing the differences before and after stimulation in each frequency band)
p_values = zeros(1, 5);
significant = false(1, 5);

for band = 1:4
    % Extract all signal data from the current frequency band
    pre_data = POWER_before_2(:, band);
    post_data = POWER_after_2(:, band);
    
    % Perform paired t-test
    [~, p] = ttest(pre_data, post_data);
    p_values(band) = p;
    
    % Mark significance (α=0.05)
    significant(band) = p < 0.05;
end

%% Calculate the mean and standard deviation
mean_pre = mean(POWER_before_2, 1);
mean_post = mean(POWER_after_2, 1);
std_pre = std(POWER_before_2, 0, 1);
std_post = std(POWER_after_2, 0, 1);

%% Draw a grouped bar chart
figure('Position', [100, 100, 500, 600]);

% Create a grouped bar chart
bar_width = 0.35;
x = 1:4;

% Draw a bar chart before stimulation
b1 = bar(x - bar_width/2, mean_pre, bar_width, 'FaceColor', '#669fde');
hold on;

% Draw a bar chart after stimulation
b2 = bar(x + bar_width/2, mean_post, bar_width, 'FaceColor', '#ec9073');

% Add error bars (standard deviation)
errorbar(x - bar_width/2, mean_pre, std_pre, 'k.', 'LineWidth', 1, 'CapSize', 10);
errorbar(x + bar_width/2, mean_post, std_post, 'k.', 'LineWidth', 1, 'CapSize', 10);

%% Add significant markers
y_max = max([mean_pre + std_pre, mean_post + std_post]) * 1.2;

for band = 1:4
    if significant(band)
        % Draw an asterisk mark
        plot([x(band) - bar_width/2, x(band) + bar_width/2], [y_max*0.95, y_max*0.95], 'k-', 'LineWidth', 1.2);
        text(x(band), y_max, '*', 'FontSize', 20, 'HorizontalAlignment', 'center');
        
        % Add p-value text
        text(x(band), y_max*0.85, sprintf('p=%.4f', p_values(band)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
    end
end

%% Graphic beautification
% Set coordinate axes and labels
set(gca, 'XTick', x, 'XTickLabel', band_names, 'FontSize', 12);
ylabel('Power', 'FontSize', 14);
title('Comparison of energy in different frequency bands before and after stimulation', 'FontSize', 16);
legend([b1, b2], {'before stim.', 'after stim.'}, 'Location', 'best');

% Set grid and background
grid on;
set(gca, 'YGrid', 'on', 'XGrid', 'off');
set(gcf, 'Color', 'w');

ylim([0, 0.82]);

hold off;
