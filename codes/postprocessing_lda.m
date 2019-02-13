function postprocessing_lda(config)

for sub_id = 1:config.sub_num
    lda.train_acc = cell(config.cv_num,config.iter_num,config.method_num);
    lda.test_acc = cell(config.cv_num,config.iter_num,config.method_num);
    lda.classification_train = cell(config.cv_num,config.iter_num,config.method_num);
    lda.classification_test = cell(config.cv_num,config.iter_num,config.method_num);
    
    for pos_ind = 1:config.position_num
        %%%%%%%%%%%%%
        % load data %
        %%%%%%%%%%%%%
        cd(config.data_dir);
        eval(sprintf('filename=[''feature_s%dch%d'']',sub_id,pos_ind));
        load(filename);
        
        class_testing_last = class_testing;
        class_training_last = class_training;        
        
        for method_ind = 1:config.method_num
            for iter_ind = 1:config.iter_num
                for cv_ind = 1:config.cv_num
                    f_test = f_te{cv_ind,iter_ind,method_ind};
                    f_train = f_tr{cv_ind,iter_ind,method_ind};
                       
                    f_test(isnan(f_test)) = 0;
                    f_train(isnan(f_train)) = 0;
                       
                    if cv_ind == config.cv_num
                        class_training = class_training_last;
                        class_testing = class_testing_last;
                    else
                        if sub_id == 9
                            class_training =  class_training_last(3:end-2,:);
                            class_testing = [ones(12,1);ones(13,1)+1];
                        elseif sub_id == 6
                            class_training =  class_training_last(2:end-1,:);
                            class_testing = [ones(11,1);ones(12,1)+1];          
                        else
                            class_training = [ones(size(f_train,2)/2,1);ones(size(f_train,2)/2,1)+1];
                            class_testing = [ones(size(f_test,2)/2,1);ones(size(f_test,2)/2,1)+1];
                        end
                    end
                    
                    cd(config.code_dir);
                    [lda.train_acc{cv_ind,iter_ind,method_ind},lda.test_acc{cv_ind,iter_ind,method_ind},lda.classification_train{cv_ind,iter_ind,method_ind},lda.classification_test{cv_ind,iter_ind,method_ind}]...
                        = ldaclassify(f_train',f_test',class_training,class_testing);
                end
            end
        end
        
        cd(config.save_dir);
        eval(sprintf('filename=[''LDA_s%dch%d'',''.mat''];',sub_id,pos_ind));
        save(filename,'lda');    
    end
end

cd(config.code_dir);