function []= oddball_classify_trial_interaction(type1,type2,zoom)
% DO MVPA, type1 & type2 is condition, zoom is ROI
%% Import features (sample rows * feature columns) and labels (sample rows * 1 column)
% Load data（不将trial叠加的数据）
load('oddball_trial.mat');

% Initialize result matrices
num_iterations = length(1:371);
acc_final = zeros(1, num_iterations);
AUC_real = zeros(1, num_iterations);
sensitivity = zeros(1, num_iterations);
specificity = zeros(1, num_iterations);
iteration_index = 1;

% Initialize matrix to save all accuracies
all_acc = [];
all_deci_values = [];  % Initialize matrix to store all decision values

for t = 1:371
    % Extract data from structure(data-demension: subjects, conditions, electrodes, times, trials. 50*6*64*375*45)
    g1data = double(mean(subjs_oddball_trial_ERP(:,type1,zoom,t:t+4,:),4));  % set time window
    g2data = double(mean(subjs_oddball_trial_ERP(:,type2,zoom,t:t+4,:),4));
    g1data = reshape(g1data,50,length(zoom),45);
    g2data = reshape(g2data,50,length(zoom),45);
    reshaped_g1data = permute(g1data, [1 3 2]);  % 50*45*zoom
    reshaped_g2data = permute(g2data, [1 3 2]);
    data_all = [reshaped_g1data; reshaped_g2data];  % 100*45*zoom
    label = [ones(50,45);-1*ones(50,45)];
    label(isnan(data_all(:,:,1))) = nan;   % some subjects do not have 45trials
 
%     original code
%     g1data = squeeze(original_g1data.tf_data_diff1(t,:,:,:));
%     g2data = squeeze(original_g2data.tf_data_diff2  (t,:,:,:));
%     reshaped_g1data = reshape(g1data, 32, []);
%     reshaped_g2data = reshape(g2data, 32, []);
%     data_all = [reshaped_g1data; reshaped_g2data];
%     label = [ones(size(reshaped_g1data,1),1);-1*ones(size(reshaped_g2data,1),1)];

    % Normalize Samples (row normalization, optional)
    data_all = reshape(data_all,4500,length(zoom));
    data_all_sum_square = sqrt(sum(data_all.^2, 2));
    data_all = bsxfun(@rdivide, data_all, data_all_sum_square);
    data_all = reshape(data_all,100,45,length(zoom));


    % Leave-one-out cross-validation(原文是留1法，改成五折法)
    w = zeros(length(zoom)); % Classification weight, hyperplane weight w (subject number (fold number) * feature number)
    acc = zeros(5, 1); % Accuracy for all subjects in the current iteration
    deci_values = zeros(100, 1); % Decision values for all subjects in the current iteration
    
    % 抽取交叉验证的数据（五折.五份数据）
    test_datas = nan(5,900,length(zoom));
    train_datas = nan(5,3600,length(zoom));
    test_labels = nan(5,900);
    train_labels = nan(5,3600);
    for i = 1:100 % 每个被试的4/5trial为训练集，1/5trial为测试集
        tem_label = label(i,:);
        cv = cvpartition(tem_label, 'KFold', 5);
        for fold = 1:5
            tem_new_data = reshape(data_all(i,:,:),45,length(zoom));
            tem_test_idx = test(cv, fold);       % 调用交叉检验里的test方法
            tem_new_label = tem_label;
            tem_test_data = tem_new_data(tem_test_idx,:);
            test_trialnum = size(tem_test_data,1);
            tem_new_data(tem_test_idx,:) = [];
            tem_train_data = tem_new_data;
            train_trialnum = size(tem_train_data,1);
            tem_test_label = tem_label(tem_test_idx);
            tem_new_label(tem_test_idx) = [];
            tem_train_label = tem_new_label;
            test_datas(fold, 9*(i-1)+1:9*(i-1)+test_trialnum ,:) = tem_test_data;
            train_datas(fold,36*(i-1)+1:36*(i-1)+train_trialnum,:) = tem_train_data;
            test_labels(fold,9*(i-1)+1:9*(i-1)+test_trialnum) = tem_test_label;
            train_labels(fold,36*(i-1)+1:36*(i-1)+train_trialnum) = tem_train_label;
        end
    end

    all_test_label = [];
    length_last_fold = 0;
    for fold = 1:5
        % extract data
        test_data = reshape(test_datas(fold,:,:),[],length(zoom));
        train_data = reshape(train_datas(fold,:,:),[],length(zoom));
        test_label = reshape(test_labels(fold,:),[],1);
        train_label = reshape(train_labels(fold,:),[],1);
        % delete nan data
        test_label = test_label(~all(isnan(test_data), 2), :);
        train_label = train_label(~all(isnan(train_data), 2), :);
        test_data = test_data(~all(isnan(test_data), 2), :);
        train_data = train_data(~all(isnan(train_data), 2), :);

        % standardization
        [train_data, PS] = mapminmax(train_data', 0, 1);
        test_data = mapminmax('apply', test_data', PS);
        train_data = train_data';
        test_data = test_data';

%         [bestacc, bestc] = SVMcgForClass_NoDisplay_linear(train_label, train_data, -10, 10, 5, 0.2);
%         cmd = ['-t 0 ', ' -c ', num2str(bestc)];
        cmd = ['-t 0 -c 1'];
        model = svmtrain(train_label, train_data, cmd);  % Train
        w(fold,:) = model.SVs'*model.sv_coef; % Weight of support vectors (supports linear kernel only)
        [~, accuracy, deci] = svmpredict(test_label, test_data, model);
%       [~, accuracy, deci] = svmpredict(train_label, train_data, model);% 检验过拟合
        % 模型可视化
%             h = 0.02; % 网格步长
%             [x1, x2] = meshgrid(min(train_data(:,1))-1:h:max(train_data(:,1))+1, ...
%                                 min(train_data(:,2))-1:h:max(train_data(:,2))+1);
%             
%             % 预测网格点
%             mesh_data = [x1(:), x2(:)];
%             [predicted_label, accuracy, decision_values] = svmpredict(zeros(size(mesh_data,1),1), mesh_data, model);
%             
%             % 绘制决策区域
%             figure;
%             contourf(x1, x2, reshape(decision_values, size(x1)), 50, 'LineStyle', 'none');
%             colormap(jet);
%             colorbar;
%             hold on;
%             
%             % 绘制数据点
%             gscatter(train_data(:,1), train_data(:,2), train_label, 'rb', 'o*', 8);
%             
%             % 标记支持向量
%             sv_indices = model.sv_indices;
% %             plot(train_data(sv_indices,1), train_data(sv_indices,2), 'ko', 'MarkerSize', 10, 'LineWidth', 2);
% %             
%             title('SVM决策边界和支持向量');
%             xlabel('特征1');
%             ylabel('特征2');
%             legend('决策值', '类别1', '类别2', '支持向量');


        acc(fold, 1) = accuracy(1); % Summarize accuracy of the current fold
        deci_values(length_last_fold+1:length_last_fold+length(deci),1 ) = deci; % Save decision value
        length_last_fold = length_last_fold+length(deci);
        all_test_label = [all_test_label,test_label'];
        acc(fold,1) = accuracy(1);
    end

    % Save accuracy of the current iteration
    if isempty(all_acc)
        all_acc = acc';
    else
        all_acc = [all_acc; acc'];
    end

    % Save decision values
    if isempty(all_deci_values)
        all_deci_values = deci_values';
    else
        all_deci_values = [all_deci_values; deci_values'];
    end

    w(1,:) = mean(w,1); % Average weight of all folds
    acc_final(iteration_index) = mean(acc); % Calculate overall accuracy
    % Calculate ROC curve, specificity, and sensitivity
    [X, Y, ~, AUC_real(iteration_index)] = perfcurve(all_test_label, all_deci_values(iteration_index, :), 1);
    Cut_off = (1-X) .* Y;
    [~, maxind] = max(Cut_off);
    specificity(iteration_index) = 1 - X(maxind); % Calculate specificity
    sensitivity(iteration_index) = Y(maxind); % Calculate sensitivity
    iteration_index = iteration_index + 1;
end

% Save results
save([num2str(type1) '_acc_final_beta.mat'], 'acc_final');
save([num2str(type1) '_AUC_real_beta.mat'], 'AUC_real');
save([num2str(type1) '_sensitivity_beta.mat'], 'sensitivity');
save([num2str(type1) '_specificity_beta.mat'], 'specificity');
save([num2str(type1) '_all_acc_beta.mat'], 'all_acc'); % Save accuracy of each subject in all iterations
save([num2str(type1) '_all_deci_values_beta.mat'], 'all_deci_values'); % Save decision values in all iterations
end