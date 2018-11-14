RSpec.describe Function do
  before do
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  describe '#execute' do
    before do
      @name = 'name'
    end

    context 'with ENV settings' do
      before do
        allow(ENV).to receive(:[]).with('GATEWAY').and_return('https://gtw:1234')
      end

      it 'sets the uri according to settings' do
        expect(URI).to receive(:parse).with(
          "https://gtw:1234/function/#{@name}"
        )
        Function.new(@name, 0, @logger)
      end
    end

    context 'with no ENV settings' do
      it 'sets the uri according to defaults' do
        expect(URI).to receive(:parse).with(
          "http://gateway:8080/function/#{@name}"
        )
        Function.new(@name, 0, @logger)
      end
    end
  end
end
