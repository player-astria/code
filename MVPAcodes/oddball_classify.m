function []= oddball_classify(type1,type2,zoom)
%% Import features (sample rows * feature columns) and labels (sample rows * 1 column)
% Load data
load('oddball_ERP_50.mat');

% Initialize result matrices
num_iterations = length(1:5:375);
acc_final = zeros(1, num_iterations);
AUC_real = zeros(1, num_iterations);
sensitivity = zeros(1, num_iterations);
specificity = zeros(1, num_iterations);
iteration_index = 1;

% Initialize matrix to save all accuracies
all_acc = [];
all_deci_values = [];  % Initialize matrix to store all decision values

for t = 1:5:375
    % Extract data from structure
    g1data = squeeze(double(mean(subjs_oddball_ERP(:,type1,zoom,t:t+4),4)));  % set time window
    g2data = squeeze(double(mean(subjs_oddball_ERP(:,type2,zoom,t:t+4),4)));
    reshaped_g1data = reshape(g1data, 50, []);
    reshaped_g2data = reshape(g2data, 50, []);
    data_all = [reshaped_g1data; reshaped_g2data];
    label = [ones(size(reshaped_g1data,1),1);-1*ones(size(reshaped_g2data,1),1)];

%     original code
%     g1data = squeeze(original_g1data.tf_data_diff1(t,:,:,:));
%     g2data = squeeze(original_g2data.tf_data_diff2(t,:,:,:));
%     reshaped_g1data = reshape(g1data, 32, []);
%     reshaped_g2data = reshape(g2data, 32, []);
%     data_all = [reshaped_g1data; reshaped_g2data];
%     label = [ones(size(reshaped_g1data,1),1);-1*ones(size(reshaped_g2data,1),1)];

    % Normalize Samples (row normalization, optional)
    data_all_sum_square = sqrt(sum(data_all.^2, 2));
    data_all = bsxfun(@rdivide, data_all, data_all_sum_square);

    % Leave-one-out cross-validation(原文是留1法，改成十折法)
    w = zeros(length(zoom)); % Classification weight, hyperplane weight w (subject number (fold number) * feature number)
    acc = zeros(10, 1); % Accuracy for all subjects in the current iteration
    deci_values = zeros(100, 1); % Decision values for all subjects in the current iteration

    cv = cvpartition(label, 'KFold', 10);
    all_test_label = [];
    for fold = 1:10
        test_idx = test(cv, fold);       % 调用交叉检验里的test方法
        new_DATA = data_all;
        new_label = label;
        test_data = data_all(test_idx,:);
        new_DATA(test_idx,:) = [];
        train_data = new_DATA;
        test_label = label(test_idx);
        new_label(test_idx) = [];
        train_label = new_label;

        [train_data, PS] = mapminmax(train_data', 0, 1);
        test_data = mapminmax('apply', test_data', PS);
        train_data = train_data';
        test_data = test_data';

        [bestacc, bestc] = SVMcgForClass_NoDisplay_linear(train_label, train_data, -10, 10, 5, 0.2);
        cmd = ['-t 0 ', ' -c ', num2str(bestc)];

        model = svmtrain(train_label, train_data, cmd);  % Train
        w(fold,:) = model.SVs'*model.sv_coef; % Weight of support vectors (supports linear kernel only)
        [~, accuracy, deci] = svmpredict(test_label, test_data, model);
        acc(fold, 1) = accuracy(1); % Summarize accuracy of the current fold
        deci_values((10*fold-9):10*fold,1 ) = deci; % Save decision value
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
    [X, Y, T, AUC_real(iteration_index)] = perfcurve(all_test_label, all_deci_values(iteration_index, :), 1);
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