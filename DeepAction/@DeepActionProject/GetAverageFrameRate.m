function fps = GetAverageFrameRate(self)
videoNames = GetVideoNames(self);

totalTime = 0;
totalFrames = 0;
for i = 1:length(videoNames)
    currAnnot = Annotation(self, videoNames{i});
    ts = currAnnot.GetTimeStamps();

    if ~isempty(ts)
        totalTime = totalTime + ts(end);
        totalFrames = totalFrames + length(ts);
    end
end

fps = totalFrames / totalTime;
end