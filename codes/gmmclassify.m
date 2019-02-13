function [TrainAcc,TestAcc,TrainPredict,TestPredict] = gmmclassify(TrainData,TestData,TrainClass,TestClass,Order)

opts = statset('MaxIter',100000);

for i = 1:max(TrainClass)
    temp = TrainClass==i;
    [row, col] = find(temp);
    str = ['gm',num2str(i) '= fitgmdist(TrainData(row,:),Order,''CovarianceType'',''full'',''Options'',opts,''RegularizationValue'',0.01);']; 
    eval(str);
end

% computing the class-conditional probability density function
TrainPredict = zeros(size(TrainData,1),1);
TestPredict = zeros(size(TestData,1),1);

p = [pdf(gm1,TrainData),pdf(gm2,TrainData)];
 
for i = 1:size(TrainData,1)
    [~,TrainPredict(i,:)] = max(p(i,:));
end

p = [pdf(gm1,TestData),pdf(gm2,TestData)];
 
for i = 1:size(TestData,1)
    [~,TestPredict(i,:)] = max(p(i,:));
end

TrainAcc = sum(TrainPredict == TrainClass)/length(TrainClass)*100;
TestAcc = sum(TestPredict == TestClass)/length(TestClass)*100;