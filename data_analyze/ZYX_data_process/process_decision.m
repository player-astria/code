clear
clc
% addpath('/Applications/eeglab2024.2.1');
eeglab
close all

%read in Data (still to modify)
%"THE GREAT CHANGE"
load('montage_for_topoplot.mat');
read_dir = 'D:\ISRR-EEG_data_analysis\Formal EEG data analysis\Data\EEG preprocessed data\decision\sd_all\';   %There is your EEG preprocessed data with the respective reference you are interested in.
baselinestart = ((1000-200)/(1000/EEG.srate))+1; %from -200, as the segments start here from -1000, sampling rate set above
baselinestop =	((1000-0)/(1000/EEG.srate))+1; % to 0, as the segments start here from -1000, sampling rate set above
Segementation_time_start = -1;
Segementation_time_end = 2;

%select the files that are in the relevant directory:
files = dir([read_dir '*.set']);
filenames = {files.name}';
%How many participants / files are there ?
SubjectNum = size(filenames,1);

% choose epoches
ProcessEpoches_decision;

%Creating all needed arrays: Here only mean_signal array and mean_theta array, but other arrays are possible (e.g. signle trial array shown for signal here)
% erp_mean_ChoiceOnset(:,:,:,:) = nan(SubjectNum,size(SrInfoCases,2), EEG.nbchan, (Segementation_time_end-Segementation_time_start)*EEG.srate, 'single');		    %4D array: VP,CASES,ELECTRODES,TIMES
erp_mean_ChoiceOnset(:,:,:,:) = nan(SubjectNum,2, EEG.nbchan, (Segementation_time_end-Segementation_time_start)*EEG.srate, 'single');		    %4D array: VP,CASES,ELECTRODES,TIMES

%Create an array only to visually quickly check whether a case / condition is given in a participant and if so how many times.
% Casecheck (:,:) = zeros(SubjectNum,size(SrInfoCases,2), 'single');
Casecheck (:,:) = zeros(SubjectNum,2, 'single');

for P = 1:SubjectNum
    EEG = pop_loadset('filename',filenames{P},'filepath',read_dir);									%load set (first time)	-> Reason for this here: in case of error, the file is not loaded every case but only if something is done correctly
    % 选择对social role分类的方式
    block_num = filenames{P}(strfind(filenames{P},'.set')-2:strfind(filenames{P},'.set')-1);
    if strcmp(block_num, '01') || strcmp(block_num, '02') || strcmp(block_num, '03')
        cd_replace_markers_decision; %93个social roles为一类，baseline为一类
        DecisionCases = DecisionCases_cd;
    elseif strcmp(block_num, '04') || strcmp(block_num, '05') || strcmp(block_num, '06')
        sd_replace_markers_decision; %93个social roles为一类，baseline为一类
        DecisionCases = DecisionCases_sd;
    end

    for CASES = 1:size(DecisionCases,2)

        try % see whether the relevant segements are there... else do the next iteration
            EEG = pop_epoch(EEG, DecisionCases(CASES), [-5.6 4], 'epochinfo', 'yes'); %select trials
            EEG = pop_select(EEG,'time',[-2 4]);
            EEG = pop_epoch(EEG, DecisionCases(CASES),[-1 2]);
            [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); %#ok<*ASGLU>
            EEG = eeg_checkset( EEG );

            % baseline correction
            for i = 1:size(EEG.data,1)
                for j = 1:size(EEG.data,3)
                    EEG.data (i,:,j) = EEG.data (i,:,j) - nanmean(EEG.data(i,baselinestart:baselinestop,j),2);
                end
            end

            %%%"THE GREAT CHANGE": Choose your desired mean signals and frequencies
            erp_mean_ChoiceOnset(P,CASES,1:size(EEG.data,1),1:size(EEG.data,2))  = single(nanmean(EEG.data,3));	            %4D array: VP,CASES,ELECTRODES,TIMES


            %Count the trials in the conditions and create a casecheck array
            try %#ok<*TRYNC>
                if size(EEG.data) == [EEG.nbchan,EEG.pnts] %#ok<*BDSCA>
                    Casecheck(P,CASES) =  single(1);                                  %2D array: VP,CASES
                end
            end
            try
                if size(EEG.data,3)>1
                    Casecheck(P,CASES) = single(size(EEG.data,3));                    %2D array: VP,CASES
                end
            end

            STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];	    %#ok<*NASGU> %clear the EEG sets
            EEG = pop_loadset('filename',filenames{P},'filepath',read_dir);       %reload data here if something was cut from it

            block_num = filenames{P}(strfind(filenames{P},'.set')-2:strfind(filenames{P},'.set')-1);
            if strcmp(block_num, '01') || strcmp(block_num, '02') || strcmp(block_num, '03')
                cd_replace_markers_decision; %93个social roles为一类，baseline为一类
            elseif strcmp(block_num, '04') || strcmp(block_num, '05') || strcmp(block_num, '06')
                sd_replace_markers_decision; %93个social roles为一类，baseline为一类
            end

        end %try end: If this condition can not be found, then simply start from here -> next condition
    end
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];		    %clear the EEG sets
end
size(erp_mean_ChoiceOnset)
Decision_ERP = erp_mean_ChoiceOnset(:,:,:,1:750);
% save('Decision_ERP_sd', '-v7.3')

%% 将ERP数据从文件维度降为被试维度
% 统计每个被试有几个文件
current_ID = '001';
file_num = 0;
file_nums = {};
for i = 1:length(filenames)
    subID = filenames{i}(strfind(filenames{i},'sub')+3:strfind(filenames{i},'sub')+5);
    if strcmp(subID, current_ID)
        file_num = file_num + 1;
    elseif ~strcmp(subID, current_ID)
        file_nums = [file_nums; file_num];
        file_num = 1;
        current_ID = subID;
    end
end
file_nums = [file_nums; file_num];
file_nums = cell2mat(file_nums);
% 对每个被试的n个文件平均
[n, d2, d3, d4] = size(Decision_ERP);
subj_num = numel(file_nums);
subjs_Decision_ERP = [];
start_idx = 1;
for i = 1:subj_num
    current_size = file_nums(i);
    end_idx = start_idx + current_size -1;
    % 如果超出数据范围则跳过
    if end_idx > n
        break;
    end
    % 计算当前被试n个文件的均值
    subj_Decision_ERP = nanmean(Decision_ERP(start_idx:end_idx,:,:,:), 1);
    subjs_Decision_ERP = [subjs_Decision_ERP; subj_Decision_ERP];
end
SubjectNum = size(subjs_Decision_ERP,1);
save('Decision_ERP_sd', '-v7.3')