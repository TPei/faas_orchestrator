class Modifier
  def initialize(le_proc)
    @le_proc = le_proc
  end

  # sync vs async??
  def execute(data)
    # ¯\_(ツ)_/¯
    # execute block with data
    puts 'Applying modification'
    puts '==================='
    @le_proc.call(data)
  end
end
