function [TrainAcc,TestAcc,TrainPredict,TestPredict] = rfclassify(TrainData,TestData,TrainClass,TestClass,leaf,varargin)

options = statset('UseParallel', 'Always');
b = TreeBagger(leaf,TrainData,TrainClass,'Method','classification','Options',options);
predCharTrain = b.predict(TrainData);
TrainPredict = str2double(predCharTrain);

predCharTest = b.predict(TestData);
TestPredict = str2double(predCharTest);

TrainAcc = sum(TrainPredict == TrainClass)/length(TrainClass)*100;
TestAcc = sum(TestPredict == TestClass)/length(TestClass)*100;