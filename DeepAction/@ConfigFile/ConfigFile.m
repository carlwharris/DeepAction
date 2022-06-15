classdef ConfigFile

    properties
        FilePath
        
        Params
        WriteToFile = true
    end
    
    methods
        function self = ConfigFile(configFilePath)
            self.FilePath = configFilePath;
            
            if isfile(self.FilePath)
                self = GenerateParams(self);
            end
        end
        

        
        
        params = GetParams(self, varargin)
        
        configFileParams = ParseConfigFile(self)
        defaultParams = GetDefaultParams(self)
        
        self = GenerateParams(self)

        function AddBehavior(self, newBehavior, newKey)
            currBehaviors = self.GetParams('Behaviors');
            currKeys = self.GetParams('Keys');
            
            if ~iscell(newBehavior)
                newBehavior = {newBehavior};
            end

            if ~iscell(newKey)
                newKey = {newKey};
            end

            allBehaviors = [currBehaviors; newBehavior];
            allKeys = [currKeys; newKey];
            EditBehaviors(self, allBehaviors, allKeys)
        end

        function RemoveBehavior(self, toRemove)
            currBehaviors = self.GetParams('Behaviors');
            currKeys = self.GetParams('Keys');

            isBehav = strcmp(toRemove, currBehaviors);
            allBehaviors = currBehaviors(~isBehav);
            allKeys = currKeys(~isBehav);

            EditBehaviors(self, allBehaviors, allKeys)
        end

        function RenameBehavior(self, oldName, newName)
            currBehaviors = self.GetParams('Behaviors');
            currKeys = self.GetParams('Keys');

            isOldName = strcmp(oldName, currBehaviors);

            if ~any(isOldName)
                return
            end
            
            currBehaviors{isOldName} = newName;

            EditBehaviors(self, currBehaviors, currKeys)
        end

        function ChangeBehaviorKey(self, behavior, newKey)
            currBehaviors = self.GetParams('Behaviors');
            currKeys = self.GetParams('Keys');

            isBehav = strcmp(behavior, currBehaviors);

            if ~any(isBehav)
                return
            end

            currKeys{isBehav} = newKey;

            EditBehaviors(self, currBehaviors, currKeys)
        end

        function EditBehaviors(self, allBehaviors, allKeys)
            contents = fileread(self.FilePath);
            fileLines = strsplit(contents, '\n', 'CollapseDelimiters', false);  
            lineIdx = find(contains(fileLines, 'Behaviors (key)'), true, 'first');

            targetLine = fileLines{lineIdx};

            isBehaviorLine = true;
            behaviorLines = [];
            currentLine = lineIdx + 1;
            while isBehaviorLine
                if contains(fileLines{currentLine}, '-')
                    behaviorLines = [behaviorLines; currentLine];
                    currentLine = currentLine + 1;
                else
                    isBehaviorLine = false;
                end

            end

            newLines = {};
            for i = 1:length(allBehaviors)
                currBehav = allBehaviors{i};
                currKey = allKeys{i};
                currLine = sprintf('  \t- %s (%s)', currBehav, currKey);
                newLines = [newLines {currLine}];
            end
            
            startFile = fileLines(1:lineIdx);
            endFile = fileLines(behaviorLines(end)+1:end);
            newFileLines = [startFile, newLines, endFile];

            newFileLines = strjoin(newFileLines, '\n');
            fid = fopen(self.FilePath, 'w');
            fwrite(fid, newFileLines);
            fclose(fid);

        end

        
        
        function self = SetTempParam(self, paramName, newValue)
            fieldNSection = fieldnames(self.Params);
            for i = 1:length(fieldNSection)
                currSection = self.Params.(fieldNSection{i});
                
                fieldN = fieldnames(currSection);
                
                for j = 1:length(fieldN)
                    if strcmpi(paramName, fieldN{j})
                        self.Params.(fieldNSection{i}).(fieldN{j}) = newValue;
                    end
                end
            end
            
            self.WriteToFile = false;
        end
        
        function EditFile(self, paramName, newValue)
            contents = fileread(self.FilePath);
            fileLines = strsplit(contents, '\n', 'CollapseDelimiters', false);  
            lineIdx = find(contains(fileLines, paramName), true, 'first');

            targetLine = fileLines{lineIdx};
            k = strfind(targetLine,'=');
            
            if ~ischar(newValue)
%                 if ~contains(newValue, '''')
%                     newValue = sprintf('''%s''', newValue);
%                 end
%             else
                newValue = convertStringsToChars(string(newValue));
            end
            newLine = [targetLine(1:k) newValue];
            
            fileLines{lineIdx} = newLine;
            
            newcontents = strjoin(fileLines, '\n');
            fid = fopen(self.FilePath, 'w');
            fwrite(fid, newcontents);
            fclose(fid);
        end
        self = CreateConfigFile(self)
        
        function params = GetAllParams(self)
            self = GenerateParams(self);
            params = self.Params;
        end
    end
    
    
    
    methods (Static)
        function line = CreateLine(fieldName, value)
            if ischar(value)
                line = sprintf('  %s=''%s''\n', fieldName, value);
            end

            if isnumeric(value)
                if isempty(value)
                    line = sprintf('  %s=[]\n', fieldName);
                else
                    line = sprintf('  %s=%.10g\n', fieldName, value);
                end
            end

            if islogical(value)
                if value == true
                    line = sprintf('  %s=true\n', fieldName);
                else
                    line = sprintf('  %s=false\n', fieldName);
                end
            end

            if iscell(value)
                if strcmpi(fieldName, 'Behaviors')
                    line = [];
                    currLine = sprintf('  Behaviors\n');
                    line = [line currLine];

                    for i = 1:length(value)
                        currLine = sprintf('    - %s\n', value{i});
                        line = [line currLine];
                    end
                else
                    line = [];
                    currLine = sprintf('  %s=[', fieldName);
                    line = [line currLine];

                    for i = 1:length(value)
                        if i ~= length(value)
                            currLine = sprintf('''%s'', ', value{i});
                        else
                            currLine = sprintf('''%s'']\n', value{i});
                        end
                        line = [line currLine];
                    end
                end
            end

            end

    end
end

