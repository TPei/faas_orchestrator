require_relative 'orchestrator'

class Handler
  def run(req)
    Orchestrator.new('sync').
      #with(req).
      first('business-strategy-generator', 'get').
      modify do |data|
        data.split('.')[1]
      end.
      then(multiple: [['echo', 'post'], ['echo', 'post'], [Orchestrator::RETAIN]]).
      modify do |data|
        data[0]
      end.
      #next('echo', 'post').
      #then('echo', 'post').
      #then('nothing', 'post', 3).
      #then('sentimentanalysis', 'post').
      #execute
      finally('sentimentanalysis', 'post')
  end
end
