% The 'envelope_length' script is used for iEEG signal envelope length calculation
close all

% Please fill in the directory where the target EDF files is located in the 'pathname' variable
pathname = [''];
file_list = dir(fullfile(pathname, '*.edf'));

fs = 200;                               % Sampling frequency
duration = 10;                     % Duration of the signal for analysis
before_time = 45;               % Start time of the signal for analysis (before)
after_time = 75;               % Start time of the signal for analysis (after)
chn_select = 1;

%% ========== First image: Single signal multi band analysis ==========
figure('Name', 'Single iEEG signal frequency band decomposition', 'Position', [100 100 1200 800]);

% Define the standard frequency band range (unit: Hz)
freq_bands = {
    'Delta',   [1, 4];
    'Theta',   [4, 8];
    'Alpha',   [8, 13];
    'Beta',    [13, 30];
    'Gamma',   [30, 80]
};
raw  = ft_read_data('');
target_signal = raw(chn_select, before_time*fs : before_time*fs+duration*fs-1);

for iBand = 1:size(freq_bands, 1)
    band_name = freq_bands{iBand, 1};
    band_range = freq_bands{iBand, 2};
    
    % Design a bandpass filter
    [b, a] = butter(4, band_range/(fs/2), 'bandpass');
    
    % Filter&Hilbert transform to extract envelope
    filtered_sig = filtfilt(b, a, target_signal);
    analytic_sig = hilbert(filtered_sig);
    envelope_sig = abs(analytic_sig);
    
    subplot(3, 2, iBand);
    
    % Draw the original filtered signal (blue) and envelope (red)
    plot(filtered_sig, 'LineWidth', 0.8); 
    hold on;
    plot(envelope_sig, 'LineWidth', 1.5);
    hold off;
    
    title(sprintf('%s band (%d-%d Hz)', band_name, band_range(1), band_range(2)));
    xlabel('Aampling point');
    ylabel('Amplitude');
    legend('Filtered signal', 'envelope', 'Location', 'best');
    grid on;
    set(gca, 'FontSize', 10);
end

%% ========== Second image: Envelope energy statistics before and after stimulation ==========
% Calculate the envelope energy of each signal in each frequency band (i.e. area under the envelope curve ≈ frequency band power)
pre_length = zeros(length(file_list), 5); 
post_length = zeros(length(file_list), 5); 
p_values = zeros(1, 5); 
significance_level = 0.05; 

for i = 1:length(file_list)
    filename = file_list(i).name;
    file = fullfile(pathname, filename);
    fprintf('File %d/%d: %s\n', i, length(file_list), filename);
    LFP_data = ft_read_data(file);
    LFP_PSD_data_before = LFP_data(chn_select, before_time*fs : before_time*fs+duration*fs-1);
    LFP_PSD_data_after = LFP_data(chn_select, after_time*fs : after_time*fs+duration*fs-1);
    L = length(LFP_PSD_data_before);
    % Processing pre stimulus signals
    for iBand = 1:size(freq_bands, 1)
        band_range = freq_bands{iBand, 2};
        [b, a] = butter(4, band_range/(fs/2), 'bandpass');
        filtered_pre = filtfilt(b, a, LFP_PSD_data_before);
        envelope_pre = abs(hilbert(filtered_pre));
        % Calculate envelope length (Total length of curve = Σ√(Δx² + Δy²))
        dx = 1;
        dy = diff(envelope_pre); 
        pre_length(i, iBand) = sum(sqrt(dx^2 + dy.^2));
    end
    % Processing signals after stimulation
    for iBand = 1:size(freq_bands, 1)
        band_range = freq_bands{iBand, 2};
        [b, a] = butter(4, band_range/(fs/2), 'bandpass');
        filtered_post = filtfilt(b, a, LFP_PSD_data_after);
        envelope_post = abs(hilbert(filtered_post));
        dy = diff(envelope_post);
        post_length(i, iBand) = sum(sqrt(dx^2 + dy.^2));
    end
end

for iBand = 1:size(freq_bands, 1)
    % Perform paired t-test (pre stimulus vs post stimulus)
    [~, p] = ttest(pre_length(:, iBand), post_length(:, iBand));
    p_values(iBand) = p;
end

% Convert to matrix for statistical convenience
pre_energy_mat = pre_length;  % 10 rows x 5 columns (10 signals x 5 frequency bands)
post_energy_mat = post_length;

% Calculate the mean and standard deviation
mean_pre = mean(pre_energy_mat, 1);
std_pre = std(pre_energy_mat, 0, 1);
mean_post = mean(post_energy_mat, 1);
std_post = std(post_energy_mat, 0, 1);

% Draw a statistical bar chart
figure('Name', 'Comparison of frequency band energy before and after stimulation', 'Position', [100, 100, 500, 600]);
band_names = {freq_bands{:,1}};
x = 1:numel(band_names);
bar_width = 0.35;

% Before the stimulus (blue)
bar(x - bar_width/2, mean_pre, bar_width, 'DisplayName', 'Before stim.', 'FaceColor', '#669fde');
hold on;

% After the stimulus (red)
bar(x + bar_width/2, mean_post, bar_width, 'DisplayName', 'After stim.', 'FaceColor', '#ec9073');

% Add error bars (standard deviation)
errorbar(x - bar_width/2, mean_pre, std_pre, 'k.', 'LineWidth', 1);
errorbar(x + bar_width/2, mean_post, std_post, 'k.', 'LineWidth', 1);

% Beautify graphics
set(gca, 'XTick', x, 'XTickLabel', band_names);
ylabel('envelope energy (a.u.)');
title('Comparison of LFP energy in different frequency bands before and after stimulation (Mean ± SD)');
legend('show', 'Location', 'best');
grid on;
hold off;