function [true_cluster,permute_clusters,p_value] = oddball_ERP_permutation(type1,type2,electro,valpha)


% Load data
load('oddball_ERP_50.mat');
% config
num_subjects = 50;
% set time parameter
EEG.srate = 250;
display_time_start_from_zero_in_ms = -200; %Note that one can also go into - : this means it is left from 0, being a display of the baseline. Note also that you cannot display data that is not in your segmentation.
display_time_end_from_zero_in_ms = 1000; %Note also that you cannot display data that is not in your segmentation.
display_time_start = display_time_start_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate
display_time_end = display_time_end_from_zero_in_ms/(1000/EEG.srate)-(Segementation_time_start*EEG.srate); % dependent on the starting point of segement and sampling rate

% data
t1data = squeeze(nanmean(subjs_oddball_ERP(:,type1,electro,display_time_start:display_time_end),3));
t2data = squeeze(nanmean(subjs_oddball_ERP(:,type2,electro,display_time_start:display_time_end),3));
all_data = [t1data;t2data];

% true data
tp_s = [];
for l = 1:(display_time_end-display_time_start)
    [~,tp] = ttest(t1data(:,l),t2data(:,l));
    tp_s = [tp_s tp];
end
t_salient = tp_s< valpha;
% 计算差分，找到聚簇的开始和结束
diff_salient = [0, t_salient, 0];
diff_vec = diff(diff_salient);
starts = find(diff_vec == 1);   % 聚簇开始位置
ends = find(diff_vec == -1);    % 聚簇结束位置
% 计算每个聚簇的大小
if isempty(starts)
    max_cluster_size = 0;
else
    cluster_sizes = ends - starts;
    max_cluster_size = max(cluster_sizes);
end
true_cluster = max_cluster_size;


permut = 1000;
max_clusters = [];
label = [ones(num_subjects/2,1);0*ones(num_subjects/2,1)];
for i = 1:permut
    %permut label
    randlabel = randperm(length(label));
    label_r1 = label(randlabel);
    label_r2 = 1-label_r1;
    t1data_r = t1data.*label_r1+t2data.*label_r2;
    t2data_r = t2data.*label_r1+t1data.*label_r2;

    p_s = [];
    for l = 1:(display_time_end-display_time_start)
        [~,p] = ttest(t1data_r(:,l),t2data_r(:,l));
        p_s = [p_s p];
    end
    salient = p_s<valpha;
       
    % 计算差分，找到聚簇的开始和结束
    diff_salient = [0, salient, 0];
    diff_vec = diff(diff_salient);
    starts = find(diff_vec == 1);   % 聚簇开始位置
    ends = find(diff_vec == -1);    % 聚簇结束位置
    % 计算每个聚簇的大小
    if isempty(starts)
        max_cluster_size = 0;
    else
        cluster_sizes = ends - starts;
        max_cluster_size = max(cluster_sizes);
    end

max_clusters = [max_clusters max_cluster_size];

end
permute_clusters = max_clusters;
%计算正式数据在置换检验的零分布中的p值
count_exceeding = sum(max_clusters >= true_cluster);
p_value = (count_exceeding + 1) / (permut + 1);

end