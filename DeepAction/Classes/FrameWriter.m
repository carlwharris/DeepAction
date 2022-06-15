classdef FrameWriter
    
    properties
        Path % path of the output video
        
        % SequenceReader - reader for .seq input type
        Writer
                
        CurrentIndex % current frame index
        
        % Opts - options for output
        %   .OverWriteExisting - whether or not to over-write if exists
        
        % Info - info about the input video
        %   .ImageType   - file type of the input
        %     'Folder', 'Sequence', 'mp4'
        %   .Extension  - extension of output
        %   .NumFrames  - number of frames in input file
        %   .FrameRate  - frame rate of input file (default is 30 for folders)
        %   .Width      - width of video frame
        %   .Height     - height of video frame
        %   .IsRGB      - number color channels (1 for greyscale, 3 for RGB)
        %   .FrameName  - for folder output, base name for images
        ImageType
        FrameRate
        Dimensions
        Name
        Extension
    end
    
    methods
        function self = FrameWriter(path, varargin)
            if iscell(path)
                path = path{1};
            end
            self.Path = path;
            
            p = inputParser;
            addOptional(p,'FrameRate', 30);
            addOptional(p,'Extension', 'jpg');
            addOptional(p,'Quality', 85);
            parse(p, varargin{:});
   
            self.FrameRate = p.Results.FrameRate;
            self.Extension = strrep(p.Results.Extension, '.', '');
            self.Dimensions = [];
            
            if contains(self.Path, '.seq')
                self.ImageType = 'sequence';
            elseif contains(self.Path, '.mp4') || contains(self.Path, '.avi') || contains(self.Path, '.mpg')
                self.ImageType = 'video';
            else
                self.ImageType = 'image';
            end
            
            self.CurrentIndex = 1;
            
            [~, self.Name, ~] = fileparts(self.Path);
            
            if strcmp(self.ImageType, 'image')
                if ~isfolder(self.Path)                    
                    mkdir(self.Path)
                end
            else
                [folder, ~, ~] = fileparts(self.Path);
                
                if ~isfolder(folder)
                    mkdir(folder)
                end
                
                if strcmp(self.ImageType, 'sequence')
                    self.Writer = [];
                else
                    if strcmp(self.ImageType, 'video')
                        self.Writer = VideoWriter(self.Path, 'MPEG-4');
                        self.Writer.FrameRate = self.FrameRate;
                        self.Writer.Quality = p.Results.Quality;
                        open(self.Writer)
                    end
                end
            end
        end
        
        function self = WriteFrame(self, frame, varargin)
            %varargin{1} = ts
            
            if self.CurrentIndex == 1
                self.Dimensions = [size(frame,1) size(frame,2)];
                
                if strcmp(self.ImageType, 'sequence')
                    if length(size(frame)) == 3
                        if strcmpi(self.Extension, 'png')
                            codec = 'imageFormat002';
                        elseif strcmpi(self.Extension, 'jpg')
                            codec = 'imageFormat201';
                        end
                    else
                        if strcmpi(self.Extension, 'png')
                            codec = 'imageFormat001';
                        elseif strcmpi(self.Extension, 'jpg')
                            codec = 'imageFormat102';
                        end
                    end

                    sequenceWriterInfo = struct('height', self.Dimensions(1), ...
                        'width', self.Dimensions(2), ...
                        'quality', 80, ...
                        'codec', codec, ...
                        'fps', self.FrameRate);
                    self.Writer = seqIo(self.Path, 'writer', sequenceWriterInfo);
                end
            end
            
            if nargin == 3
                ts = varargin{1};
            else
                ts = self.CurrentIndex / self.FrameRate;
            end
            
            if strcmp(self.ImageType, 'image')
                currFrameName = sprintf('%s_%06d.%s', self.Name, ...
                    self.CurrentIndex, ...
                    self.Extension);
                currOutPath = fullfile(self.Path, currFrameName);
                imwrite(frame, currOutPath);
            elseif strcmp(self.ImageType, 'sequence')
                self.Writer.addframe(frame, ts);
            else
                writeVideo(self.Writer, frame);
            end
            
            self.CurrentIndex = self.CurrentIndex + 1;
        end
        
        function self = Close(self)
            if ~strcmp(self.ImageType, 'image')
                if strcmp(self.ImageType, 'sequence')
                    self.Writer.close();
                else
                    close(self.Writer);
                end
            end
        end
    end
end