class Modifier
  def initialize(le_proc, logger)
    @le_proc = le_proc
    @logger = logger
  end

  # sync vs async??
  def execute(data)
    # ¯\_(ツ)_/¯
    # execute block with data
    @logger.info 'Applying modification'
    @logger.info  '==================='
    @le_proc.call(data)
  end
end
