class FunctionGroup
  def initialize(functions, logger)
    @functions = functions
    @logger = logger
  end

  def execute(data)
    prelog

    responses = @functions.collect do |function|
      Thread.new { function.execute(data) }
    end.map(&:value)


    # TODO: thread for parallelization
    #responses = @functions.collect do |function|
      #function.execute(data)
    #end
    postlog(responses)
    responses
  end

  def prelog
    @logger.info '************* PARALLEL *************'
    function_names = @functions.map(&:function_name).join(', ')
    @logger.info "Executing [#{function_names}] in parallel"
  end

  def postlog(responses)
    @logger.debug "returning #{responses}"
    @logger.info '************* PARALLEL *************'
  end
end
