function [trnClipNos, valClipNos, testClipNos] = RandomlySelectClipIndices(self, clipT)
clipNos = unique(clipT.ClipNumber);
nClips = length(clipNos);

clipOrder = randperm(nClips);
clipNos = clipNos(clipOrder);


pTrain = self.ConfigFile.GetParams('TrainProportion');
pVal = self.ConfigFile.GetParams('ValidationProportion');
pTest = self.ConfigFile.GetParams('TestProportion');


useAllData = sum(pTrain + pVal + pTest) == 1;

nTrain = round(pTrain * nClips);
trnClipNos = clipNos(1:nTrain);
clipNos = clipNos(nTrain+1:end);

nVal = round(pVal * nClips);
valClipNos = clipNos(1:nVal);
clipNos = clipNos(nVal+1:end);

if useAllData == true
    testClipNos = clipNos;
else
    nTest = round(pTest * nClips);
    testClipNos = clipNos(1:nTest);
end
end
