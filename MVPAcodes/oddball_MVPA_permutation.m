clear all; clc;

% Load data
original_g1data = load('single_alpha.mat');
original_g2data = load('dual_alpha.mat');

% Permutation parameters
permut = 500;
num_times = 100; 
num_subjects = 32;
num_frequencies = 37;

% Results storage
acc_final_rand = zeros(permut,num_subjects * 2, num_times);
auc_final_rand = zeros(permut, num_times);
sensitivity_final_rand = zeros(permut, num_times);
specificity_final_rand = zeros(permut, num_times);

h = waitbar(0, 'Please wait for permutation test...');

% Labels
label = [ones(num_subjects, 1); -1 * ones(num_subjects, 1)];

% Permutation testing
for i = 1:permut
    waitbar(i / permut, h, sprintf('Permutation: %d/%d', i, permut));
    randlabel = randperm(length(label));
    label_r = label(randlabel);
    a=10;

    for t_index = 1:a:1000
        g1data = squeeze(original_g1data.tf_data_diff1(t_index,:,:));
        g2data = squeeze(original_g2data.tf_data_diff2(t_index,:,:));
        
        data_all = [g1data; g2data];

        deci_values = [];

        for j = 1:size(data_all, 1)
            new_DATA = data_all;
            new_label = label_r;
            test_data = new_DATA(j, :);
            new_DATA(j, :) = [];
            train_data = new_DATA;
            test_label = new_label(j);
            new_label(j) = [];
            train_label = new_label;

            % Data normalization
            [train_data, PS] = mapminmax(train_data', 0, 1);
            test_data = mapminmax('apply', test_data', PS)';
            train_data = train_data';

            % Linear kernel SVM training
            [bestacc, bestc] = SVMcgForClass_NoDisplay_linear(train_label, train_data, -10, 10, 5, 0.2);
            cmd = ['-t 0 ', ' -c ', num2str(bestc)];
            model = svmtrain(train_label, train_data, cmd);
            [predicted_label, accuracy, deci] = svmpredict(test_label, test_data, model);

            % Collect decision values for AUC calculation
            deci_values = [deci_values; deci];

            % Record accuracy
            acc_final_rand(i, j, (t_index - 1) / a + 1) = accuracy(1);
        end
        
        % Calculate AUC, sensitivity, and specificity for the current permutation and time point
        [X, Y, T, AUC] = perfcurve(label_r, deci_values, 1);
        Cut_off = (1-X) .* Y;
        [~, maxind] = max(Cut_off);
        specificity = 1 - X(maxind);
        sensitivity = Y(maxind);

        auc_final_rand(i, (t_index - 1) / 10 + 1) = AUC;
        sensitivity_final_rand(i, (t_index - 1) / 10 + 1) = sensitivity;
        specificity_final_rand(i, (t_index - 1) / 10 + 1) = specificity;
    end
end
close(h);

% Save results
save('permutation_results_alpha.mat', 'acc_final_rand', 'auc_final_rand', 'sensitivity_final_rand', 'specificity_final_rand');
