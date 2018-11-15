require 'yaml'

class OrchestratorCreator
  def self.from_yaml_file(filename)
    make_from_yaml(YAML.load_file(filename))
  end

  def self.from_yaml(yaml)
    make_from_yaml(YAML.load(yaml))
  end

  private

  def self.make_from_yaml(pipeline)
    orchestrator = Orchestrator.new
    @logger = orchestrator.logger
    orchestrator.entries = make_policy(pipeline['steps'])
    orchestrator
  end

  def self.make_policy(steps)
    functions = []

    steps.each do |step|
      if step.is_a? String
        functions << make_function(step, 'POST', 0, @logger)
      elsif step.is_a? Hash
        if step['multiple'].nil?
          if step.keys.count > 1
            throw MalformedOrchestrationError,
              'Malformed orchestration yaml, \"multiple\" shouldn\'t have siblings.'
          end
          name = step.keys.first
          values = step.values.first
          values = values.reduce({}, :merge)
          method = values['method'] || 'POST'
          retries = values['retries'] || 0
          functions << make_function(name, method, retries, @logger)
        else
          functions << FunctionGroup.new(make_policy(step['multiple']), @logger)
        end
      end
    end
    return functions
  rescue
    throw MalformedOrchestrationError, 'error parsing yaml file'
  end

  def self.make_function(function_name, http_method, retry_max, logger)
    if(function_name == Orchestrator::RETAIN)
      return RetainerFunction.new(logger)
    end

    case http_method
    when 'get', 'GET'
      GetFunction.new(function_name, retry_max, logger)
    when 'post', 'POST'
      PostFunction.new(function_name, retry_max, logger)
    end
  end

end
