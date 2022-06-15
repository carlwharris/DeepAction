classdef FrameReader
    properties 
        Path % path of the input video
        
        ImageType
        
        % Reader - Reader for .seq and standard video formats
        Reader
                
        CurrentIndex % current frame index
        
        NumFrames
        Dimensions
        FrameRate
        
        ImageDS % imageDataStore for when reading frames from folder
        SeqTS
    end
    
    methods
        function self = FrameReader(path)
            %FRAMEREADER    Read frames from input file/folder
            % 
            
            self.Path = path;
            
            if ~isfile(path) && ~isfolder(path)
                fprintf('File %s not found!\n', self.Path)
                self = [];
                return
            end
            
            if contains(self.Path, '.seq')
                self.ImageType = 'sequence';
            elseif contains(self.Path, '.mp4') || contains(self.Path, '.avi') || contains(self.Path, '.mpg')
                self.ImageType = 'video';
            else
                self.ImageType = 'image';
            end
            
            self.CurrentIndex = 1;
            
            if strcmp(self.ImageType, 'image')
                [self.Reader, nFrames, dim, fps] = CreateFolderReader(self.Path);
            elseif strcmp(self.ImageType, 'sequence')
                [self.Reader, nFrames, dim, fps] = CreateSequenceFileReader(self.Path);

                outTS = self.Reader.getts();
                diff = outTS(2:end) - outTS(1:end-1);
                diff = seconds([0; diff']);
                diff = cumsum(diff);
                self.SeqTS = seconds(diff);
            else
                [self.Reader, nFrames, dim, fps] = CreateStandardVideoReader(self.Path);
            end
            
            self.NumFrames = nFrames;
            self.Dimensions = dim;
            self.FrameRate = fps;
        end
        
        function hasFrame = HasFrame(self)
            %HasFrame  return logical value for whether there are more frames
            hasFrame = self.CurrentIndex <= self.NumFrames;
        end
                
        function [self, frame, ts] = ReadFrame(self, varargin)

            %READFRAME   read frame from input
            % OPTIONAL
            % varargin{1} - frame number
            
            if nargin == 2
                self.CurrentIndex = varargin{1};
            end
            
            if ~HasFrame(self)
                frame = [];
                ts = [];
                return
            end

            if strcmp(self.ImageType, 'image')
               frame = imread(self.Reader.Files{self.CurrentIndex});
               ts = self.CurrentIndex / self.FrameRate;
            elseif strcmp(self.ImageType, 'sequence')
                out = self.Reader.seek(self.CurrentIndex-1);
                frame = self.Reader.getframe();
                ts = self.SeqTS(self.CurrentIndex);
            else
                frame = read(self.Reader, self.CurrentIndex);
                ts = self.Reader.CurrentTime;
            end
            
            self.CurrentIndex = self.CurrentIndex + 1;
        end

        function Close(self)
            if strcmp(self.ImageType, 'sequence')
                self.Reader.close();

                [~, baseName, ~] = fileparts(self.Path);
                currFolderFiles = GetValidFolderFiles(pwd);
    
                containsCurrName = contains(currFolderFiles.name, baseName);
                currFolderFiles = currFolderFiles(containsCurrName, :);
    
                containsTmp = contains(currFolderFiles.name, 'png') | ...
                    contains(currFolderFiles.name, 'jpg');
                currFolderFiles = currFolderFiles(containsTmp, :);
    
                for i = 1:size(currFolderFiles,1)
                    delete(fullfile(currFolderFiles.folder{i}, currFolderFiles.name{i}))
                end
            end

            

        end
    end
end

function [reader, nFrames, dim, fps] = CreateFolderReader(path)
reader = imageDatastore(path);

fps = 30;

dsFiles = reader.Files;
testImgPath = dsFiles{1};
nFrames = size(dsFiles,1);

testImg = imread(testImgPath);
imgSize = size(testImg);
dim = [imgSize(1), imgSize(2)];
end

function [reader, nFrames, dim, fps] = CreateSequenceFileReader(path)
reader = seqIo(path, 'reader');
info = reader.getinfo();

nFrames = info.numFrames;
dim = [info.height, info.width];
fps = info.fps;
end

function [reader, nFrames, dim, fps] = CreateStandardVideoReader(path)
reader = VideoReader(path);

nFrames = reader.NumFrames;
fps = reader.FrameRate;
dim = [reader.Height, reader.Width];
end