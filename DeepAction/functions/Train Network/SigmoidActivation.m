classdef SigmoidActivation < nnet.layer.Layer
    methods
        function layer = SigmoidActivation(name)
            layer.Name = name;
            layer.Description = 'Sigmoid Activation Layer'; 
        end
        function Z = predict(layer,X)
            Z = sigmoid(X);
        end
    end
 end