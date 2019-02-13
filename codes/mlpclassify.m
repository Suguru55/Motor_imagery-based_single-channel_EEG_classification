function [TrainAcc,TestAcc,TrainPredict,TestPredict] = mlpclassify(TrainData,TestData,TrainClass,TestClass,TrainLabel,TestLabel,NeuroNum)

% create network
setdemorandstream(491218382)
%net = feedforwardnet(10);
net = patternnet(NeuroNum);        % number of hidden layer neurons
  
% hidden layer transfer function
net.layers{1}.transferFcn = 'tansig';

% train net
net.trainFcn = 'trainscg';                 % Scaled conjugate gradiant backpropagation
%net.performFcn = 'sae';                   % Sum absolute error
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
net.trainParam.time = 60*60; 
net.trainParam.showWindow = false; 

% train a neural network
net = train(net,TrainData,TrainClass,'useParallel','yes','useGPU','yes');
y_train = net(TrainData);

% test
%tic
y_test = net(TestData);
%time = toc;

for k = 1:length(y_train)
    [val, ind] = max(y_train(:,k));
    TrainPredict(:,k) = ind;
end

for k = 1:length(y_test)
    [val, ind] = max(y_test(:,k));
    TestPredict(:,k) = ind;
end

TrainAcc = sum(TrainPredict == TrainLabel)/length(TrainLabel)*100;
TestAcc = sum(TestPredict == TestLabel)/length(TestLabel)*100;
