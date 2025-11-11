clear
clc
% addpath('/Applications/eeglab2024.2.1');
eeglab
close all

%read in Data (still to modify)
%"THE GREAT CHANGE"
load('montage_for_topoplot.mat');
read_dir = 'D:\Github\data\oddball_202503\EEGdata\EEG preprocessed data\removed_automatically\ICA\automatically_rejected\Mastoid\';   %There is your EEG preprocessed data with the respective reference you are interested in.
baselinestart = ((500-200)/(1000/EEG.srate))+1; %from -200, as the segments start here from -1000, sampling rate set above
baselinestop =	((500-0)/(1000/EEG.srate))+1; % to 0, as the segments start here from -1000, sampling rate set above
Segementation_time_start = -0.5;
Segementation_time_end = 1;

%select the files that are in the relevant directory:
files = dir([read_dir '*.set']);
filenames = {files.name}';
%How many participants / files are there ?
fileNum = size(filenames,1);


epochnums_subjs=[];
casenum=6;

%Creating all needed arrays: Here only mean_signal array and mean_theta array, but other arrays are possible (e.g. signle trial array shown for signal here)
erp_mean_stimstart(:,:,:,:) = nan(fileNum, casenum,EEG.nbchan, (Segementation_time_end-Segementation_time_start)*EEG.srate, 'single');		    %4D array: VP,CASES,ELECTRODES,TIMES
erp_trial_stimstart(:,:,:,:,:) = nan(fileNum, casenum-1,EEG.nbchan, (Segementation_time_end-Segementation_time_start)*EEG.srate, 9,'single');		    %4D array: VP,CASES,ELECTRODES,TIMES,trialnum
%Create an array only to visually quickly check whether a case / condition is given in a participant and if so how many times.
% Casecheck (:,:) = zeros(SubjectNum,size(SrInfoCases,2), 'single');
Casecheck (:,:) = zeros(fileNum,casenum, 'single');

%%% step9
for P = 1:fileNum
    EEG = pop_loadset('filename',filenames{P},'filepath',read_dir);									%load set (first time)	-> Reason for this here: in case of error, the file is not loaded every case but only if something is done correctly
    % 对附带伤害类型进行分类,并将六种类型放在oddball_cdtype中（1-child,2-pregnant,3-civilian,4-drug,5-criminal,6-none）
    replace_markers_oddball
    CASEARRAY = oddball_cdtype;

    epochnums=[];
    for CASES = 1:size(CASEARRAY,2) 
        try % see whether the relevant segements are there... else do the next iteration
            EEG = pop_epoch( EEG, {CASEARRAY{CASES}}, [Segementation_time_start Segementation_time_end ], 'epochinfo', 'yes'); %selection here: -0.5 to 1 seconds 
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
            EEG = eeg_checkset( EEG ); 

            %计算使用的段数
            epochnum = ALLEEG.trials;
            epochnums = [epochnums, epochnum];

            % baseline correction
            for i = 1:size(EEG.data,1)
                for j = 1:size(EEG.data,3)
                    EEG.data (i,:,j) = EEG.data (i,:,j) - nanmean(EEG.data(i,baselinestart:baselinestop,j),2);
                end
            end

            %%%计算各导各采样点，所有段的平均
            erp_mean_stimstart(P,CASES,1:size(EEG.data,1),1:size(EEG.data,2))  = single(nanmean(EEG.data,3));	            %4D array: VP,CASES,ELECTRODES,TIMES
            %统计所有数据（无附带伤害不纳入分析，故不保存）
            if CASES ~= 6
            erp_trial_stimstart(P,CASES,1:size(EEG.data,1),1:size(EEG.data,2),1:epochnum) = single(EEG.data);
            end

            %Count the trials in the conditions and create a casecheck array
            try %检查是二维还是三维（是三维）
                if size(EEG.data) == [EEG.nbchan,EEG.pnts] %[64 375]
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
            replace_markers_oddball

        end %try end: If this condition can not be found, then simply start from here -> next condition
    end
    epochnums_subjs = [epochnums_subjs;epochnums];
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];		    %clear the EEG sets
end
size(erp_mean_stimstart)
Decision_ERP = erp_mean_stimstart(:,:,:,1:375);
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
subjs_oddball_ERP = [];
subjs_oddball_trial_ERP = nan(subj_num,5,64,375,45);
start_idx = 1;
% 有个被试莫名多出一个trial，应该是分段重叠之类的问题，只采用前9个trial
erp_trial_stimstart = erp_trial_stimstart(:,:,:,:,1:9);
for i = 1:subj_num
    current_size = file_nums(i);
    end_idx = start_idx + current_size -1;
    % 如果超出数据范围则跳过
    if end_idx > n
        break;
    end
    %统合所有被试数据
    subj_oddball_trial_ERP_one = erp_trial_stimstart(start_idx:end_idx,1:5,:,:,:);
    subj_oddball_trial_ERP = reshape(subj_oddball_trial_ERP_one, 1, 5, 64,375,[]);
    subjs_oddball_trial_ERP(i,:,:,:,1:size(subj_oddball_trial_ERP,5)) = subj_oddball_trial_ERP;
    % 计算当前被试n个文件的均值
    subj_oddball_ERP = nanmean(Decision_ERP(start_idx:end_idx,:,:,:), 1);
    subjs_oddball_ERP = [subjs_oddball_ERP; subj_oddball_ERP];
    start_idx = end_idx+1;
end
fileNum = size(subjs_oddball_ERP,1);
save('oddball_trial', '-v7.3')