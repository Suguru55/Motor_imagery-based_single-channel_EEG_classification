function [TrainAcc,TestAcc,TrainPredict,TestPredict] = ldaclassify(TrainData,TestData,TrainClass,TestClass)

%TrainPredict = classify(TrainData,TrainData,TrainClass);
%TestPredict = classify(TestData,TrainData,TrainClass);
obj = fitcdiscr(TrainData,TrainClass);
TrainPredict = predict(obj,TrainData);
TestPredict = predict(obj,TestData);


TrainAcc = sum(TrainPredict == TrainClass)/length(TrainClass)*100;
TestAcc = sum(TestPredict == TestClass)/length(TestClass)*100;
