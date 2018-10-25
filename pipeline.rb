require_relative 'function'
require_relative 'modifier'

class Pipeline
  def initialize(sync_type)
    @sync_type = sync_type
    @entries = []
  end

  def then(function_name, http_method = 'get', retrying = false)
    @entries << Function.new(function_name, http_method, retrying)
    self
  end

  def next(function_name)
    self.then(function_name)
  end

  def modify(&block)
    @entries << Modifier.new(block)
    self
  end

  def execute(state)
    # TODO: new thread and return if async
    @entries.each do |entry|
      # TODO: catch FunctionCallError and retry if appropriate
      state = entry.execute(state)
    end
    state
  end
end
