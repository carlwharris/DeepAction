function DisplayProgress(currIdx, endIdx, varargin)

p = inputParser;
addOptional(p, 'SimpleOutput', false);
addOptional(p, 'CurrentName', []);
addOptional(p, 'ShowAllOutput', true);
addOptional(p, 'TotalUpdates', 1000);
parse(p, varargin{:});

showAllOutput = p.Results.ShowAllOutput;

if p.Results.SimpleOutput == true
    
    if currIdx == 1
        fprintf('\n');
    end
    
    if ~isempty(p.Results.CurrentName)
        msg = sprintf('\t\t%s Complete (%d of %d)\n', p.Results.CurrentName, currIdx, endIdx);
    else
        msg = sprintf('\t\t%d of %d Complete\n', p.Results.CurrentName, currIdx, endIdx);
    end
    fprintf('%s', msg);
end

if p.Results.SimpleOutput == false
persistent DisplayProgressTic

if currIdx == 1 || isempty(DisplayProgressTic)
    DisplayProgressTic = tic;
end

if endIdx > p.Results.TotalUpdates
    if p.Results.TotalUpdates <= endIdx
        displayIdxs = round(linspace(1, endIdx, p.Results.TotalUpdates));
    end
else
    displayIdxs = 1:endIdx;
end

nDigitsIdxTxt = numel(num2str(endIdx));

idxHeader = sprintf('Idx/Total');
digitSpace = 2 * nDigitsIdxTxt + 1;

digitSpace = max([length(idxHeader) digitSpace]);
nSpaces = (digitSpace - length(idxHeader))/2;

spaces = repmat(' ', 1, nSpaces);
equals = repmat('=', 1, digitSpace);

if ismember(currIdx, displayIdxs)
    propElapsed = currIdx / endIdx;
    
    idx = find(ismember(displayIdxs, currIdx));
    
    if idx ~= 1
        elapsedTime = toc(DisplayProgressTic);
        
        timePerStep = elapsedTime / (currIdx-1);
        estTotTime = timePerStep * endIdx;
        remainingTime = (endIdx - currIdx) * timePerStep;
    else
        remainingTime = 0;
        elapsedTime = 0;
        estTotTime = 0;
    end
    
    elapsedTimeDuration = ConvertTimeToString(elapsedTime);
    strRemaining = ConvertTimeToString(remainingTime);
    totTimeStr = ConvertTimeToString(estTotTime);
    
    idxHeader1 = sprintf('%s%s%s', spaces, 'Idx/Total', spaces);
    idxHeader2 = sprintf('%s         %s', spaces, spaces);
    idxHeaderD = sprintf('%s', equals);
    
    complHeader1 = sprintf(' Completed ');
    complHeader2 = sprintf('    (%%)    ');
    complHeaderD = sprintf('===========');
    
    elapsedHeader1 = sprintf('   Time Elapsed    ');
    elapsedHeader2 = sprintf('    (hh:mm:ss.S)   ');
    elapsedHeaderD = sprintf('===================');
    
    remainingHeader1 = sprintf('    Time Remaining   ');
    remainingHeader2 = sprintf('     (hh:mm:ss.S)    ');
    remainingHeaderD = sprintf('=====================');
    
    totalHeader1 = sprintf(' Est. Total Time ');
    totalHeader2 = sprintf('  (hh:mm:ss.S)   ');
    totalHeaderD = sprintf('=================');
    
    header1 = sprintf('        | %s | %s | %s | %s | %s |', idxHeader1, complHeader1, elapsedHeader1, remainingHeader1, totalHeader1);
    header2 = sprintf('        | %s | %s | %s | %s | %s |', idxHeader2, complHeader2, elapsedHeader2, remainingHeader2, totalHeader2);
    headerD = sprintf('        |=%s=|=%s=|=%s=|=%s=|=%s=|', idxHeaderD, complHeaderD, elapsedHeaderD, remainingHeaderD, totalHeaderD);
    
    header = sprintf('\n%s\n%s\n%s\n%s',headerD, header1, header2, headerD);
    
    idxDisplay = sprintf('%*d/%-*d', (digitSpace-1)/2, currIdx, (digitSpace-1)/2, endIdx);
    complDisplay = sprintf('  %5.1f%%   ', propElapsed*100);
    elapsedDisplay = sprintf('Elapsed: %10s', elapsedTimeDuration);
    remainingDisplay = sprintf('Remaining: %10s', strRemaining);
    totalDisplay = sprintf('Total: %10s', totTimeStr);    
    
    display = sprintf('        | %s | %s | %s | %s | %s |', idxDisplay, complDisplay, elapsedDisplay, remainingDisplay, totalDisplay);
    
    
    if showAllOutput == true
         if currIdx == 1
            message = sprintf('\n%s\n%s\n', header, display);
        else
            message = sprintf('%s\n', display);
         end
    else
        message = sprintf('\n%s\n%s\n', header, display);
        
        if currIdx ~= 1
            fprintf(repmat('\b', 1, length(message)))            
        end
    end
    fprintf('%s', message);
    
end

if currIdx == endIdx
    fprintf('        |=%s=|=============|=====================|=======================|===================|\n', equals);
    clear DisplayProgress
end
end

end

function str = ConvertTimeToString(timeInSec)

timeDuration = seconds(timeInSec);
timeDuration.Format = 'hh:mm:ss.S';
timeString = char(timeDuration);

if seconds(timeDuration) < 0.1
    str = '--:--:--.-';
elseif minutes(timeDuration) < 1
    str = timeString(7:end) ;
elseif hours(timeDuration) < 1
    str = timeString(4:end);
else
    str = timeString;
end
end
