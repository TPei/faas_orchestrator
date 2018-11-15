require_relative 'orchestrator'

class Handler
  def run(req)
    # Orchestrator.execute_from_yaml_file('./orchestration.yml')

    Orchestrator.new('sync').
      #with(req).
      first('business-strategy-generator', 'GET').
      modify do |data|
        data.split('.')[1]
      end.
      then(multiple: [['echo', 'POST'], [Orchestrator::RETAIN]]).
      modify do |data|
        data[1]
      end.
      #next('echo', 'post').
      #then('echo', 'post').
      #then('nothing', 'post', 3).
      #then('sentimentanalysis', 'post').
      #execute
      finally(multiple: [['sentimentanalysis'], ['echo']]) # POST is default
  end
end
