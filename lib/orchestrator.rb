require 'logger'
require 'yaml'
require_relative 'function'
require_relative 'get_function'
require_relative 'post_function'
require_relative 'retainer_function'
require_relative 'function_group'
require_relative 'modifier'

class Orchestrator
  RETAIN = 'Orchestrator::RETAIN'

  def initialize(sync_type = 'sync', data = nil)
    @data = data
    @sync_type = sync_type
    @entries = []
    @logger = Logger.new(STDOUT)
    log_level = (ENV['LOG_LEVEL'] || ENV['log_level'] || 'ERROR').upcase
    @logger.level = case log_level
    when "UNKNOWN"
      Logger::UNKNOWN
    when "DEBUG"
      Logger::DEBUG
    when "INFO"
      Logger::INFO
    when "WARN"
      Logger::WARN
    when "ERROR"
      Logger::ERROR
    when "FATAL"
      Logger::FATAL
    end
  end

  def with(data)
    @data = data
    self
  end

  def from_yaml(filename)
    pipeline = YAML.load_file(filename)
    @entries += make_policy(pipeline['steps'])
  end

	def make_policy(steps)
    functions = []

		steps.each do |step|
			if step.is_a? String
        functions << make_function(step, 'POST', 0, @logger)
			elsif step.is_a? Hash
				if step['multiple'].nil?
          if step.keys.count > 1
            throw MalformedOrchestrationError, 'Malformed orchestration yaml, \"multiple\" shouldn\'t have siblings.'
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

  def then(function_name = '', http_method = 'POST', retry_max = 0, multiple: [])
    if multiple.empty?
      @entries << make_function(function_name, http_method.upcase, retry_max, @logger)
    else
      functions = multiple.collect do |function|
        make_function(
          function.fetch(0),
          function.fetch(1, 'POST').upcase,
          function.fetch(2, 0),
          @logger
        )
      end
      @entries << FunctionGroup.new(functions, @logger)
    end

    self
  end

  alias next then
  alias first then # TODO: check if entries empty

  def modify(&block)
    @entries << Modifier.new(block, @logger)
    self
  end

  def execute
    # TODO: new thread and return if async
    state = @data
    @entries.each do |entry|
      state = entry.execute(state)
    end
    state
  end

  def finally(function_name = '', http_method = 'POST', retry_max = 0, multiple: [])
    self.then(function_name, http_method, retry_max, multiple: multiple)
    execute
  end

  def make_function(function_name, http_method, retry_max, logger)
    if(function_name == RETAIN)
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

class MalformedOrchestrationError < StandardError; end
