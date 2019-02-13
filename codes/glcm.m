function [f_train, f_test] = glcm(pow_tr,pow_te,config)

sub_bands = 3; % theta, alpha, beta
feat_type = 4; % 

f_train = zeros(sub_bands*feat_type*size(config.offsets,1),size(pow_tr,3));
f_test = zeros(sub_bands*feat_type*size(config.offsets,1),size(pow_te,3));
                         
% divide into frequency sub-bands(1:4 4-8 Hz, 4:6 8-12 Hz, 6:20 12-40 Hz)
for i = 1:size(pow_tr,3)
    theta_band = pow_tr(1:4,:,i);
    alpha_band = pow_tr(4:6,:,i);
    beta_band = pow_tr(6:20,:,i);
                             
    theta_glcms = graycomatrix(theta_band,'GrayLimits',[],'Offset',config.offsets,'Symmetric', true);
    theta_stats = graycoprops(theta_glcms);
    theta_features = [theta_stats.Contrast(:);theta_stats.Correlation(:);theta_stats.Energy(:);theta_stats.Homogeneity(:)];
                             
    alpha_glcms = graycomatrix(alpha_band,'GrayLimits',[],'Offset',config.offsets,'Symmetric', true);
    alpha_stats = graycoprops(alpha_glcms);
    alpha_features = [alpha_stats.Contrast(:);alpha_stats.Correlation(:);alpha_stats.Energy(:);alpha_stats.Homogeneity(:)];
                             
    beta_glcms = graycomatrix(beta_band,'GrayLimits',[],'Offset',config.offsets,'Symmetric', true);
    beta_stats = graycoprops(beta_glcms);
     beta_features = [beta_stats.Contrast(:);beta_stats.Correlation(:);beta_stats.Energy(:);beta_stats.Homogeneity(:)];
                             
     f_train(:,i) = [theta_features; alpha_features; beta_features];
end

for i = 1:size(pow_te,3)
    theta_band = pow_te(1:4,:,i);
    alpha_band = pow_te(4:6,:,i);
    beta_band = pow_te(6:20,:,i);
                             
    theta_glcms = graycomatrix(theta_band,'GrayLimits',[],'Offset',config.offsets,'Symmetric', true);
    theta_stats = graycoprops(theta_glcms);
    theta_features = [theta_stats.Contrast(:);theta_stats.Correlation(:);theta_stats.Energy(:);theta_stats.Homogeneity(:)];
                             
    alpha_glcms = graycomatrix(alpha_band,'GrayLimits',[],'Offset',config.offsets,'Symmetric', true);
    alpha_stats = graycoprops(alpha_glcms);
    alpha_features = [alpha_stats.Contrast(:);alpha_stats.Correlation(:);alpha_stats.Energy(:);alpha_stats.Homogeneity(:)];
                             
    beta_glcms = graycomatrix(beta_band,'GrayLimits',[],'Offset',config.offsets,'Symmetric', true);
    beta_stats = graycoprops(beta_glcms);
    beta_features = [beta_stats.Contrast(:);beta_stats.Correlation(:);beta_stats.Energy(:);beta_stats.Homogeneity(:)];
                             
    f_test(:,i) = [theta_features; alpha_features; beta_features];
end