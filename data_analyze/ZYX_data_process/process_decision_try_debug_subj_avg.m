clear
clc
% addpath('/Applications/eeglab2024.2.1');
eeglab
close all

%read in Data (still to modify)
%"THE GREAT CHANGE"
load('montage_for_topoplot.mat');
read_dir = 'D:\ISRR-EEG_data_analysis\Formal EEG data analysis\Data\EEG preprocessed data\decision\sd_all_new\';   %There is your EEG preprocessed data with the respective reference you are interested in.
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

%%%%%%%%计算trial级数据，不在文件级求均值%%%%%%%%%%%%%%%
erp_all_trials = cell(SubjectNum, 2);

for P = 1:SubjectNum
    EEG = pop_loadset('filename',filenames{P},'filepath',read_dir);									%load set (first time)	-> Reason for this here: in case of error, the file is not loaded every case but only if something is done correctly
%     % 选择对social role分类的方式
%     block_num = filenames{P}(strfind(filenames{P},'.set')-2:strfind(filenames{P},'.set')-1);
%     if strcmp(block_num, '01') || strcmp(block_num, '02') || strcmp(block_num, '03')
%         sd_replace_markers; %93个social roles为一类，baseline为一类
%         SrInfoCases = SrInfoCases_sd;
%     elseif strcmp(block_num, '04') || strcmp(block_num, '05') || strcmp(block_num, '06')
%         sd_replace_markers; %93个social roles为一类，baseline为一类
%         SrInfoCases = SrInfoCases_sd;
%     end
        
        %%%%%全部都是sd，直接sd_replace_markers就行%%%%%%
        sd_replace_markers_decision;
        DecisionCases = DecisionCases_sd;

    for CASES = 1:size(DecisionCases,2)

        try % see whether the relevant segements are there... else do the next iteration
            EEG = pop_epoch(EEG, DecisionCases(CASES), [-1  2], 'epochinfo', 'yes'); %select trials
            % EEG = pop_select(EEG,'time',[-2 3]);
            % EEG = pop_epoch(EEG, DecisionCases(CASES),[-1 2]);
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
            
            %%%%%%%%%%%%%%%不计算ERP，直接存储trial数据%%%%%%%%%%%%%%%%%%%%
            erp_all_trials{P, CASES} = EEG.data;

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

%             block_num = filenames{P}(strfind(filenames{P},'.set')-2:strfind(filenames{P},'.set')-1);
%             if strcmp(block_num, '01') || strcmp(block_num, '02') || strcmp(block_num, '03')
%                 sd_replace_markers; 
%             elseif strcmp(block_num, '04') || strcmp(block_num, '05') || strcmp(block_num, '06')
%                 sd_replace_markers; 
%             end

                %%%%%全部都是sd，直接sd_replace_markers就行%%%%%%
                sd_replace_markers_decision;
                DecisionCases = DecisionCases_sd;

        end %try end: If this condition can not be found, then simply start from here -> next condition
    end
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];		    %clear the EEG sets
end
size(erp_mean_ChoiceOnset)
Decision_ERP = erp_mean_ChoiceOnset(:,:,:,1:750);
% save('Decision_ERP_sd', '-v7.3')

%% 计算被试级别的ERP
SubjectNum = 31; %一共有31个被试！（将SubjectNum从文件数改为被试数）
subj_trials = cell(SubjectNum,2);
for i = 1:SubjectNum
    %获取当前被试的所有文件
    file_indices = find(contains(filenames, ['sub' num2str(i,'%03d')]));
    %合并baseline
    % 存在缺失的baseline，先过滤空的baseline
    valid_baseline_trials = erp_all_trials(file_indices,1);
    valid_baseline_trials =  valid_baseline_trials(~cellfun(@isempty, valid_baseline_trials));
    if ~isempty(valid_baseline_trials)
            all_baseline_trials = cat(3,valid_baseline_trials{:}); %电极*750*baseline数量
            subj_trials{i,1} = mean(all_baseline_trials,3); % 电极*750（baseline平均）
    else
        subj_trials{i,1} = nan(62,750); %没有baseline，赋NaN
    end
    % 合并social role trials
    all_sr_trials = cat(3, erp_all_trials{file_indices,2}); %电极*750*sr_trial数量
    subj_trials{i,2} = all_sr_trials;

end
subjs_decision_ERP = nan(SubjectNum, 2, 62, 750, 'single');
for i = 1:SubjectNum
    % baseline trial
    subjs_decision_ERP(i,1,:,:) = single(subj_trials{i,1});
    % social role trials
    subjs_decision_ERP(i,2,:,:) = single(nanmean(subj_trials{i,2},3));
end
save('Decision_ERP_sd', '-v7.3')