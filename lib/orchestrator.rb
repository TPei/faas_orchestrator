require 'logger'
require_relative 'function'
require_relative 'function_group'
require_relative 'modifier'

class Orchestrator
  RETAIN = 'Orchestrator::RETAIN'

  def initialize(sync_type, data = nil)
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

  def then(function_name = '', http_method = 'POST', retry_max = 0, multiple: [])
    if multiple.empty?
      @entries << Function.new(function_name, http_method.upcase, retry_max, @logger)
    else
      functions = multiple.collect do |function|
        Function.new(
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
      # TODO: catch FunctionCallError and retry if appropriate
      state = entry.execute(state)
    end
    state
  end

  def finally(function_name = '', http_method = 'POST', retry_max = 0, multiple:)
    self.then(function_name, http_method, retry_max, multiple: multiple)
    execute
  end
end
