RSpec.describe FunctionGroup do
  before do
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  describe '#execute' do
    before do
      @functions = []
      (1..3).each do |n|
        @functions << GetFunction.new("some_function_#{n}", '', @logger)
      end
      @functions.each do |function|
        allow(function).to receive(:execute)
      end
    end

    it 'executes all functions and returns the results' do
      data = 7
      fg = FunctionGroup.new(@functions, @logger)
      @functions.each do |function|
        expect(function).to receive(:execute).with(data).
          and_return(function.function_name)
      end

      expect(fg.execute(data)).to eq @functions.map(&:function_name)
    end

    it 'logs output' do
      fg = FunctionGroup.new(@functions, @logger)
      expect(@logger).to receive(:info).with(FunctionGroup::START_SEPARATOR)
      expect(@logger).to receive(:info).with(
        /#{@functions.map(&:function_name).join(', ')}/
      )
      expect(@logger).to receive(:info).with(FunctionGroup::END_SEPARATOR)

      fg.execute(12)
    end
  end
end
