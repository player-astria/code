% EEGLAB history file generated on the 27-May-2025
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','oddball_250502_sub010_5.set','filepath','D:\\Github\\data\\oddball_202503\\EEGdata\\EEG preprocessed data\\removed_automatically\\ICA\\automatically_rejected\\Mastoid\\');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
figure;pop_topoplot(EEG, 1, 300,'oddball_250502_sub010_5.cdt_intchan_avg_filt epochs pruned with ICA',[1 1] ,0,'electrodes','on');
pop_topoplot(EEG, 1, [-450:20:890] ,'oddball_250502_sub010_5.cdt_intchan_avg_filt epochs pruned with ICA',[8 9] ,0,'electrodes','on');
eeglab redraw;
