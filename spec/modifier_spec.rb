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
  end
end
