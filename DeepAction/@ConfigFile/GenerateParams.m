function self = GenerateParams(self)
    if self.WriteToFile == false
        return
    end
    
    configFileParams = ParseConfigFile(self);
    
    self.Params = configFileParams;
end
