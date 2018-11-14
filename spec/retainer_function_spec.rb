RSpec.describe RetainerFunction do
  before do
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  describe '#execute' do
    it 'logs and returns the input data' do
      data = 'some_data'
      expect(@logger).to receive(:info).with(/Orchestrator::RETAIN/)
      expect(@logger).to receive(:debug).with(/#{data}/)
      expect(@logger).to receive(:info).with(Function::SEPARATOR)
      expect(RetainerFunction.new(@logger).execute(data)).to eq data
    end
  end
end
