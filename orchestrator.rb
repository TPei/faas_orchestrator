require_relative 'function'
require_relative 'function_group'
require_relative 'modifier'

class Orchestrator
  def initialize(sync_type, data = nil)
    @data = data
    @sync_type = sync_type
    @entries = []
  end

  def with(data)
    @data = data
    self
  end

  def then(function_name = '', http_method = 'get', retry_max = 0, multiple: [])
    if multiple.empty?
      @entries << Function.new(function_name, http_method, retry_max)
    else
      functions = multiple.collect do |function|
        Function.new(
          function.fetch(0),
          function.fetch(1, 'get'),
          function.fetch(2, 0)
        )
      end
      @entries << FunctionGroup.new(functions)
    end

    self
  end

  alias next then
  alias first then # TODO: check if entries empty

  def modify(&block)
    @entries << Modifier.new(block)
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

  def finally(function_name, http_method = 'get', retry_max = false)
    self.then(function_name, http_method, retry_max)
    execute
  end
end
