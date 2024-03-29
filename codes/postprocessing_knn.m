function postprocessing_knn(config)

for sub_id = 1:config.sub_num
    temp.train_acc = cell(config.cv_num,config.iter_num,config.method_num);
    temp.test_acc = cell(config.cv_num,config.iter_num,config.method_num);
    temp.classification_train = cell(config.cv_num,config.iter_num,config.method_num);
    temp.classification_test = cell(config.cv_num,config.iter_num,config.method_num);
    knn.train_acc = cell(config.cv_num,config.iter_num,config.method_num);
    knn.test_acc = cell(config.cv_num,config.iter_num,config.method_num);
    knn.classification_train = cell(config.cv_num,config.iter_num,config.method_num);
    knn.classification_test = cell(config.cv_num,config.iter_num,config.method_num);
    
    for pos_ind = 1:config.position_num
        %%%%%%%%%%%%%
        % load data %
        %%%%%%%%%%%%%
        cd(config.data_dir);
        eval(sprintf('filename=[''feature_s%dch%d'']',sub_id,pos_ind));
        load(filename);
        
        class_testing_last = class_testing;
        class_training_last = class_training;        
        
        for k = config.knn_k
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
                           class_training = [ones(size(f_train,2)/2,1);ones(size(f_train,2)/2,1)+1];
                           class_testing = [ones(size(f_test,2)/2,1);ones(size(f_test,2)/2,1)+1];
                       end
                       
                       cd(config.code_dir);
                       [temp.train_acc{cv_ind,iter_ind,method_ind},temp.test_acc{cv_ind,iter_ind,method_ind},temp.classification_train{cv_ind,iter_ind,method_ind},temp.classification_test{cv_ind,iter_ind,method_ind}]...
                           = knnclassify(f_train',f_test',class_training,class_testing,k);
                    end
                end             
            end
            
            test_acc = cell2mat(temp.test_acc);
            test_acc = reshape(test_acc,[config.cv_num*config.iter_num, config.method_num]);
            ave_acc = mean(test_acc,1);
            
            if k==config.knn_k(1)
                knn.train_acc = temp.train_acc;
                knn.test_acc = temp.test_acc;
                knn.classification_train = temp.classification_train;
                knn.classification_test = temp.classification_test;
                
                knn.parameter = [k, k, k];
                best_test_acc = ave_acc;
            end
    
            for method_ind = 1:config.method_num
                if best_test_acc(:,method_ind) < ave_acc(:,method_ind)
                    knn.train_acc(:,:,method_ind) = temp.train_acc(:,:,method_ind);
                    knn.test_acc(:,:,method_ind) = temp.test_acc(:,:,method_ind);
                    knn.classification_train(:,:,method_ind) = temp.classification_train(:,:,method_ind);
                    knn.classification_test(:,:,method_ind) = temp.classification_test(:,:,method_ind);
        
                    knn.parameter(:,method_ind) = k;
                    best_test_acc(:,method_ind) = ave_acc(:,method_ind);
                end
            end
        end
        
        cd(config.save_dir);
        eval(sprintf('filename=[''kNN_s%dch%d'',''.mat''];',sub_id,pos_ind));
        save(filename,'knn');    
    end
end

cd(config.code_dir);