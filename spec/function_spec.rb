RSpec.describe FunctionGroup do
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
        allow(ENV).to receive(:[]).with('GATEWAY').and_return('gtw')
        allow(ENV).to receive(:[]).with('GATEWAY_PORT').and_return('1234')
        allow(ENV).to receive(:[]).with('PROTOCOL').and_return('https')
      end

      it 'sets the uri according to settings' do
        expect(URI).to receive(:parse).with(
          "https://gtw:1234/function/#{@name}"
        )
        Function.new(@name, 'get', 0, @logger).execute(nil)
      end
    end

    context 'with no ENV settings' do
      it 'sets the uri according to defaults' do
        expect(URI).to receive(:parse).with(
          "http://gateway:8080/function/#{@name}"
        )
        Function.new(@name, 'get', 0, @logger).execute(nil)
      end
    end

    context 'with http_method GET' do
      before do
        @method = 'GET'
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
          f = Function.new(@name, @method, 0, @logger)
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
          f = Function.new(@name, @method, 0, @logger)
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
          f = Function.new(@name, @method, 0, @logger)
          expect(f.execute({ test: 'hello'})).to eq @response
        end
      end

      it 'logs output' do
        f = Function.new(@name, @method, 0, @logger)
        expect(@logger).to receive(:info).with("Calling #{@name} via #{@method}")
        expect(@logger).to receive(:debug).with(
          /^.*?\bhello\b.*?\b#{@response}\b.*?$/m
        )
        expect(@logger).to receive(:info).with(Function::SEPARATOR)

        f.execute('hello')
      end
    end

    context 'with http_method POST' do
      before do
        @method = 'POST'
        @response = 'hello from function'
        allow(Net::HTTP).to receive(:new).and_return(http = double)
        allow(http).to receive(:request).and_return response = double
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return true
        allow(response).to receive(:body).and_return(@response)

        @header = {'Content-Type': 'text/json'}
        @data = { some: 'request' }
      end

      it 'makes a POST request' do
        expect(URI).to receive(:parse).with(/#{@name}/).
          and_return(uri = double)
        allow(uri).to receive(:host).and_return('some_url')
        allow(uri).to receive(:port).and_return('8080')
        allow(uri).to receive(:request_uri).and_return 'something'
        expect(Net::HTTP::Post).to receive(:new).with('something', @header).
          and_return(request = double)
        expect(request).to receive(:body=).with(@data.to_json)

        f = Function.new(@name, @method, 0, @logger)
        expect(f.execute(@data)).to eq @response
      end

      it 'logs output' do
        f = Function.new(@name, @method, 0, @logger)
        expect(@logger).to receive(:info).with("Calling #{@name} via #{@method}")
        expect(@logger).to receive(:debug).with(
          /^.*?\bhello\b.*?\b#{@response}\b.*?$/m
        )
        expect(@logger).to receive(:info).with(Function::SEPARATOR)

        f.execute('hello')
      end
    end
  end
end
