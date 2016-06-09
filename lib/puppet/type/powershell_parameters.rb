module PuppetX
    module Powershell
        def self.check_parameter(name, value)
            if value.is_a?(Array)
                value.each_with_index do |v, index|
                    check_parameter(name, v)
                end
            elsif value.is_a?(Hash)
                value.each do |key, v|
                    check_parameter(key, v)
                end
            elsif !value.respond_to?("to_s")
                raise ArgumentError, "A value for the parameter '#{name}' cannot be converted to a Powershell parameter"
            end        
        end
    end
end

Puppet::Type.newtype(:powershell_parameters) do
    desc "A set of parameters for a Powershell script"
       
    newparam(:script, :namevar => true) do
        desc "The name of the Powershell Exec resource the parameters are for"    
    end

    newparam(:parameters) do
        desc "The parameters to be passed to the 'command' being run by the Powershell Exec"

        validate do |value|
            raise ArgumentError, "'parameters' must be a hash." if !value.is_a?(Hash)
            PuppetX::Powershell.check_parameter("All Parameters", value)
        end
    end

    newparam(:condition_parameters) do
        desc "The parameters to be passed to the 'onlyif' or 'unless' condition being run by the Powershell Exec"

        defaultto {}

        validate do |value|
            raise ArgumentError, "'condition_parameters' must be a hash." if !value.is_a?(Hash)
            PuppetX::Powershell.check_parameter("Condition Parameters", value)
        end
    end
end