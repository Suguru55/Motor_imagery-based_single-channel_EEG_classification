function [lib_Epochs, lib_classlabel] = load_data(config, sub_id)
% Prepare epochs containing clean EEG epochs of class 1 and class 2

for session_id = 1:config.session_num
    cd(config.data_dir);
    if session_id == 1
        eval(sprintf('filename = [''A0%dT.gdf''];',sub_id));
        eval(sprintf('labelname = [''A0%dT.mat''];',sub_id));
    else
        eval(sprintf('filename = [''A0%dE.gdf''];',sub_id));
        eval(sprintf('labelname = [''A0%dE.mat''];',sub_id));           
    end
    
    [s, HDR] = sload(filename, 0, 'OVERFLOWDETECTION:ON');
    load(labelname);
        
    % fill NaN values in s
    s = fillmissing(s,'spline');
        
    % filtering
    f_s = zeros(size(s));
    for i = 1:size(s,2)
        f_s(:,i) = filtfilt(config.d, s(:,i));
    end
    
    % sprit continuous signals into epochs
    PRE = config.pre_time*config.Fs;
    PST = config.post_time*config.Fs-1;
        
    [X, sz] = trigg(f_s, HDR.TRIG, PRE, PST);
    Epochs = reshape(X,sz);
    cd(config.code_dir);
        
    % remove class 3 (foot) and class 4 (tongue) epochs
    Epochs(:,:,(classlabel==3 | classlabel==4)) = [];
    HDR.ArtifactSelection((classlabel==3 | classlabel==4),:) = [];
    classlabel((classlabel==3 | classlabel==4),:) = [];
        
    % remove artifactual epochs
    artifact_id = find(HDR.ArtifactSelection);
        
    Epochs(:,:,artifact_id) = [];
    classlabel(artifact_id,:) = [];
        
    if session_id == 1
        lib_Epochs = Epochs;
        lib_classlabel = classlabel;
    else
        lib_Epochs = cat(3,lib_Epochs,Epochs);
        lib_classlabel = [lib_classlabel; classlabel];
    end
end