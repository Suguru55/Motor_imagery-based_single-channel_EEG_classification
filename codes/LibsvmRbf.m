function [TrainAcc,TestAcc,TrainPredict,TestPredict] = LibsvmRbf(TrainData,TestData,TrainClass,TestClass,log2c,log2g,config)
cd(config.svm_toolbox);
% s 0: C-SVM
% t 0: linear; 1: polynomial; 2: rbf; 3: sigmoid
cmd = ['-q -s 0 -t 2 -g ', num2str(2^log2g), '-c ', num2str(2^log2c),'-b 0'];
model = svmtrain(TrainClass, TrainData, cmd);
[TestPredict, accuracy,~] = svmpredict(TestClass,TestData,model,'-b 0');

TestAcc = accuracy(1,1);
%TrainPredict = classify(TrainData,TrainData,TrainClass);
%TestPredict = classify(TestData,TrainData,TrainClass);
[TrainPredict, accuracy,~] = svmpredict(TrainClass,TrainData,model,'-b 0');
TrainAcc = accuracy(1,1);