RSpec.describe Modifier do
  before do
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  describe '#execute' do
    it 'executes a block and returns the result' do
      le_proc = Proc.new { |n| n + 7 }

      modifier = Modifier.new(le_proc, @logger)
      expect(modifier.execute(3)).to eq 10
    end

    it 'logs output' do
      le_proc = Proc.new { |name| "hello #{name}" }

      modifier = Modifier.new(le_proc, @logger)

      expect(@logger).to receive(:info).with('Applying modification')
      expect(@logger).to receive(:debug).with(
        /^.*?\bfellow human\b.*?\bhello fellow human\b.*?$/m
      )
      expect(@logger).to receive(:info).with(Modifier::SEPARATOR)

      modifier.execute('fellow human')
    end
  end
end
