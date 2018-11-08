class FunctionGroup
  START_SEPARATOR = '************* PARALLEL START *************'
  END_SEPARATOR = '*************  PARALLEL END  *************'

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
    @logger.info START_SEPARATOR
    function_names = @functions.map(&:function_name).join(', ')
    @logger.info "Executing [#{function_names}] in parallel"
  end

  def postlog(responses)
    @logger.debug "returning #{responses}"
    @logger.info END_SEPARATOR
  end
end
