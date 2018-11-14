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
end

class FunctionCallError < StandardError; end
