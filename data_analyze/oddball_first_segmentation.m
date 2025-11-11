% %%% Skript Rodrigues: Made by Dr. rer. nat. Johannes Rodrigues, Dipl. Psych. Julius-Maximilians University of W黵zburg. johannes.rodrigues@uni-wuerzburg.de; Started 2012, Latest update: 2021_05
% %%% IMPORTATANT NOTE: THERE IS NO WARRENTY INCLUDED ! -> GNU 
% %%% THERE ARE MANY THINGS THAT NEED TO BE ADJUSTED TO YOUR DATA !
% %%% PLEASE ALSO KEEP IN MIND, THAT DIFFERENT MATLAB VERSIONS MIGHT HAVE SOME CRITICAL CHANGES IN THEM THAT MAY ALTER YOUR RESULTS !!! One example is the differences in the round function that changed the Baseline EEGLAB function on "older" MATLAB Version. 
% %%% PLEASE DON碩 USE THIS SCRIPT WITHOUT CONTROLLING YOUR RESULTS ! CHECK FOR PLAUSIBILITY OF THE SIGNAL AND TOPOGRAPHY
% 
% 
% %seperate_script_for_segmentation

for i = 2:(size(EEG.event,2)-1)
    marker = EEG.event(1,i).type;
        if strcmp(class(marker), 'double')
            if i==1 && marker == 88 % 标记区块开始marker
                EEG.event(1,i).type = 'block_start';
                continue;
            end            
            if marker == 199 || marker == 100 || marker == 200  % 反应marker(1是士兵在上，2是士兵在下)
                stim_marker = EEG.event(1,i+1).type;  % 附带伤害类型和数量,（1-child,2-pregnant,3-drug,4-criminal,5-civilian,6-none）
                soldier_marker = EEG.event(1,i-1).type;
                if stim_marker>69 || soldier_marker>29 || soldier_marker<10 % 出现异常则跳过这个trial
                    continue;
                end

                switch floor(stim_marker/10)
                    case 1 
                        cd_type = 'child';
                    case 2
                        cd_type = 'pregnant';
                    case 3
                        cd_type = 'drug';
                    case 4
                        cd_type = 'criminal';
                    case 5
                        cd_type = 'civilian';
                    case 6
                        cd_type = 'none';
                end
                switch mod(stim_marker,10)
                    case 0
                        cd_num = '_';
                    case {1,2,3}
                        cd_num = 'low';
                    case {4,5,6}
                        cd_num = 'mid';
                    case {7,8,9}
                        cd_num = 'high';
                end
                switch mod(soldier_marker,10)
                    case 0
                        soldier_num = 'target';
                    case {1,2,3}
                        soldier_num = 'low';
                    case {4,5,6}
                        soldier_num = 'mid';
                    case {7,8,9}
                        soldier_num = 'high';
                end
                if floor(soldier_marker/10) == 1
                    line_order = 'soldierup';
                else
                    line_order = 'soldierdown';
                end

                if marker==199
                    EEG.event(1,i).type = 'no_response';
                elseif marker==100
                    EEG.event(1,i).type = 'space';
                elseif marker==200
                    EEG.event(1,i).type = 'otherkey';
                end
                EEG.event(1,i-1).type = [cd_type '_' cd_num '_soldier_' soldier_num '_line_' line_order]; % example：child_low_soldier_low_line_soldierup
                EEG.event(1,i+1).type = 'trial_end';
            end
        end
end
%出现未标记试次，标记为异常
for i = 1:size(EEG.event,2)
    marker = EEG.event(i).type;
    if class(marker)=="double"
        EEG.event(i).type = 'error';
    end
end

Relevant_Markers = {};
trialnum = 5;
for i = 1:size(EEG.event,2)
    marker = EEG.event(1,i).type;
    if contains(marker,'_line_')
        Relevant_Markers = [Relevant_Markers marker];
    elseif contains(marker,'trial_end') %每6个trial标记一下，用于ICA前分段
        trialnum = trialnum + 1;
        if trialnum==6
            EEG.event(1,i).type = 'trial_end_6';
            trialnum = 0;
        end
    end
end

% Relevant_Markers = cellstr(Relevant_Markers);  % 将 string 数组转换为 cell 数组 
Relevant_Markers=unique(Relevant_Markers);
% 
EEG = pop_epoch( EEG, 'trial_end_6' , [-1 9], 'newname', strcat(filenames{VP},'_intchan_avg_filt epochs'), 'epochinfo', 'yes'); %selection: 0 to 1.5 seconds
