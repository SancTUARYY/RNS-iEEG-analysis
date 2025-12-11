% The 'phase_locking' script is used for iEEG signal phase locking value calculation
close all

% Please fill in the directory where the target EDF files is located in the 'pathname' variable
pathname = [''];
file_list = dir(fullfile(pathname, '*.edf'));
fs = 200;                               % Sampling frequency
duration = 10;                     % Duration of the signal for analysis
before_time = 45;               % Start time of the signal for analysis (before)
after_time = 75;               % Start time of the signal for analysis (after)

%% ========== First image: Single signal multi band analysis ==========
figure('Name', 'Single iEEG signal lock-in analysis', 'Position', [100 100 1200 800]);

% Define the standard frequency band range (unit: Hz)
freq_bands = {
    'Delta',   [1, 4];
    'Theta',   [4, 8];
    'Alpha',   [8, 13];
    'Beta',    [13, 30];
    'Gamma',   [30, 80]
};
raw  = ft_read_data('');
target_signal_1 = raw(:, before_time*fs : before_time*fs+duration*fs-1);
target_signal_2 = raw(:, after_time*fs : after_time*fs+duration*fs-1);
len = length(target_signal_1);
t = (1/fs:1/fs:len/fs);

for iBand = 1:size(freq_bands, 1)
    band_name = freq_bands{iBand, 1};
    band_range = freq_bands{iBand, 2};
    
    % Design a bandpass filter
    [b, a] = butter(4, band_range/(fs/2), 'bandpass');
    
    % Channel 1 processing
    ch1_filt = filtfilt(b, a, target_signal_1(1, :));
    analytic1 = hilbert(ch1_filt);
    phase1 = angle(analytic1);
    % Channel 2 processing
    ch2_filt = filtfilt(b, a, target_signal_1(2, :));
    analytic2 = hilbert(ch2_filt);
    phase2 = angle(analytic2);
    % Calculate phase difference
    phase_diff_1 = phase1 - phase2;
    
    % Draw the original signal before stimulation
    subplot(5, 4, (iBand-1)*4 + 1);
    plot(t, ch1_filt);
    hold on;
    plot(t, ch2_filt);
    ylim([-200 200])
    grid on;

    % Draw phase difference distribution (polar coordinates)
    subplot(5, 4, (iBand-1)*4 + 2);
    polarhistogram(phase_diff_1, 20, 'FaceColor', [0.2 0.6 0.8]);
    title(sprintf('PLV = %.3f', abs(mean(exp(1i*phase_diff_1)))));
    grid on;

    % Channel 1 processing
    ch1_filt = filtfilt(b, a, target_signal_2(1, :));
    analytic1 = hilbert(ch1_filt);
    phase1 = angle(analytic1);
    % Channel 2 processing
    ch2_filt = filtfilt(b, a, target_signal_2(2, :));
    analytic2 = hilbert(ch2_filt);
    phase2 = angle(analytic2);
    % Calculate phase difference
    phase_diff_2 = phase1 - phase2;
    
    % Draw the original signal before stimulation
    subplot(5, 4, (iBand-1)*4 + 3);
    plot(t, ch1_filt);
    hold on;
    plot(t, ch2_filt);
    ylim([-200 200])
    grid on;
    
    % Draw phase difference distribution (polar coordinates)
    subplot(5, 4, (iBand-1)*4 + 4);
    polarhistogram(phase_diff_2, 20, 'FaceColor', [0.2 0.6 0.8]);
    title(sprintf('PLV = %.3f', abs(mean(exp(1i*phase_diff_2)))));
    grid on;
end

%% ========== Second image: PLV statistical analysis ==========
% initialization
pre_plv = zeros(length(file_list), 5); 
post_plv = zeros(length(file_list), 5);
p_values = zeros(1, 5); 
significance_level = 0.05; 

% Calculate the PLV of all signals
for iSig = 1:length(file_list)
    filename = file_list(iSig).name;
    file = fullfile(pathname, filename);
    fprintf('file %d/%d: %s\n', iSig, length(file_list), filename);
    LFP_data = ft_read_data(file);
    LFP_PSD_data_before = LFP_data(:, before_time*fs : before_time*fs+duration*fs-1);
    LFP_PSD_data_after = LFP_data(:, after_time*fs : after_time*fs+duration*fs-1);
    L = length(LFP_PSD_data_before);

    for iBand = 1:5
        band_range = freq_bands{iBand, 2};
        
        % Design filters
        [b, a] = butter(4, band_range/(fs/2), 'bandpass');
        
        % Processing pre stimulus signals
        sig_pre = LFP_PSD_data_before;
        ch1_pre = filtfilt(b, a, sig_pre(1, :));
        ch2_pre = filtfilt(b, a, sig_pre(2, :));
        phase1_pre = angle(hilbert(ch1_pre));
        phase2_pre = angle(hilbert(ch2_pre));
        phase_diff_pre = phase1_pre - phase2_pre;
        pre_plv(iSig, iBand) = abs(mean(exp(1i*phase_diff_pre)));
        
        % Processing after stimulus signals
        sig_post = LFP_PSD_data_after;
        ch1_post = filtfilt(b, a, sig_post(1, :));
        ch2_post = filtfilt(b, a, sig_post(2, :));
        phase1_post = angle(hilbert(ch1_post));
        phase2_post = angle(hilbert(ch2_post));
        phase_diff_post = phase1_post - phase2_post;
        post_plv(iSig, iBand) = abs(mean(exp(1i*phase_diff_post)));
    end
end

% compute statistics
mean_pre = mean(pre_plv);
std_pre = std(pre_plv);
mean_post = mean(post_plv);
std_post = std(post_plv);

% Perform paired t-test
for iBand = 1:5
    [~, p] = ttest(pre_plv(:, iBand), post_plv(:, iBand));
    p_values(iBand) = p;
end

% Draw a statistical chart
figure('Name', 'Comparison of PLV before and after stimulation', 'Position', [100 100 600 850]);
band_names = {freq_bands{:,1}};
x = 1:numel(band_names);
bar_width = 0.35;

% Before the stimulus (blue)
bar(x - bar_width/2, mean_pre, bar_width, 'DisplayName', 'before stim.', 'FaceColor', '#669fde');
hold on;

% After the stimulus (red)
bar(x + bar_width/2, mean_post, bar_width, 'DisplayName', 'after stim.', 'FaceColor', '#ec9073');

% Add error bars (standard deviation)
errorbar(x - bar_width/2, mean_pre, std_pre, 'k.', 'LineWidth', 1);
errorbar(x + bar_width/2, mean_post, std_post, 'k.', 'LineWidth', 1);

% Beautify graphics
set(gca, 'XTick', x, 'XTickLabel', band_names);
ylabel('PLV');
title('Comparison of PLV in various frequency bands before and after stimulation (Mean ± SD)');
legend('show', 'Location', 'best');
ylim([0,0.3])
grid on;
hold off;