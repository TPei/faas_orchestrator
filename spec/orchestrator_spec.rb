RSpec.describe Orchestrator do
  before do
    @pipe = Orchestrator.new
    @name = 'function_name'
    @retry_max = 10
  end

  describe '#then' do
    context 'with single function data' do
      context 'with GET as method' do
        it 'creates a GetFunction instance' do
          expect(GetFunction).to receive(:new).with(
            @name,  @retry_max, instance_of(Logger)
          )
          @pipe.then(@name, 'GET', @retry_max)
        end
      end

      context 'with POST as method' do
        it 'creates a GetFunction instance' do
          expect(PostFunction).to receive(:new).with(
            @name,  @retry_max, instance_of(Logger)
          )
          @pipe.then(@name, 'POST', @retry_max)
        end
      end

      context 'with Orchestrator::RETAIN as function name' do
        it 'creates a RetainerFunction' do
          expect(RetainerFunction).to receive(:new).with(
            instance_of(Logger)
          )
          @pipe.then(Orchestrator::RETAIN)
        end
      end
    end

    context 'with multiple function data' do
      context 'with all data set' do
        it 'creates multiple functions and a function group' do
          data = [
            ['f1', 'GET', 10],
            ['f2', 'POST', 20],
            ['f3', 'GET', 0]
          ]

          expect(GetFunction).to receive(:new).with('f1', 10, instance_of(Logger)).and_call_original
          expect(PostFunction).to receive(:new).with('f2', 20, instance_of(Logger)).and_call_original
          expect(GetFunction).to receive(:new).with('f3', 0, instance_of(Logger)).and_call_original

          expect(FunctionGroup).to receive(:new).with(
            instance_of(Array), instance_of(Logger)
          )
          @pipe.then(multiple: data)
        end
      end

      context 'with some data missing' do
        it 'uses defaults' do
          data = [
            ['f1'],
            ['f2', 'POST'],
            ['f3', 'GET', 10]
          ]

          expect(PostFunction).to receive(:new).with('f1', 0, instance_of(Logger)).and_call_original
          expect(PostFunction).to receive(:new).with('f2', 0, instance_of(Logger)).and_call_original
          expect(GetFunction).to receive(:new).with('f3', 10, instance_of(Logger)).and_call_original

          expect(FunctionGroup).to receive(:new).with(
            instance_of(Array), instance_of(Logger)
          )
          @pipe.then(multiple: data)
        end
      end
    end
  end

  describe '#modify' do
    it 'creates a modifier' do
      expect(Modifier).to receive(:new)

      @pipe.modify do |n|
        n + 3
      end
    end
  end

  describe '#from_yaml' do
    before do
      allow(GetFunction).to receive(:new).with(
        'f1', 0, instance_of(Logger)
      ).and_return(@f1 = double)
      allow(PostFunction).to receive(:new).with(
        'f2', 10, instance_of(Logger)
      ).and_return(@f2 = double)
      allow(GetFunction).to receive(:new).with(
        'f3', 11, instance_of(Logger)
      ).and_return(@f3 = double)
      allow(@f1).to receive(:execute).and_return 'hello from f1'
      allow(FunctionGroup).to receive(:new).and_return(@fg = double)
      allow(@fg).to receive(:execute).and_return 'hello from fg'

      @data = { some: 'data' }

      @pipe.with(@data)
      @pipe.from_yaml('spec/files/orchestration.yml')
    end

    it 'executes all previously added executables' do
      expect(@f1).to receive(:execute).with(@data)
      expect(@fg).to receive(:execute).with('hello from f1')
      @pipe.execute
    end

    it 'returns the result' do
      expect(@pipe.execute).to eq 'hello from fg'
    end
  end

  describe '#finally' do
    it 'calls then and execute' do
      expect(@pipe).to receive(:then).with(
        'f1', 'POST', 0, multiple: []
      )
      expect(@pipe).to receive(:execute)
      @pipe.finally('f1', 'POST', 0, multiple: [])
    end
  end

  describe '#execute' do
    context 'with added data' do
      before do
        allow(Function).to receive(:new).with(
          'f1', 0, instance_of(Logger)
        ).and_return(@f1 = double)
        allow(Function).to receive(:new).with(
          'f2', 0, instance_of(Logger)
        ).and_return(@f2 = double)
        allow(Function).to receive(:new).with(
          'f3', 0, instance_of(Logger)
        ).and_return(@f3 = double)
        allow(@f1).to receive(:execute).and_return 'hello from f1'
        allow(FunctionGroup).to receive(:new).and_return(@fg = double)
        allow(@fg).to receive(:execute).and_return 'hello from fg'
        allow(Modifier).to receive(:new).and_return(@mod = double)
        allow(@mod).to receive(:execute).and_return 'hello from modifier'

        @data = { some: 'data' }

        @pipe.with(@data)
        @pipe.then('f1')
        @pipe.then(multiple: [['f2'], ['f3']])
        @pipe.modify do
        end
      end

      it 'executes all previously added executables' do
        expect(@f1).to receive(:execute).with(@data)
        expect(@fg).to receive(:execute).with('hello from f1')
        expect(@mod).to receive(:execute).with('hello from fg')
        @pipe.execute
      end

      it 'returns the result' do
        expect(@pipe.execute).to eq 'hello from modifier'
      end
    end
  end
end
