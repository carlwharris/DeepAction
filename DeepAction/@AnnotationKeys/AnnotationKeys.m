classdef AnnotationKeys < DeepActionProject
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FilePath
        KeyTable
    end

    methods
        function self = AnnotationKeys(project, varargin)
            self = self@DeepActionProject(project.ProjectPath)
            
            self.FilePath = fullfile(self.ProjectPath, 'annotations/annotator_keys.mat');

            if ~isfile(self.FilePath)
                self.KeyTable = table({}, {}, 'VariableNames', {'Behavior', 'Key'});
                Save(self)
            end
            
            load(self.FilePath, 'KeyTable')
            self.KeyTable = KeyTable;
            self = self.Update();
        end

        function keyT = GetKeyTable(self)
            keyT = self.KeyTable;
        end

        function self = Update(self)
            annotFileBehaviors = GetAnnotationFileBehaviors(self);

            for i = size(self.KeyTable, 1):-1:1
                if ~any(strcmpi(self.KeyTable.Behavior{i}, annotFileBehaviors))
                    self.KeyTable(i, :) = [];
                end
            end

            for i = 1:length(annotFileBehaviors)
                if ~any(strcmp(annotFileBehaviors{i}, self.KeyTable.Behavior))
                    possValues = ['123456789', 'a':'z', 'A':'Z'];
                    newKey = [];
                    for j = length(possValues):-1:1
                        if ~any(strcmp(possValues(j), self.KeyTable.Key))
                            newKey = possValues(j);
                        end
                    end

                    tmpT = table(annotFileBehaviors(i), {newKey}, 'VariableNames', {'Behavior', 'Key'});
                    self.KeyTable = [self.KeyTable; tmpT];
                end
            end

            Save(self)
        end

        function Save(self)
            KeyTable = self.KeyTable;
            save(self.FilePath, 'KeyTable')

            if ~isempty(KeyTable)
                tablePath = fullfile(self.ProjectPath, 'annotations/annotator_keys.txt');
                FormatTableToTxtFile(KeyTable, tablePath, 'Title', 'Annotator Keys')
            end
        end

        function behavs = GetAnnotationFileBehaviors(self)
            folders = GetValidSubFolders(fullfile(self.ProjectPath, 'annotations'));

            annotFileBehavs = {};
            for i = 1:size(folders,1)
                currVideo = folders.name{i};

                currAnnot = Annotation(self, currVideo);
                currBehaviors = currAnnot.GetBehaviors();

                annotFileBehavs = [annotFileBehavs; currBehaviors];
            end
            behavs = unique(annotFileBehavs);
        end

        function self = AddBehavior(self, newBehavior, newKey)
            if ~iscell(newBehavior)
                newBehavior = {newBehavior};
            end

            if ~iscell(newKey)
                newKey = {newKey};
            end

            allBehaviors = [self.KeyTable.Behavior; newBehavior];
            allKeys = [self.KeyTable.Key; newKey];

            self.KeyTable = table(allBehaviors, allKeys, 'VariableNames', {'Behavior', 'Key'});
        end

        
%         function self = AddBehavior(self, newBehavior, varargin)
%             currBehaviors = self.KeyTable.Behavior;
%             currKeys = self.KeyTable.Key;
% 
%             if nargin == 3
%                 newKey = varargin{1};
%             else
%                 possValues = ['123456789', 'a':'z', 'A':'Z'];
%                 newKey = [];
%                 for i = length(possValues):-1:1
%                     if ~any(strcmp(possValues(i), currKeys))
%                         newKey = possValues(i);
%                     end
%                 end
%             end
%             
%             if ~iscell(newBehavior)
%                 newBehavior = {newBehavior};
%             end
% 
%             if ~iscell(newKey)
%                 newKey = {newKey};
%             end
% 
%             allBehaviors = [currBehaviors; newBehavior];
%             allKeys = [currKeys; newKey];
% 
%             self.KeyTable = table(allBehaviors, allKeys, 'VariableNames', {'Behavior', 'Key'});
%         end

        function self = RemoveBehavior(self, toRemove)
            currBehaviors = self.KeyTable.Behavior;
            currKeys = self.KeyTable.Key;
            
            isBehav = strcmp(toRemove, currBehaviors);
            allBehaviors = currBehaviors(~isBehav);
            allKeys = currKeys(~isBehav);

            self.KeyTable = table(allBehaviors, allKeys, 'VariableNames', {'Behavior', 'Key'});
        end

        function self = RenameBehavior(self, oldName, newName)
            currBehaviors = self.KeyTable.Behavior;

            isOldName = strcmp(oldName, currBehaviors);
            
            currBehaviors{isOldName} = newName;
            currKeys = self.KeyTable.Key;
            self.KeyTable = table(currBehaviors, currKeys, 'VariableNames', {'Behavior', 'Key'});
        end

        function self = ChangeBehaviorKey(self, behavior, newKey)
            currBehaviors = self.KeyTable.Behavior;
            currKeys = self.KeyTable.Key;

            isBehav = strcmp(behavior, currBehaviors);

            if ~any(isBehav)
                return
            end

            currKeys{isBehav} = newKey;

            self.KeyTable = table(currBehaviors, currKeys, 'VariableNames', {'Behavior', 'Key'});
        end

        function self = ShiftBehaviorUp(self, behavior)
            behaviorIdx = find(strcmp(behavior, self.KeyTable.Behavior));
            if behaviorIdx == 1
                return
            end
            
            tmp = self.KeyTable(behaviorIdx-1, :);
            self.KeyTable(behaviorIdx-1, :) = self.KeyTable(behaviorIdx, :);
            self.KeyTable(behaviorIdx, :) = tmp;

        end

        function self = ShiftBehaviorDown(self, behavior)
            behaviorIdx = find(strcmp(behavior, self.KeyTable.Behavior));
            if behaviorIdx == size(self.KeyTable,1)
                return
            end
            
            tmp = self.KeyTable(behaviorIdx+1, :);
            self.KeyTable(behaviorIdx+1, :) = self.KeyTable(behaviorIdx, :);
            self.KeyTable(behaviorIdx, :) = tmp;
        end
    end
end