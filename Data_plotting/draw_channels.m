% The 'draw_channels' script is used for plotting channel signals
close all
% Read EDF file and load iEEG data
iEEG_data = ft_read_data('');

% Plot waveform - 2 channels
for i = 1:2
    plot(iEEG_data(i, :) - 5000*(i-1));
    hold on
end