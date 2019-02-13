function postprocessing_mlp(config)

for sub_id = 1:config.sub_num
    temp.train_acc = cell(config.cv_num,config.iter_num,config.method_num);
    temp.test_acc = cell(config.cv_num,config.iter_num,config.method_num);
    temp.classification_train = cell(config.cv_num,config.iter_num,config.method_num);
    temp.classification_test = cell(config.cv_num,config.iter_num,config.method_num);
    mlp.train_acc = cell(config.cv_num,config.iter_num,config.method_num);
    mlp.test_acc = cell(config.cv_num,config.iter_num,config.method_num);
    mlp.classification_train = cell(config.cv_num,config.iter_num,config.method_num);
    mlp.classification_test = cell(config.cv_num,config.iter_num,config.method_num);
    
    for pos_ind = 1:config.position_num
        %%%%%%%%%%%%%
        % load data %
        %%%%%%%%%%%%%
        cd(config.data_dir);
        eval(sprintf('filename=[''feature_s%dch%d'']',sub_id,pos_ind));
        load(filename);
        
        class_testing_last = class_testing;
        class_training_last = class_training;        
            
        for neuro_ind = [16,32,64,100,150,200,250,300,400]
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
                       
                       output_train_matrix = zeros(2,size(class_training,1));
                       output_test_matrix = zeros(2,size(class_testing,1));
        
                       for i = 1:size(class_training,1)
                           if class_training(i,:) == 1
                               output_train_matrix(1,i) = 1;
                           else
                               if class_training(i,:) == 2
                                   output_train_matrix(2,i) = 1;
                               end
                           end
                       end
                       
                       for i = 1:size(class_testing,1)
                           if class_testing(i,:) == 1
                               output_test_matrix(1,i) = 1;
                           else
                               if class_testing(i,:) == 2
                                   output_test_matrix(2,i) = 1;
                               end
                           end
                       end
                       
                       cd(config.code_dir);
                       [temp.train_acc{cv_ind,iter_ind,method_ind},temp.test_acc{cv_ind,iter_ind,method_ind},temp.classification_train{cv_ind,iter_ind,method_ind},temp.classification_test{cv_ind,iter_ind,method_ind}]...
                           = mlpclassify(f_train,f_test,output_train_matrix,output_test_matrix,class_training',class_testing',neuro_ind);
                    end
                end             
            end
            
            test_acc = cell2mat(temp.test_acc);
            test_acc = reshape(test_acc,[config.cv_num*config.iter_num,config.method_num]);
            ave_acc = mean(test_acc,1);
            
            if neuro_ind==16
                mlp.train_acc = temp.train_acc;
                mlp.test_acc = temp.test_acc;
                mlp.classification_train = temp.classification_train;
                mlp.classification_test = temp.classification_test;
                
                mlp.parameter = [neuro_ind, neuro_ind, neuro_ind];
                best_test_acc = ave_acc;
            end
    
            for method_ind = 1:method_num
                if best_test_acc(:,method_ind) < ave_acc(:,method_ind)
                    mlp.train_acc(:,:,method_ind) = temp.train_acc(:,:,method_ind);
                    mlp.test_acc(:,:,method_ind) = temp.test_acc(:,:,method_ind);
                    mlp.classification_train(:,:,method_ind) = temp.classification_train(:,:,method_ind);
                    mlp.classification_test(:,:,method_ind) = temp.classification_test(:,:,method_ind);
        
                    mlp.parameter(:,method_ind) = neuro_ind;
                    best_test_acc(:,method_ind) = ave_acc(:,method_ind);
                end
            end
            disp(['Neuro_ind =',num2str(neuro_ind)])
        end
        
        cd(config.save_dir);
        eval(sprintf('filename=[''MLP_s%dch%d'',''.mat''];',sub_id,pos_ind));
        save(filename,'mlp');    
    end
end

cd(config.code_dir);