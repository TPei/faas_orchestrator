RSpec.describe GetFunction do
  before do
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  describe '#execute' do
    before do
      @name = 'name'
      @response = 'hello from function'
      allow(Net::HTTP).to receive(:get_response).and_return(response = double)
      allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return true
      allow(response).to receive(:body).and_return(@response)
    end

    context 'with nil data' do
      it 'does a GET call without data' do
        expect(URI).to receive(:parse).with(/#{@name}/).
          and_return(uri = double)
        expect(Net::HTTP).to receive(:get_response).with(uri)
        f = GetFunction.new(@name, 0, @logger)
        expect(f.execute(nil)).to eq @response
      end
    end

    context 'with string' do
      it 'makes a data hash with string and makes query' do
        expect(URI).to receive(:parse).with(/#{@name}/).
          and_return(uri = double)
        allow(uri).to receive(:query=)
        expect(URI).to receive(:encode_www_form).with({ data: 'hello' }).
          and_call_original
        expect(Net::HTTP).to receive(:get_response).with(uri)
        f = GetFunction.new(@name, 0, @logger)
        expect(f.execute('hello')).to eq @response
      end
    end

    context 'with hash' do
      it 'makes a query from hash' do
        expect(URI).to receive(:parse).with(/#{@name}/).
          and_return(uri = double)
        allow(uri).to receive(:query=)
        expect(URI).to receive(:encode_www_form).with({ test: 'hello' }).
          and_call_original
        expect(Net::HTTP).to receive(:get_response).with(uri)
        f = GetFunction.new(@name, 0, @logger)
        expect(f.execute({ test: 'hello'})).to eq @response
      end
    end

    context 'with incompatible data' do
      it 'continues without darta and logs a warning' do
        expect(URI).to receive(:parse).with(/#{@name}/).
          and_return(uri = double)
        expect(URI).not_to receive(:encode_www_form)
        expect(Net::HTTP).to receive(:get_response).with(uri)
        expect(@logger).to receive(:warn).with(
          /\"#{NoMethodError.new}\" not convertible/
        )
        f = GetFunction.new(@name, 0, @logger)
        expect(f.execute(NoMethodError.new)).to eq @response
      end

      it 'logs output' do
        f = GetFunction.new(@name, 0, @logger)
        expect(@logger).to receive(:info).with("Calling #{@name} via GET")
        expect(@logger).to receive(:debug).with(
          /^.*?\bhello\b.*?\b#{@response}\b.*?$/m
        )
        expect(@logger).to receive(:info).with(Function::SEPARATOR)

        f.execute('hello')
      end
    end
  end
end
