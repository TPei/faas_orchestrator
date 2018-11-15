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

  describe '#handle_error' do
    before do
      allow_any_instance_of(GetFunction).to receive(:execute).and_return(response = double)
      allow_any_instance_of(PostFunction).to receive(:execute).and_return(response = double)
    end

    context 'when a PostFunction' do
      context 'when max retries not yet reached' do
        it 'retries' do
          f = PostFunction.new(@name, 3, @logger)
          expect(f).to receive(:execute)
          f.handle_error(nil)
        end
      end

      context 'when max retries have been reached reached' do
        it 'fails' do
          f = PostFunction.new(@name, 0, @logger)
          expect { f.handle_error(nil) }.to raise_error(FunctionCallError, /#{@name} POST/)
        end
      end
    end

    context 'when a GetFunction' do
      context 'when max retries not yet reached' do
        it 'retries' do
          f = GetFunction.new(@name, 3, @logger)
          expect(f).to receive(:execute)
          f.handle_error(nil)
        end
      end

      context 'when max retries have been reached reached' do
        it 'fails' do
          f = GetFunction.new(@name, 0, @logger)
          expect { f.handle_error(nil) }.to raise_error(FunctionCallError, /#{@name} GET/)
        end
      end
    end
  end
end
