function ProgressBar(currIdx, endIdx, varargin)
p = inputParser;
addOptional(p, 'TotalUpdates', 1000);
parse(p, varargin{:});

persistent ProgressBar

if currIdx == 1 || isempty(ProgressBar)
    ProgressBar = struct;
    ProgressBar.Start = tic;
    ProgressBar.PrevLineLength = 0;
end

if endIdx > p.Results.TotalUpdates
    if p.Results.TotalUpdates <= endIdx
        displayIdxs = round(linspace(1, endIdx, p.Results.TotalUpdates));
    end
else
    displayIdxs = 1:endIdx;
end


if ismember(currIdx, displayIdxs)
    propElapsed = currIdx / endIdx;
    
    idx = find(ismember(displayIdxs, currIdx));
    
    if idx ~= 1
        elapsedTime = toc(ProgressBar.Start);
        
        elapsedTime = seconds(elapsedTime);
        timePerStep = elapsedTime / (currIdx-1);
        estTotTime = timePerStep * endIdx;
        remainingTime = (endIdx - currIdx) * timePerStep;
    else
        timePerStep = seconds(0);
        remainingTime = seconds(0);
        elapsedTime = seconds(0);
        estTotTime = seconds(0);
    end
    
%     elapsedTime.Format = 'mm:ss';
    elapsedTime = FormatTime(elapsedTime);
    estTotTime = FormatTime(estTotTime);
    remainingTime = FormatTime(remainingTime);
%     estTotTime.Format = 'mm:ss';
%     remainingTime.Format = 'mm:ss';
    
    nBarsTotal = 25;
    
    
    if currIdx == 1
        rateTxt = sprintf('');
    else
        if seconds(timePerStep) > 1
            timePerStep = FormatTime(timePerStep);
            rateTxt = sprintf('(%s/iter)', timePerStep);
        else
            if timePerStep ~= 0
                iterPerSec = 1/seconds(timePerStep);
                rateTxt = sprintf('(%0.1f iter/sec)', iterPerSec);
            end
        end
    end
    
    
    nBarsCurr = round(propElapsed * nBarsTotal);
    
    percElapsed = round(propElapsed * 100, 1);
    if percElapsed < 10
        percent = sprintf(' %0.1f%%', percElapsed);
    else
        percent = sprintf('%0.1f%%', percElapsed);
    end
    bar = sprintf('%s%s', repmat('█', nBarsCurr, 1), repmat(' ', nBarsTotal-nBarsCurr, 1));
    idxTxt = sprintf('%d/%d', currIdx, endIdx);
    
    timeTxt = sprintf('%s < %s', elapsedTime, remainingTime);
    finalTxt = sprintf('%s |%s| %s [%s] %s\n', percent, bar, idxTxt, timeTxt, rateTxt);
    
    if currIdx ~= 1
        removeTxt = repmat('\b', 1, ProgressBar.PrevLineLength);
        fprintf(removeTxt);
    end
    
    fprintf('%s', finalTxt)
    ProgressBar.PrevLineLength = length(finalTxt);
end
end

function currDuration = FormatTime(currDuration)
if minutes(currDuration) < 1
    currDuration.Format = 'mm:ss.S';
    return
end

if hours(currDuration) < 1
    currDuration.Format = 'mm:ss';
    return
end

currDuration.Format = 'hh:mm:ss';
end