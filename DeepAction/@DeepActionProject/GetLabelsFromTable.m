function labels = GetLabelsFromTable(t)
labels = {};

for i=1:size(t, 1)
    labels = [labels; {t.Annotations{i}.Label}];
end
end