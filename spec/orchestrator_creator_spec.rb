RSpec.describe OrchestratorCreator do
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
  end

  describe '.from_yaml' do
    it 'creates an Orchestrator and sets functions' do
      yaml = File.read('spec/files/orchestration.yml')

      allow(Orchestrator).to receive(:new).and_return(pipe = double)
      allow(pipe).to receive(:logger).and_return(Logger.new(STDOUT))
      expect(pipe).to receive(:entries=).with(instance_of(Array))
      OrchestratorCreator.from_yaml(yaml)
    end

    # integration spec
    it 'creates an Orchestrator with functions set' do
      yaml = File.read('spec/files/orchestration.yml')

      expect(@f1).to receive(:execute).with(nil)
      expect(@fg).to receive(:execute).with('hello from f1')
      pipe = OrchestratorCreator.from_yaml(yaml)
      expect(pipe.class).to eq Orchestrator
      expect(pipe.execute).to eq 'hello from fg'
    end
  end

  describe '.from_yaml_file' do
    it 'creates an Orchestrator and sets functions' do
      allow(Orchestrator).to receive(:new).and_return(pipe = double)
      allow(pipe).to receive(:logger).and_return(Logger.new(STDOUT))
      expect(pipe).to receive(:entries=).with(instance_of(Array))
      OrchestratorCreator.from_yaml_file('spec/files/orchestration.yml')
    end

    # integration spec
    it 'creates an Orchestrator with functions set' do
      expect(@f1).to receive(:execute).with(nil)
      expect(@fg).to receive(:execute).with('hello from f1')
      pipe = OrchestratorCreator.from_yaml_file('spec/files/orchestration.yml')
      expect(pipe.class).to eq Orchestrator
      expect(pipe.execute).to eq 'hello from fg'
    end
  end
end
