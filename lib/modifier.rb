class Modifier
  SEPARATOR = '=========================================='

  def initialize(le_proc, logger)
    @le_proc = le_proc
    @logger = logger
  end

  # sync vs async??
  def execute(data)
    # ¯\_(ツ)_/¯
    # execute block with data
    @logger.info 'Applying modification'
    result = @le_proc.call(data)
    @logger.debug "got: \n #{data} \n and returned: \n #{result}"
    @logger.info SEPARATOR
    result
  end
end
