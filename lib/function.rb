require 'net/http'
require 'json'

class Function
  SEPARATOR = '=========================================='
  attr_accessor :function_name

  def initialize(function_name, retry_max, logger)
    @function_name = function_name
    @retry_max = retry_max
    @retry_count = 0
    @logger = logger

    gateway = ENV['GATEWAY'] || ENV['gateway'] || 'http://gateway:8080'
    @uri = URI.parse("#{gateway}/function/#{@function_name}")
  end

  def log_results(data, response, method)
    @logger.info "Calling #{@function_name} via #{method}"
    @logger.debug "got: \n #{data} \n and returned: \n #{response.body}"
    @logger.info SEPARATOR
  end

  def handle_error(data)
    method = self.class == GetFunction ? 'GET' : 'POST'

    if @retry_count < @retry_max
      @retry_count += 1
      @logger.warn "Calling #{function_name} via #{method} failed, retrying: #{@retry_count}/#{@retry_max}"
      execute(data)
    else
      @logger.error("Calling #{function_name} via #{method} failed")
      raise FunctionCallError, "Calling #{function_name} via #{method} failed"
    end

  end
end

class FunctionCallError < StandardError; end
