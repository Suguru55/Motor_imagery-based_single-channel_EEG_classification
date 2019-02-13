function struct = set_config

% change your directory
main_dir = 'C:\Users\3usgr\Desktop\SC_motor_imagery\';
struct.code_dir = [main_dir, 'codes'];
struct.data_dir = [main_dir, 'data'];
struct.save_dir = main_dir;
struct.svm_toolbox = 'C:\toolbox\libsvm-3.23\matlab';

% general
struct.Fs = 250;
struct.session_num = 2;   % training and evaluation sessions
struct.sub_num = 9;
struct.position_num = 22; % 22 channels
struct.cv_num = 10;       % 10-fold CV
struct.iter_num = 10;     % 10 iterations
struct.method_num = 3;    % PS, GLCM, SCCEP

% filter
fh = 40; % Butterworth filter
fl = 4;
order = 4;
struct.d = designfilt('bandpassiir',...
                      'FilterOrder',order,...
                      'HalfPowerFrequency1',fl,...
                      'HalfPowerFrequency2',fh,...
                      'DesignMethod','butter',...
                      'SampleRate',struct.Fs);

% epoching
struct.pre_time = 2.5;
struct.post_time = 4.5;
                  
% feature extraction
struct.win_num = 9;
struct.window_size = 100;
struct.nfft = 128;
struct.overlap = 50;
struct.bin_num = 20;
struct.L = 7;
struct.offsets = [0 1; -1 1; -1 0; -1 -1]; % offsets for GLCM