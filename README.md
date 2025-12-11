# Source code for: Dataset of long-term iEEG invasively recorded in epilepsy patients implanted with responsive neurostimulation system (RNS)

## Introduction

This repository contains the codes that relate to our paper 'Dataset of long-term iEEG invasively recorded in epilepsy patients implanted with responsive neurostimulation system (RNS). We provided some MATLAB scripts to technically validate the iEEG dataset, including channel signals plotting, power spectrum analysis, envelop length calculation, phase locking value calculation, etc.

Abstract:

> This work provided a long-term intracranial electroencephalography (iEEG) dataset of 8 epilepsy patients implanted with responsive neurostimulation (RNS) devices. The dataset was constituted by iEEG data recorded from bilateral epileptic lesion areas.
>
> Each recording contains 90 seconds of dual-channel iEEG around each stimulation, 60 seconds before the start of the stimulation, and about 30 seconds after the end of the stimulation. The stimulation markers are contained in the events.tsv files, including the onset and duration for each stimulus. The ieeg.json files contain the electrical stimulation parameters for the current session, which were set by the neurosurgeon during each regular clinical follow-up of epilepsy patients. 
>
> The iEEG data were saved in EDF format, stored as the Brain Imaging Data Structure (BIDS), and published on the OpenNeuro. The criterion for including patients in this dataset is to intracranially record the seizure events for more than six months. For each subject, one week is considered as a session, which includes all seizures within a day with high frequency seizure onset during that week.
>
> The dataset can be used to evaluate the alterations of seizure onset pattern during the development of epilepsy, as well as the changes in iEEG characteristics after the electrical stimulation. We have technically validated the dataset through specific signal analysis, such as power spectral analysis, calculation of envelop length, and calculation of phase locking value.

## Installation - Code

The code in this repository can be downloaded by entering the following commands:

```
cd $target_directory
git clone https://github.com/SancTUARYY/epilepsy-analysis.git
```

## Installation - FieldTrip

To install the FieldTrip toolbox on your computer, you can clone the repository or download the zip file ([fieldtrip/fieldtrip: The MATLAB toolbox for MEG, EEG and iEEG analysis](https://github.com/fieldtrip/fieldtrip)), unzip it, and add it to your MATLAB path. Subsequently you call the `ft_defaults` function, which will add the required subdirectories to the path.

We recommend that you add the `addpath(...)` and the `ft_defaults` command to your [startup.m](https://www.mathworks.com/help/matlab/ref/startup.html) file. See also https://www.fieldtriptoolbox.org/faq/installation/

Note that you should not use `addpath(genpath(...))` and we recommend not to use the "add with subdirectories" button in the graphical path setup tool, as there are a number of external toolboxes and backward compatibility directories that you should not add to your path. If those directories are needed, then `ft_defaults` and `ft_hastoolbox` will take care of them.

## Data Plotting

Here we provide the sample code for plotting data from EDF files in the iEEG dataset. 

- Download MATLAB script `draw_channels.m`. Make sure that the FieldTrip toolbox has been installed. First, set the parameter of the `ft_read_data` function to the path of the EDF file, and two-channel signal will be stored in the `iEEG_data` parameter. Run the script to get the channel signals and plot them.


## MATLAB Analysis

- **Power Spectral Analysis:** Download MATLAB script `powerspec.m`. First, set `pathname` as the directory where the target EDF file is located. Second, initialize the variables. Set `fre_high` as the upper limit frequency of the spectrum analyzed. Set `before_time` as the start time of the signal (before stimulation) for analysis, `after_time` as the start time of the signal (after stimulation) for analysis, and set `duration` as the duration of the signal for analysis. Third, Welch method will be used to calculate the PSD of the iEEG signal (`pwelch` function, with 0.64 s Hamming window and 78.1% overlap by default). The parameters of `noverlap`, `nfft`, `window`, and `n_segments` can be adjusted according to the duration of the signal. Figure 1 plots the PSD of two iEEG channels before and after the stimulation. Fourth, paired t-test is used to compare the differences before and after stimulation in each frequency band (Theta (4-8Hz), Alpha (9-12Hz), Beta(13-30Hz), Gamma(31-80Hz)), and Figure 2 shows the statistical results obtained.
- **Envelop Length Calculation:** Download MATLAB script `envelope_length.m`. First, set `pathname` as the directory where the target EDF file is located. Second, initialize the variables. Set `before_time` as the start time of the signal (before stimulation) for analysis, `after_time` as the start time of the signal (after stimulation) for analysis, and set `duration` as the duration of the signal for analysis. Set `channel` as the selected channel. Third, bandpass filter the iEEG signals in each frequency band (Delta (1-4Hz), Theta (4-8Hz), Alpha (9-12Hz), Beta(13-30Hz), Gamma(31-80Hz)). Fourth, the envelopes of iEEG signals in the aforementioned frequency bands were extracted using Hilbert transform. Fifth, the changes in envelope length of each frequency band before and after stimulation are calculated and statistically analyzed, as is shown in Figure 2.
- **Phase Locking Value (PLV) Calculation:** Download MATLAB script `phase_locking.m`. First, set `pathname` as the directory where the target EDF file is located. Second, initialize the variables. Set `before_time` as the start time of the signal (before stimulation) for analysis, `after_time` as the start time of the signal (after stimulation) for analysis, and set `duration` as the duration of the signal for analysis. Third, bandpass filter the iEEG signals in each frequency band (Delta (1-4Hz), Theta (4-8Hz), Alpha (9-12Hz), Beta(13-30Hz), Gamma(31-80Hz)). Fourth, the instantaneous phase of each frequency band signal is obtained through Hilbert transform, and the phase difference between the two channels is calculated to obtain the phase-locked value (PLV) of each frequency band, as is shown in Figure 1. Fifth, the changes in PLV of each frequency band before and after stimulation are calculated and statistically analyzed, as is shown in Figure 2.

## Contributors

- Haoqi Ni
- Chen Feng













