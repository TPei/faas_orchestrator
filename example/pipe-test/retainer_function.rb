class RetainerFunction < Function
  def initialize(logger)
    @logger = logger
    @function_name = Orchestrator::RETAIN
  end

  def execute(data)
    @logger.info "Using Orchestrator::RETAIN"
    @logger.debug "with: \n #{data}"
    @logger.info SEPARATOR
    data
  end
end
