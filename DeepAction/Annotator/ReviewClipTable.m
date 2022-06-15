classdef ReviewClipTable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        ClipTable
        CurrentClipNumber

%         CurrentClip
    end

    methods
        function self = ReviewClipTable(clipTable)
            if any(strcmp('Features', clipTable.Properties.VariableNames))
                clipTable = removevars(clipTable, 'Features');
            end

            if any(strcmp('Indices', clipTable.Properties.VariableNames))
                clipTable = removevars(clipTable, 'Indices');
            end
            self.ClipTable = clipTable;
        end

        function labels = GetBehaviors(self)
            annotT = self.ClipTable.Annotations{1};
            labels = categories(annotT.Label);
        end

        function clipT = GetClipTable(self, varargin)
            if nargin == 2
                type = varargin{1};

                if strcmpi(type, 'complete')
                    isSet = self.ClipTable.Type == categorical({'R'});
                    clipT = self.ClipTable(isSet, :);
                    clipT = sortrows(clipT, 'ClipNumber');
                elseif strcmpi(type, 'incomplete')
                    isSet = self.ClipTable.Type == categorical({'UR'});
                    clipT = self.ClipTable(isSet, :);

                    if any(strcmp('Score', self.ClipTable.Properties.VariableNames))
                        clipT = sortrows(clipT, 'Score');
                    end
                end
            else
                clipT = self.ClipTable;
            end
        end

        function self = SetCurrentClip(self, clipNumber)
            self.CurrentClipNumber = clipNumber;
        end

        function currClipT = GetCurrentClipTable(self)
            if isempty(self.CurrentClipNumber)
                currClipT = [];
                return
            end

            isCurrClip = self.ClipTable.ClipNumber == self.CurrentClipNumber;
            currClipT = self.ClipTable(isCurrClip, :);
        end

        function currAnnot = GetCurrentAnnotation(self)
            currClipT = GetCurrentClipTable(self);
            currAnnot = currClipT.Annotations{1};
        end

        function idxs = GetIndicesWhereBehaviorOccurs(self, behavior)
            if isempty(self.CurrentClipNumber)
                idxs = [];
                return
            end

            if ~iscell(behavior)
                behavior = {behavior};
            end

            currClipT = GetCurrentClipTable(self);
            isCurrBehavior = currClipT.Annotations{1}.Label == categorical(behavior);
            idxs = currClipT.Annotations{1}.Frame(isCurrBehavior);
        end

        function clipNo = GetSelectedClipNumber(self, rowIndex, type)
            if strcmp(type, 'complete')
                currT = self.GetClipTable('complete');
            elseif strcmp(type, 'incomplete')
                currT = self.GetClipTable('incomplete');
            end

            if isempty(currT)
                clipNo = [];
                return
            end

            clipNo = currT.ClipNumber(rowIndex);
        end

        function [ts, frameNos] = GetTSAndFrameNos(self)
            currClipT = GetCurrentClipTable(self);
            currAnnot = currClipT.Annotations{1};
            ts = currAnnot.TimeStamp;
            frameNos = currAnnot.Frame;
        end

        function self = MarkComplete(self)
            if isempty(self.CurrentClipNumber)
                return
            end

            isCurr = self.ClipTable.ClipNumber == self.CurrentClipNumber;
            self.ClipTable(isCurr, :).Type(1) = categorical({'R'});
            currAnnots = self.ClipTable(isCurr, :).Annotations{1};

            for i = 1:size(currAnnots)
                toChange = currAnnots.Type == categorical({'C'});
                self.ClipTable(isCurr, :).Annotations{1}.Type(toChange) = categorical({'R'});

                toChange = currAnnots.Type == categorical({'UL'}) & ...
                           currAnnots.Label ~= categorical({'UL'});
                self.ClipTable(isCurr, :).Annotations{1}.Type(toChange) = categorical({'A'});
            end

%             newType = repmat(categorical({'A'}), size(currAnnots, 1), 1);
%             self.ClipTable(isCurr, :).Annotations{1}.Type = newType;

            clipTableTemp = self.ClipTable;
            currClip = self.ClipTable(isCurr, :);
            clipTableTemp(isCurr, :) = [];
            clipTableTemp = [currClip; clipTableTemp];
            self.ClipTable = clipTableTemp;

            self = self.SetCurrentClip([]);
        end
        
        function self = MarkIncomplete(self)
            if isempty(self.CurrentClipNumber)
                return
            end

            isCurrClip = self.ClipTable.ClipNumber == self.CurrentClipNumber;
            self.ClipTable(isCurrClip, :).Type(1) = categorical({'C'});
            currAnnots = self.ClipTable(isCurrClip, :).Annotations{1};
            newType = repmat(categorical({'C'}), size(currAnnots, 1), 1);
            self.ClipTable(isCurrClip, :).Annotations{1}.Type = newType;

            clipTableTemp = self.ClipTable;
            currClip = self.ClipTable(isCurrClip, :);
            clipTableTemp(isCurrClip, :) = [];
            clipTableTemp = [currClip; clipTableTemp];
            self.ClipTable = clipTableTemp;

            self = self.SetCurrentClip([]);
        end

        function totalDuration = GetTotalDuration(self, varargin)
            clipT = GetClipTable(self, varargin{:});

            totalDuration = 0;
            for i = 1:size(clipT, 1)
                startTime = clipT.Annotations{i}.TimeStamp(1);
                endTime = clipT.Annotations{i}.TimeStamp(end);
                currDur = endTime - startTime;
                totalDuration = totalDuration + currDur;
            end
            
            totalDuration = seconds(totalDuration);

            if hours(totalDuration) < 1
                totalDuration.Format = 'mm:ss';
            else
                totalDuration.Format = 'hh:mm:ss';
            end
        end

        function self = RenameBehavior(self, oldName, newName)
            currT = self.ClipTable.Annotations{1};
            oldCats = categories(currT.Label);

            if ~any(strcmp(oldName, oldCats))
                self = AddBehavior(self, newName);
            elseif any(strcmp(newName, oldCats))
                for i = 1:size(self.ClipTable)
                    currLabels = self.ClipTable.Annotations{i}.Label;
                    isOldCat = currLabels == categorical({oldName});
                    self.ClipTable.Annotations{i}.Label(isOldCat) = categorical({newName});

                    if any(strcmp(oldName, oldCats))
                        self.ClipTable.Annotations{i}.Label = removecats(currLabels, oldName);
                    end
                end
            else
                for i = 1:size(self.ClipTable)
                    currT = self.ClipTable.Annotations{i};
                    self.ClipTable.Annotations{i}.Label = renamecats(currT.Label, oldName, newName);
                end
            end
        end

        function self = AddBehavior(self, newBehavior)
            for i = 1:size(self.ClipTable)
                currT = self.ClipTable.Annotations{i};
                self.ClipTable.Annotations{i}.Label = addcats(currT.Label, newBehavior);
            end

%             self = SetCurrentClip(self, self.CurrentClipNumber);
        end

        function self = RemoveBehavior(self, toRemove)
            for i = 1:size(self.ClipTable)
                currT = self.ClipTable.Annotations{i};
                currCats = categories(self.ClipTable.Annotations{i}.Label);
                if any(strcmp(toRemove, currCats))
                    self.ClipTable.Annotations{i}.Label = removecats(currT.Label, toRemove);
                end
            end

%             self = SetCurrentClip(self, self.CurrentClipNumber);
        end

        function self = SetBehavior(self, indices, behaviorLabel)
            if ~iscell(behaviorLabel)
                behaviorLabel = {behaviorLabel};
            end

            isCurrClip = self.ClipTable.ClipNumber == self.CurrentClipNumber;
            self.ClipTable(isCurrClip, :).Annotations{1}.Label(indices) = categorical(behaviorLabel);
        end


    end
end