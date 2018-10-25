require_relative 'function'
require_relative 'modifier'

class Pipeline
  def initialize(sync_type, data = nil)
    @data = data
    @sync_type = sync_type
    @entries = []
  end

  def with(data)
    @data = data
    self
  end

  def then(function_name, http_method = 'get', retrying = false)
    @entries << Function.new(function_name, http_method, retrying)
    self
  end

  alias next then

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
end
