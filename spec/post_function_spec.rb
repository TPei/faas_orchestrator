RSpec.describe PostFunction do
  before do
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::FATAL
  end

  describe '#execute' do
    before do
      @name = 'name'
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

      f = PostFunction.new(@name, 0, @logger)
      expect(f.execute(@data)).to eq @response
    end

    it 'logs output' do
      f = PostFunction.new(@name, 0, @logger)
      expect(@logger).to receive(:info).with("Calling #{@name} via POST")
      expect(@logger).to receive(:debug).with(
        /^.*?\bhello\b.*?\b#{@response}\b.*?$/m
      )
      expect(@logger).to receive(:info).with(Function::SEPARATOR)

      f.execute('hello')
    end
  end
end
