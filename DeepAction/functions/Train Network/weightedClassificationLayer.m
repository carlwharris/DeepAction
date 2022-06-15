
classdef weightedClassificationLayer < nnet.layer.ClassificationLayer
    
    properties
        % Row vector of weights corresponding to the classes in the
        % training data.
        ClassWeights
    end
    
    methods
        function layer = weightedClassificationLayer(classWeights, name)
            % layer = weightedClassificationLayer(classWeights) creates a
            % weighted cross entropy loss layer. classWeights is a row
            % vector of weights corresponding to the classes in the order
            % that they appear in the training data.
            %
            % layer = weightedClassificationLayer(classWeights, name)
            % additionally specifies the layer name.
            
            % Set class weights.
            layer.ClassWeights = classWeights;
            
            % Set layer name.
            if nargin == 2
                layer.Name = name;
            end
            
            % Set layer description
            layer.Description = 'Weighted cross entropy';
        end
        
        function loss = forwardLoss(layer, Y, T)
            % Find observation and sequence dimensions of Y
            [~, N, S] = size(Y);

            % Reshape ClassWeights to KxNxS
            W = repmat(layer.ClassWeights(:), 1, N, S);

            % Compute the loss
            loss = -sum( W(:).*T(:).*log(Y(:)) )/N;
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % dLdY = backwardLoss(layer, Y, T) returns the derivatives of
            % the weighted cross entropy loss with respect to the
            % predictions Y.
            % Find observation and sequence dimensions of Y
            [~, N, S] = size(Y);

            % Reshape ClassWeights to KxNxS
            W = repmat(layer.ClassWeights(:), 1, N, S);

            % Compute the derivative
            dLdY = -(W.*T./Y)/N;
        end
    end
end

