clear
clc
load("oddball_ERP_50.mat")
load("permute_test.mat")

zooms = [8 9 10 11 12 0 0 0 0 0 0 0;  %fron
         17 18 19 20 21 0 0 0 0 0 0 0  %froncen
         26 27 28 29 30 0 0 0 0 0 0 0  %cen
         44 45 46 47 48 0 0 0 0 0 0 0  %pari
         42 50 51 57 0 0 0 0 0 0 0 0   %octr
         1 3 6 10 14 24 30 46 52 55 61 63];
idxs = nan(4,2,6,300);
for k=1:4
    for j = 1:2
        types1 = {'civilian','pregnant','drug','criminal'};
        types2 = {'child','none'};
        type1 = types1{k};
        type2 = types2{j};
        titlename = {strcat(type1,'-vs-',type2,'-FronElec');
                    strcat(type1,'-vs-',type2,'-FronCentElec')
                    strcat(type1,'-vs-',type2,'-CentElec')
                    strcat(type1,'-vs-',type2,'-PariElec')
                    strcat(type1,'-vs-',type2,'-OctrElec')
                    strcat(type1,'-vs-',type2,'-emotionElec')
                    };
        line_types = [3 2 4 5;1 6 0 0];
        line_type = [line_types(1,k) line_types(2,j)];
        legendname = {'',type1,'',type2};
       
        for i=1:size(zooms,1)
            figure
            zoom = zooms(i,:);
            [y_s, p_s] = plot_ERP(zoom(zoom~=0),titlename{i},line_type,legendname);
            hold on 
            idx = p_s<0.001;
            idxs(k,j,i,:) = idx; 
            diff_salient = [0, idx, 0];
            diff_vec = diff(diff_salient);
            starts = find(diff_vec == 1);   % 聚簇开始位置
            ends = find(diff_vec == -1);    % 聚簇结束位置
            true_cluster_sizes = ends-starts;
            for c = 1:length(true_cluster_sizes)
                true_cluster = true_cluster_sizes(c);
                count_exceeding = sum(cluster_groups_all(k,j,i,:) >= true_cluster);
                p_value = (count_exceeding + 1) / 1001;
                if p_value < 0.05
                    plot(starts(c), 8 , 'r*', 'MarkerSize', 10, 'LineWidth', 2, 'HandleVisibility', 'off');
                end
            end
            picturename = strcat(titlename{i},'.png');
            saveas(gcf, picturename);  %save picture 
        end
    end
end
    close all;

sig_time_otr = reshape(idxs(:,1,5,:),4,300);
sigs_time_otr = sig_time_otr(1,:)+sig_time_otr(2,:)+sig_time_otr(3,:)+sig_time_otr(4,:);

%% 聚簇检验
zooms = [8 9 10 11 12 0 0 0 0 0 0 0;
         17 18 19 20 21 0 0 0 0 0 0 0
         26 27 28 29 30 0 0 0 0 0 0 0
         44 45 46 47 48 0 0 0 0 0 0 0
         42 50 51 57 0 0 0 0 0 0 0 0
         1 3 6 10 14 24 30 46 52 55 61 63];

cluster_sizes = nan(4,2,6);
cluster_groups_all = nan(4,2,6,1000);
ps = nan(4,2,6);
ks = [3 2 4 5];
js = [1 6];
for k=1:4
    for j = 1:2
        for i = 1:size(zooms,1)
            zoom = zooms(i,:);
            type1 = ks(k);
            type2 = js(j);
            [t_cluster_size,cluster_groups ,p] = oddball_ERP_permutation(type1,type2,zoom(zoom~=0),0.01);
            cluster_groups_all(k,j,i,:) = cluster_groups;
            cluster_sizes(k,j,i) = t_cluster_size;
            ps(k,j,i) = p;
        end
    end
end


%% 统计准确率
readdir = 'D:\Github\data\oddball_202503\behavior\' ;
folders = dir([readdir,'sub*']);
folderenames = {folders.name}';
ansarr = [];
for i=1:30
curfolder = strcat(readdir,folderenames(i));
cd(string(curfolder));

file = dir('block_5*');
filename = [file.name];

readtable(filename);
arr = table2array(ans(1:5,4));
ansarr = [ansarr arr];
end


%% 坏导统计
% 统计每个数字(1-64)的出现次数
counts = histcounts(VP_indexarray, 1:65);

% 定义电极分组
% 注意：跳过33和43号电极（参考电极）
groups = struct();
groups.FP = 1:5;           % FP: 1-5
groups.F = 6:14;           % F: 6-14
groups.FC = 15:23;         % FC: 15-23
groups.C = 24:32;          % C: 24-32 (跳过33)
groups.CP = 34:42;         % CP: 34-42 (跳过43)
groups.P = 44:52;          % P: 44-52
groups.PO = 53:59;         % PO: 53-59
groups.O = 60:64;          % O: 60-64

% 计算每个脑区的总频率
groupNames = fieldnames(groups);
groupCounts = zeros(length(groupNames), 1);

for i = 1:length(groupNames)
    electrodes = groups.(groupNames{i});
    groupCounts(i) = sum(counts(electrodes));
end

% 创建直方图
figure('Position', [100, 100, 900, 600]);
bar(groupCounts, 'FaceColor', [0.2, 0.6, 0.8]);

% 设置图表属性
title('各脑区去除坏导数', 'FontSize', 16);
xlabel('脑区', 'FontSize', 14);
ylabel('坏导数', 'FontSize', 14);

% 设置X轴标签
set(gca, 'XTick', 1:length(groupNames));
set(gca, 'XTickLabel', groupNames);
set(gca, 'FontSize', 12);

% 在每个柱状图上添加数值标签
for i = 1:length(groupCounts)
    text(i, groupCounts(i) + max(groupCounts)*0.01, num2str(groupCounts(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 12);
end
% 
% % 添加网格
% grid on;
% 
% % 可选：创建每个脑区内电极的详细频率图
% figure('Position', [200, 200, 1200, 600]);
% subplot(2, 4, 1);
% for i = 1:length(groupNames)
%     subplot(2, 4, i);
%     electrodes = groups.(groupNames{i});
%     bar(counts(electrodes));
%     title([groupNames{i} '区 (' num2str(length(electrodes)) '个电极)']);
%     xlabel('电极编号');
%     ylabel('出现次数');
%     set(gca, 'XTick', 1:length(electrodes));
%     set(gca, 'XTickLabel', electrodes);
% end
% sgtitle('各脑区内电极详细频率分布', 'FontSize', 16);



% 2. 统计数字出现次数
counts = histcounts(VP_indexarray, 1:65);

% 3. 重塑为8x8矩阵
countMatrix = reshape(counts, 8, 8)';

% 4. 绘制热图
h = heatmap(countMatrix);
h.Title = '坏导频次热图';
h.XLabel = 'X';
h.YLabel = 'Y';
h.Colormap = jet;

% 5. 可选：自定义坐标轴标签（显示实际数字）
customLabels = reshape(1:64, 8, 8)';
h.XDisplayLabels = string(customLabels(1,:));
h.YDisplayLabels = string(customLabels(:,1));