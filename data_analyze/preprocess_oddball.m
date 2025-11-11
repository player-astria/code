% EEG预处理
%% Load data

% Initial
clear    					    % 清除workspace所有变量
clc								% 清除命令行窗口
% addpath('D:\ISRR-EEG_data_analysis\Formal EEG data analysis\eeglab2024.2'); % 添加eeglab路径
eeglab							% 打开eeglab
close all						% 关闭包含EEGlab GUI在内的所有窗口(恢复eeglab窗口指令：'eeglab redraw')

% 筛选并分别整理decision data & rating data
read_dir = 'D:\Github\data\oddball_202503\EEGdata\EEG raw data\'; % 选择处理的数据
write_dir = 'D:\Github\data\oddball_202503\EEGdata\EEG preprocessed data\'; % 存储预处理后的EEG data

% Dictionary settings
%mark important paths that are needed
check_dir = strcat(write_dir,'before_removal\'); % 保存去除坏导之前的数据
load_dir = strcat(write_dir,'removed_automatically\'); % 保存去除坏导之后的数据
%automatically create the folders that are needed. If you don´t want these to be created, just comment them out
mkdir(write_dir);
mkdir(check_dir);
mkdir(load_dir);
mkdir(strcat(load_dir,'ICA\')); % 保存ICA相关数据
mkdir(strcat(load_dir,'ICA\done_still_to_reject\')); %ICA之后还没有去伪迹的数据
mkdir(strcat(load_dir,'ICA\automatically_rejected\')); %ICA之后已去除伪迹的数据
mkdir(strcat(load_dir,'ICA\automatically_rejected\Mastoid\')); %参考电极换成双耳后乳突的数据
check_dir_mastoid = strcat(load_dir,'ICA\automatically_rejected\Mastoid\');

% EEG data files
% 查看有多少个EEG files，并读取EEG files文件名
files = dir([read_dir '*.cdt']); % 读取cdt文件列表
filenames = {files.name}';

Channelz_value_automatic_detection = 3.29; % Tabachnik & Fiedell, 2007 p. 73: 设置Outlier检测标准

% 文件数
COUNTPARTICIPANT = size(filenames,1);

% Cap包含的电极数
Number_of_EEG_electrodes_without_reference_and_ground = 64;

%% Preprocess data

for VP = 1:COUNTPARTICIPANT  %FOR EVERY FILE
	
    % 已经处理成.set的文件不会重复处理
    checkfiles = dir([check_dir_mastoid '*.set']); 	%look at all files in the check directory: the set format is the eeglab format
	checkfilenames = {checkfiles.name}';	%look at all file names there
	for checkfilesi = 1:size(checkfiles)	%for every file in there
        %"THE GREAT CHANGE" here you need to adjust the file format to the format of your recorded files (example is header file from brainvision)
		if strcmp(strrep(filenames{VP},'.cdt',''),strrep(checkfilenames{checkfilesi},'.set','')) == 1 	%check whether the present file is in there
			VP = VP +1;																					 %#ok<*FXSET> %if it is in there, then take the next file
		end
	end
    if VP>246
        break;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EEG = loadcurry(strcat(read_dir, filenames{VP}), 'KeepTriggerChannel', 'False', 'CurryLocations', 'True');	%LOAD THE DATA, all channels, all timepoints		
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',filenames{VP},'gui','off'); %#ok<*ASGLU> %in dataset 0 of EEGLab
% 
%     %delete data before the first marker(因为有时候在实验之前会先开始记录，所以有一段没有marker的时间，这段时间的数据可能较差，因为还没开始正式实验)
%     first_event_latency = min([EEG.event.latency]);
%     % 将采样点转换为时间（秒）
%     start_time = (first_event_latency - 1) / EEG.srate;
%     fprintf('第一个事件出现在 %.2f 秒处\n', start_time);
%     % 裁剪数据，保留从第一个事件开始的部分
%     EEG = pop_select(EEG, 'time', [start_time EEG.xmax]);

    %Resample the data as 250Hz 
    % EEG.data = detrend(EEG.data);
    EEG = pop_resample(EEG, 250); %降采样到250Hz
    %remove sc Heart (if you don´t have any, comment it out or use it for eye, we don´t need that any more as we use ICA for blink and eyemovement detection
    %"THE GREAT CHANGE"
    EEG = pop_select( EEG,'nochannel',{'HEO' 'VEO'});  %State the channels that you want to "ignore" insert your channel names  移除水平眼电和垂直眼电
    EEG = eeg_checkset( EEG ); % 检查修改后EEG data是否正常，通常没有返回值，如果有问题可能会返回问题
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	1-40Hz带通滤波
	EEG = pop_eegfiltnew(EEG, 'locutoff',1); 
	EEG = pop_eegfiltnew(EEG, 'hicutoff',40);    
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
	EEG = eeg_checkset( EEG );
    
     % 重参考（average）
     EEG = pop_reref( EEG, []); %,'refloc',struct('labels',{'Cz'},'type',{''},'theta',{0},'radius',{0},'X',{5.2047e-015},'Y',{0},'Z',{85},'sph_theta',{0},'sph_phi',{90},'sph_radius',{85},'urchan',{65},'ref',{''},'datachan',{0}));
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    EEG = eeg_checkset( EEG );
		
    % now we look for bad channels  去坏导
	
    [~, indelec1] = pop_rejchan(EEG, 'elec',1:Number_of_EEG_electrodes_without_reference_and_ground ,'threshold',Channelz_value_automatic_detection,'norm','on','measure','prob'); 		%we look for probability

	[~, indelec2] = pop_rejchan(EEG, 'elec',1:Number_of_EEG_electrodes_without_reference_and_ground ,'threshold',Channelz_value_automatic_detection,'norm','on','measure','kurt');	%we look for kurtosis 
	
    [~, indelec3] = pop_rejchan(EEG, 'elec',1:Number_of_EEG_electrodes_without_reference_and_ground ,'threshold',Channelz_value_automatic_detection,'norm','on','measure','spec','freqrange',[1 125] );	%we look for frequency spectra


    % now we look whether a channel is bad in multiple criteria 多标准判断channel是不是坏的
    index=sort(unique([indelec1,indelec2,indelec3])); %index is the bad channel array
    %save the bad channel array for every participant in a matrix 把每个被试的坏导存储为.mat文件
    for i = 1:size(index,2)
        VP_indexarray(VP,i) = index(1,i); %#ok<*SAGROW>
    end
    savename = strcat(write_dir,num2str(VP),'_removed_channels_auto.mat');  
    save(savename,'VP_indexarray', 'filenames');

    %Here we save the data before we remove the bad channels we have detected before
    % 保存去坏导之前的数据
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'),'filepath',strcat(write_dir,'before_removal\'));


    %remove channels because of index array
	%Interpolate Channels (Bad Channels)
    % 插值坏导 
    EEG = pop_interp(EEG, index, 'spherical'); %球面插值
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',strcat(filenames{VP},'_start'),'gui','off'); 
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'),'filepath',strcat(write_dir,'removed_automatically\'));
    EEG = eeg_checkset( EEG );
	
    clear indelec1 indelec2 indelec3 i 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%å
    % segmentation 分段
    oddball_first_segmentation;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Filter lowpass 1 Hz: because it gives a more stable ICA solution and works best with MARA
	% (Tools-> filter the data -> basic FIR filter (new, default) -> lower edge 1 
	%EEG = pop_eegfiltnew(EEG, [], 1, [], 1, [], 0); %%comment: These two filter displayed here are mathematically identical... notch vs. bandpass
%     EEG = pop_eegfiltnew(EEG, 'locutoff',1); % 1Hz highpass 高通滤波1Hz 只做1Hz高通ICA性能更好，后面处理数据再做1～30Hz的带通
    % EEG = pop_eegfiltnew(EEG, 48, 52, [], 1, [], 0); % notch filter 50Hz
	
	[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
	EEG = eeg_checkset( EEG );
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%first ICA: compute the ICA, takes some time....
	% EEG = pop_runica(EEG, 'extended',1,'interupt','on');
	EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'pca', Number_of_EEG_electrodes_without_reference_and_ground-size(index,2)); %this takes into account that we have extrapolated some channels and the rank of the matrix was reduced: Count original electrodes + reference - extrapolated channels
	
    %去坏段
    EEG = pop_jointprob(EEG,0,1:Number_of_EEG_electrodes_without_reference_and_ground-size(index,2) ,20,Channelz_value_automatic_detection,0,0,0,[],0);
	EEG = eeg_rejsuperpose( EEG, 0, 1, 1, 1, 1, 1, 1, 1);
	EEG = pop_rejkurt(EEG,0,1:Number_of_EEG_electrodes_without_reference_and_ground-size(index,2) ,20,Channelz_value_automatic_detection,2,0,1,[],0);
	EEG = eeg_rejsuperpose( EEG, 0, 1, 1, 1, 1, 1, 1, 1);
    %reject the selected bad segments !
    reject1 = EEG.reject; %save this for later approaches, for instance if intersted in LPP or other stuff with freq < 1 Hz
	EEG = pop_rejepoch( EEG, EEG.reject.rejglobal ,0);
	EEG = eeg_checkset( EEG );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%second ICA: again, takes some time... if no segments were rejected, the ICA will be the same. This can be good if the data is rather well...
    % this step is only one if data is rejected in step 5
    if sum(reject1.rejglobal) > 0
        EEG = pop_runica(EEG, 'extended',1,'interupt','on', 'pca', Number_of_EEG_electrodes_without_reference_and_ground-size(index,2)); %this takes into account that we have extrapolated some channels and the rank of the matrix was reduced: Count original electrodes + reference - extrapolated channels
    end
	[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',strcat(filenames{VP},'_all_arifact_filt1'),'overwrite','on','gui','off');
    EEG = eeg_checkset( EEG ); 
	EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'),'filepath',strcat(write_dir,'removed_automatically/ICA/done_still_to_reject/'));
	
    %automatically reject ICA: Using IClabels (to be used instead of MARA and ADJUST)
    % "THE GREAT CHANGE": Change what kind of selection criteria you want to apply for automatic selection. Note that the "other" classification is very prevalent when having more than 64 channels.
    % The default selection criteria here is considering the probability of the signal against the highest artifact probability (if signal probability is higher, use the IC). Note that the "other" classification is not seen as an artifact Pion-Tonachini, L., Kreutz-Delgado, K., & Makeig, S. (2019).
    % FOR UNEXPERIENCED USERS I RECOMMEND USING GUI FIRST AND READING Pion-Tonachini, L., Kreutz-Delgado, K., & Makeig, S. (2019). ICLabel: An automated electroencephalographic independent component classifier, dataset, and website. NeuroImage, 198, 181–197. https://doi.org/10.1016/j.neuroimage.2019.05.026
    EEG = pop_iclabel(EEG, 'default');
    %EEG = pop_icflag(EEG, [NaN NaN;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1;0.5 1]); % THESE ARE EXAMPLE THRESHOLDS ! VALIDATE ON YOUR DATA !
    for i = 1:size(EEG.etc.ic_classification.ICLabel.classifications,1)
        if EEG.etc.ic_classification.ICLabel.classifications(i,1)>max(EEG.etc.ic_classification.ICLabel.classifications(i,2:6))% if signal probability is higher than "pure" artifact
            classifyICs(i)=0;
        else
            classifyICs(i)=1;
        end
    end
    EEG.reject.gcompreject=classifyICs; %
    EEG = eeg_checkset( EEG );

    %"THE GREAT CHANGE": if you want to choose other criteria, specify them here.    This code is adapted from HAPPE  (Gabard-Durnam et al., 2018)
    %"THE GREAT CHANGE": if an error comes at compvar, check whether ICA_act is empty. if it is, run this code manually and start again from "ICs_to_keep" below: EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    %%% prepare evaluation of the performance
    %store IC variables and calculate variance of data that will be kept after IC rejection: This code is adapted from HAPPE  (Gabard-Durnam et al., 2018)
    ICs_to_keep =find(EEG.reject.gcompreject == 0);
    if size(EEG.icaact) == [0]
        EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    end
    ICA_act = EEG.icaact;
    ICA_winv =EEG.icawinv;   
    %variance of wavelet-cleaned data to be kept = varianceWav: : This code is adapted from HAPPE  (Gabard-Durnam et al., 2018)
    [proj, variancekeep] =compvar(EEG.data, ICA_act, ICA_winv, ICs_to_keep);

    % 1)	Channels that are not rejected (contributing “good” channels): see VP_indexarray
    Percentage_channels_kept(VP,1) = (1-(size(index,2)/Number_of_EEG_electrodes_without_reference_and_ground))*100;
    % 2)	Rejected ICs after second ICA
    Percentage_rejected_ICs(VP,1) = 1-(size(ICs_to_keep,2)/size(classifyICs,2));
    %3)	Variance kept after the rejection of the ICs
    Percentage_variance_kept(VP,1) = variancekeep;
    %4)	Number of rejected segment: not yet possible: later in processing with Step 5 revisited but remember taking reject1
    Reject1_VP(VP,1)=sum(reject1.rejglobal);
    %5)	Artifact probability of retained components, from ICLabel  
    median_artif_prob_good_ICs(VP,1) = median(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    mean_artif_prob_good_ICs(VP,1) = mean(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    range_artif_prob_good_ICs(VP,1) = range(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    min_artif_prob_good_ICs(VP,1) = min(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    max_artif_prob_good_ICs(VP,1) = max(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:6),1,[]));
    %including category "other"
    median_artif_prob_good_ICs(VP,2) = median(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    mean_artif_prob_good_ICs(VP,2) = mean(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    range_artif_prob_good_ICs(VP,2) = range(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    min_artif_prob_good_ICs(VP,2) = min(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));
    max_artif_prob_good_ICs(VP,2) = max(reshape(EEG.etc.ic_classification.ICLabel.classifications(ICs_to_keep,2:7),1,[]));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF STEP 7a
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%STEP 7b
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%     %first save necessary ICA components
%     reject2 = EEG.reject.gcompreject;
%     ICA_stuff1 = EEG.icawinv;
%     ICA_stuff2 = EEG.icasphere;
%     ICA_stuff3 = EEG.icaweights;
%     ICA_stuff4 = EEG.icachansind;
%     %now reload the data
%     %"THE GREAT CHANGE" Change the file extension from vhdr (brain-vision header file) to your original file type
%     EEG = pop_loadset('filename',strrep(filenames{VP},'cdt','set'),'filepath',load_dir);
%     EEG = eeg_checkset( EEG );
%     %segment the data once again as before
%     oddball_first_segmentation;
%     %reject the bad segemtns once more
%     EEG.reject = reject1; %apply the bad segments
%     EEG = pop_rejepoch( EEG, EEG.reject.rejglobal ,0); %reject the bad segments
%     EEG = eeg_checkset( EEG );
%     %now apply the ICA solution to the unfiltered EEG data
%     EEG.icawinv = ICA_stuff1;
%     EEG.icasphere = ICA_stuff2;
%     EEG.icaweights = ICA_stuff3;
%     EEG.icachansind = ICA_stuff4;
%     %recompute EEG.icaact:
%     EEG = eeg_checkset( EEG );
%     %set the components to reject
%     EEG.reject.gcompreject = reject2;
	%Automatically reject all marked componentss
	EEG = pop_subcomp(EEG,[],0);
    %recompute EEG.icaact:
    EEG = eeg_checkset( EEG );
	%save it
	EEG = pop_saveset( EEG, 'filename', strcat(filenames{VP},'_to_ICA'),'filepath',strcat(write_dir,'removed_automatically/ICA/automatically_rejected/'));
	[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

	
	EEG = pop_reref( EEG, [33 43] ,'keepref', 'on'); % M1 M2

	EEG = pop_saveset( EEG, 'filename',filenames{VP},'filepath',strcat(write_dir,'removed_automatically/ICA/automatically_rejected/Mastoid/'));
	
    %%"THE GREAT CHANGE": only needed once
    %%save the montage for topographical maps in next script:
    EEG.data = [];
    EEG.icaact = [];
    save('montage_for_topoplot.mat','EEG')
    
    %clear all stuff that is not needed for next person
	STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
%     clear ICA_stuff1 ICA_stuff2 ICA_stuff3 ICA_stuff4 reject2 data backupEEGdata backupEEGICA proj variancekeep index ICA_act ICA_winv ICs_to_keep reject1 classifyICs
	close all
end

%% 存储数据质量数据
Bad_channel_array = VP_indexarray ;
Number_Great_epochs_rejected = Reject1_VP;
save('Evaluation.mat','max_artif_prob_good_ICs','mean_artif_prob_good_ICs','median_artif_prob_good_ICs','min_artif_prob_good_ICs','Percentage_channels_kept','Percentage_rejected_ICs','Percentage_variance_kept','range_artif_prob_good_ICs','filenames','Bad_channel_array','Number_Great_epochs_rejected','Number_of_EEG_electrodes_without_reference_and_ground','Channelz_value_automatic_detection')
