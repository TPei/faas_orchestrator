RSpec.describe FunctionGroup do
  before do
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  describe '#execute' do
    it 'executes all functions and returns the results' do
      functions = []
      (1..3).each do |n|
        functions << Function.new("some_function_#{n}", '', '', @logger)
      end

      data = 7
      fg = FunctionGroup.new(functions, @logger)
      functions.each do |function|
        expect(function).to receive(:execute).with(data).
          and_return(function.function_name)
      end

      expect(fg.execute(data)).to eq functions.map(&:function_name)
    end
  end
end
