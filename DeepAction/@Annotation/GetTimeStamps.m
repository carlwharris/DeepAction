function ts = GetTimeStamps(self)
self = self.Load();

if isempty(self.AnnotationTable)
    ts = [];
    return
end

if self.MultiCam
    ts = self.AnnotationTable.TimeStamp;
    ts = ts.(self.PrimaryCamera);
else
    ts = self.AnnotationTable.TimeStamp.TimeStamp;
end
end