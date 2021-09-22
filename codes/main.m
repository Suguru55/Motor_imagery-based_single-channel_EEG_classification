% Main script for "A comparative study of features and classifiers in 
% single-channel EEG-based motor imagery BCI" submitted to Global SIP 2018
% 
% This script is the main script for determining the best combination of 
% channel, feature, and classifier that maximizes the classification
% accuracy of single-channel EEG-based motor imagery BCIs.
% Before using this script, you should download data from BCI competition
% IV dataset 2a.
% 
% Suguru Kanoga, 4-Dec.-2018
%  Artificial Intelligence Research Center, National Institute of Advanced
%  Industrial Science and Technology (AIST)
%  E-mail: s.kanouga@aist.go.jp

%% Clear workspace
clear all
close all

% clc
% help main

%% Set config
config = set_config;

%% Main stream (pre-processing)
%  if you saved mat.file named 'feature_s%dch%d' ones, 
%  you can skip this process.

addpath('C:\toolbox\biosig4octmat-3.2.0\biosig\t250_ArtifactPreProcessingQualityControl'); % to use trigg function
addpath('C:\toolbox\biosig4octmat-3.2.0\biosig\t200_FileAccess');  

for sub_id = 1:config.sub_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % load data (2-s epochs) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    [epochs, labels] = load_data(config, sub_id);
    
    % set parameters for cross-validation
    c_ind{1} = find(labels==1); % class 1
    c_step_size(1,1) = ceil(size(c_ind{1},1)/config.cv_num);
    
    c_ind{2} = find(labels==2); % class 2
    c_step_size(1,2) = ceil(size(c_ind{2},1)/config.cv_num);
    
    for pos_ind = 1:config.position_num
        % storage of feature vectors
        f_tr = cell(config.cv_num,config.iter_num,config.method_num);
        f_te = cell(config.cv_num,config.iter_num,config.method_num);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % extract single-channel epochs %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        target_epo = squeeze(epochs(pos_ind,:,:));
        
        % iterations for reducing the effect of random selection
        for iter_ind = 1:config.iter_num
            % all positions must use the same testing and training data
            if pos_ind == 1
               vc_ind{1} = c_ind{1}(randperm(size(c_ind{1},1)));
               vc_ind{2} = c_ind{2}(randperm(size(c_ind{2},1)));
            end
            
            % ectract features for 10 10-fold CV
            for cv_ind = 1:config.cv_num
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % split original epochs into training and testing epochs %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                dammy_vc_ind = vc_ind;
                
                if cv_ind == config.cv_num
                    testing_c{1} = target_epo(:,vc_ind{1}(1+c_step_size(1)*(cv_ind-1):end));
                    testing_c{2} = target_epo(:,vc_ind{2}(1+c_step_size(2)*(cv_ind-1):end));
                    testing = [testing_c{1}, testing_c{2}];
                    dammy_vc_ind{1}(1+c_step_size(1)*(cv_ind-1):end,:) = [];
                    dammy_vc_ind{2}(1+c_step_size(2)*(cv_ind-1):end,:) = [];
                else
                    testing_c{1} = target_epo(:,vc_ind{1}(1+c_step_size(1)*(cv_ind-1):c_step_size(1)+c_step_size(1)*(cv_ind-1)));
                    testing_c{2} = target_epo(:,vc_ind{2}(1+c_step_size(2)*(cv_ind-1):c_step_size(2)+c_step_size(2)*(cv_ind-1)));                    
                    testing = [testing_c{1}, testing_c{2}];
                    dammy_vc_ind{1}(1+c_step_size(1)*(cv_ind-1):c_step_size(1)+c_step_size(1)*(cv_ind-1),:) = [];
                    dammy_vc_ind{2}(1+c_step_size(2)*(cv_ind-1):c_step_size(2)+c_step_size(2)*(cv_ind-1),:) = [];
                end
                
                training_c{1} = target_epo(:,dammy_vc_ind{1});
                training_c{2} = target_epo(:,dammy_vc_ind{2});
                
                % check data size for single-channel CSP
                if size(training_c{1},2) ~= size(training_c{2},2)
                    training_c{1} = training_c{1}(:,1:min(size(training_c{1},2),size(training_c{2},2)));
                    training_c{2} = training_c{2}(:,1:min(size(training_c{1},2),size(training_c{2},2)));
                end
                
                %%%%%%%%%%%%%%%%%%%%%
                % zero-padding STFT %
                %%%%%%%%%%%%%%%%%%%%%
                pow_tr_c{1} = zeros(config.bin_num,config.win_num,size(training_c{1},2));
                pow_tr_c{2} = zeros(config.bin_num,config.win_num,size(training_c{2},2));
                pow_te = zeros(config.bin_num,config.win_num,size(testing,2));
                
                % extract 100 sample points from target_epo
                for data_ind = 1:size(training_c{1},2)
                    [~,~,~,ps1] = spectrogram(training_c{1}(:,data_ind),config.window_size,config.overlap,config.nfft,config.Fs);
                    pow_tr_c{1}(:,:,data_ind) = ps1(2:21,:);
                    [~,~,~,ps2] = spectrogram(training_c{2}(:,data_ind),config.window_size,config.overlap,config.nfft,config.Fs);
                    pow_tr_c{2}(:,:,data_ind) = ps2(2:21,:);                    
                end
                
                for data_ind = 1:size(testing,2)
                    [~,~,~,ps] = spectrogram(testing(:,data_ind),config.window_size,config.overlap,config.nfft,config.Fs);
                    pow_te(:,:,data_ind) = ps(2:21,:);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%
                % feature extraction %
                %%%%%%%%%%%%%%%%%%%%%%
                % 1. power spectra with log scale (PS)
                % 2. single-channel SCP (SCCSP)
                % 3. GLCM
                
                class_training = [ones(size(training_c{1},2),1); ones(size(training_c{2},2),1)+1];
                class_testing = [ones(size(testing_c{1},2),1); ones(size(testing_c{2},2),1)+1];
                pow_tr = cat(3,pow_tr_c{1},pow_tr_c{2});
                
                cd(config.code_dir)
                for method_ind = 1:config.method_num
                    switch  method_ind
                        case 1
                            f_train = log10(squeeze(var(pow_tr,[],2))./sum(squeeze(var(pow_tr,[],2))));
                            f_test = log10(squeeze(var(pow_te,[],2))./sum(squeeze(var(pow_te,[],2))));                
                            
                        case 2
                            [f_train, f_test] = sccsp(pow_tr,pow_te,config,pow_tr_c,training_c);
                            
                        case 3
                            [f_train, f_test] = glcm(pow_tr,pow_te,config);

                    end
                    %%%%%%%%%%%%%%%%%%%
                    % standardization %
                    %%%%%%%%%%%%%%%%%%%
                    m_tr = mean(f_train,2);
                    s_tr = std(f_train,[],2);
                         
                    f_tr{cv_ind,iter_ind,method_ind} = (f_train - repmat(m_tr,1,size(f_train,2))) ./ repmat(s_tr,1,size(f_train,2));
                    f_te{cv_ind,iter_ind,method_ind} = (f_test - repmat(m_tr,1,size(f_test,2))) ./ repmat(s_tr,1,size(f_test,2));               
                end
            end
        end
        
        % save f_tr and f_te
        cd(config.data_dir);
        eval(sprintf('filename=[''feature_s%dch%d''];',sub_id,pos_ind));
        save(filename,'f_tr','f_te','class_training','class_testing')
    end
end

%% Main stream (post-processing)

postprocessing_lda(config);
disp('lda done')
postprocessing_knn(config);
disp('knn done')
postprocessing_gmm(config);
disp('gmm done')
postprocessing_rf(config);
disp('rf done')
postprocessing_mlp(config);
disp('mlp done')
postprocessing_svm_rbf(config);
disp('svm done')

%% Main stream (comparison)
cd(config.save_dir);
all_acc = zeros(3,900,6);

for classifier_ind = 1:6
    lib_acc = zeros(3,900);
    for sub_id = 1:config.sub_num
        for pos_ind = 1:config.position_num
            switch classifier_ind
                case 1
                    eval(sprintf('filename=[''LDA_s%dch%d'',''.mat''];',sub_id,pos_ind));
                    load(filename);
                    acc = cell2mat(lda.test_acc);
                case 2
                    eval(sprintf('filename=[''kNN_s%dch%d'',''.mat''];',sub_id,pos_ind));
                    load(filename);
                    acc = cell2mat(knn.test_acc);                    
                case 3
                    eval(sprintf('filename=[''GMM_s%dch%d'',''.mat''];',sub_id,pos_ind));
                    load(filename);
                    acc = cell2mat(gmm.test_acc);                    
                case 4
                    eval(sprintf('filename=[''RF_s%dch%d'',''.mat''];',sub_id,pos_ind));
                    load(filename);
                    acc = cell2mat(rf.test_acc);      
                case 5
                    eval(sprintf('filename=[''MLP_s%dch%d'',''.mat''];',sub_id,pos_ind));
                    load(filename);
                    acc = cell2mat(mlp.test_acc);                       
                case 6
                    eval(sprintf('filename=[''svm_rbf_s%dch%d'',''.mat''];',sub_id,pos_ind));
                    load(filename);
                    acc = cell2mat(svm_rbf.test_acc);                    
            end
            
            acc = reshape(acc,[config.cv_num*config.iter_num,config.method_num]);
            ave_acc = mean(acc,1);
            
            if pos_ind == 1
                best_acc = ave_acc;
                lib_acc(:,1+100*(sub_id-1):100+100*(sub_id-1)) = acc';
            end
            
            for method_ind = 1:3
                if best_acc(1,method_ind) < ave_acc(1,method_ind)
                    best_acc(1,method_ind) = ave_acc(1,method_ind);
                    lib_acc(method_ind,1+100*(sub_id-1):100+100*(sub_id-1)) = acc(:,method_ind)';
                end 
            end
        end
    end
    all_acc(:,:,classifier_ind) = lib_acc;
end