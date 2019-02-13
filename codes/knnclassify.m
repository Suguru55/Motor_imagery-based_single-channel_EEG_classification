function [TrainAcc,TestAcc,TrainPredict,TestPredict] = knnclassify(TrainData,TestData,TrainClass,TestClass,k)

%TrainPredict = classify(TrainData,TrainData,TrainClass);
%TestPredict = classify(TestData,TrainData,TrainClass);
Mdl = fitcknn(TrainData,TrainClass,'NumNeighbors',k);
TrainPredict = predict(Mdl,TrainData);
TestPredict = predict(Mdl,TestData);

TrainAcc = sum(TrainPredict == TrainClass)/length(TrainClass)*100;
TestAcc = sum(TestPredict == TestClass)/length(TestClass)*100;