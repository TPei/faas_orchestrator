class FunctionGroup
  def initialize(functions)
    @functions = functions
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
    puts '************* PARALLEL *************'
    function_names = @functions.map(&:function_name).join(', ')
    puts "Executing [#{function_names}] in parallel"
  end

  def postlog(responses)
    puts "returning #{responses}"
    puts '************* PARALLEL *************'
  end
end
