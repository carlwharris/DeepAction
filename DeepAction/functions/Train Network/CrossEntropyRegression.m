classdef CrossEntropyRegression < nnet.layer.RegressionLayer    
    properties
        % Vector of weights corresponding to the classes in the training
        % data
        ClassWeights
    end
    
    methods
        
        function layer = CrossEntropyRegression(name, classWeights)
            layer.Name = name;
            layer.Description = 'Cross Entropy with Non-Exclusive Classes';
            layer.ClassWeights = classWeights;
        end
        
        function loss = forwardLoss(layer, Y, T)
            nBatches = size(Y,2);
            
            w = layer.ClassWeights;
            
            loss = 0;
            for i = 1:nBatches
                currMiniBatchY = squeeze(Y(:,i,:));
                currMiniBatchT = squeeze(T(:,i,:));
                
                repeated = repmat(w, 1, size(currMiniBatchY,2));
                
                currMiniBatchLoss = -sum(repeated .* (currMiniBatchT .* log(currMiniBatchY))) ...
                    - sum(repeated .* ((1-currMiniBatchT) .* log(1-currMiniBatchY)));
                currMiniBatchLoss = sum(currMiniBatchLoss) / numel(currMiniBatchY);
                
                loss = loss + currMiniBatchLoss;
            end
            loss = loss / nBatches;
        end
    end
end
