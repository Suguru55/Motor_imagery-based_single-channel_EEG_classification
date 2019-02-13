function [f_train, f_test] = sccsp(pow_tr,pow_te,config,pow_tr_c,training_c)
% calculate covariance matrix
C1 = zeros(config.bin_num,config.bin_num,size(training_c{1},2));
C2 = zeros(config.bin_num,config.bin_num,size(training_c{2},2));

for i = 1:size(training_c{1},2)
    temp_c1 = squeeze(pow_tr_c{1}(:,:,i));
    temp_c2 = squeeze(pow_tr_c{2}(:,:,i));
                             
    C1(:,:,i) = (temp_c1*temp_c1')./trace(temp_c1*temp_c1');
    C2(:,:,i) = (temp_c2*temp_c2')./trace(temp_c2*temp_c2');
end
C1_ave = mean(C1,3); C2_ave = mean(C2,3);
                         
% single-channel CSP
C = C1_ave + C2_ave;
[U,D] = eig(C);
P = sqrt(inv(D))*U';
                        
S = P*C1_ave*P';
[V,~] = eig(S);
                            
W = P'*V;
W = W(:,[1:config.L, end-config.L+1:end]);             
                         
z_train = zeros(2*config.L,config.win_num,size(pow_tr,3));
f_train = zeros(2*config.L,size(pow_tr,3));
                            
z_test = zeros(2*config.L,config.win_num,size(pow_te,3));
f_test = zeros(2*config.L,size(pow_te,3));               
                         
for i = 1:size(pow_tr,3)
    z_train(:,:,i) = W'*pow_tr(:,:,i);
    f_train(:,i) = log10(var(squeeze(z_train(:,:,i)),[],2)./sum(var(squeeze(z_train(:,:,i)),[],2)));
end

for i = 1:size(pow_te,3)
    z_test(:,:,i) = W'*pow_te(:,:,i);                         
    f_test(:,i) = log10(var(squeeze(z_test(:,:,i)),[],2)./sum(var(squeeze(z_test(:,:,i)),[],2))); 
end