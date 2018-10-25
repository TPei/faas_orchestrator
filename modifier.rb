class Modifier
  def initialize(le_proc)
    @le_proc = le_proc
  end

  # sync vs async??
  def execute(data)
    # ¯\_(ツ)_/¯
    # execute block with data
    @le_proc.call(data)
  end
end
