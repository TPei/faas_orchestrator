require 'net/http'
require 'json'

class Function
  SEPARATOR = '=========================================='
  attr_accessor :function_name

  def initialize(function_name, http_method, retry_max, logger)
    @function_name = function_name
    @http_method = http_method
    @retry_max = retry_max
    @retry_count = 0
    @logger = logger

    gateway = ENV['GATEWAY'] || ENV['gateway'] || 'http://gateway:8080'
    @uri = URI.parse("#{gateway}/function/#{@function_name}")
  end

  def retrying?
    @retrying
  end

  # sync vs async??
  def execute(data)
    if @function_name == Orchestrator::RETAIN
      return retain(data)
    end

    if @http_method == 'GET'
      get(data)
    elsif @http_method == 'POST'
      post(data)
    end
  end

  def retain(data)
    log_retain(data)
    return data
  end

  def get(data)
    # TODO
    begin
      if data.is_a?(String)
        @uri.query = URI.encode_www_form({ data: data })
      elsif !data.nil? && !data.empty?
        @uri.query = URI.encode_www_form(data)
      end
    rescue NoMethodError
      @logger.warn("\"#{data}\" not convertible to GET parameters, doing request without data")
      data = nil
    end

    res = Net::HTTP.get_response(@uri)
    if res.is_a?(Net::HTTPSuccess)
      log_results(data, res, 'GET')
      return res.body
    elsif @retry_count < @retry_max
      @retry_count += 1
      @logger.info "function call failed, retrying: #{@retry_count}/#{@retry_max}"
      execute(data)
    else
      throw FunctionCallError, 'function call failed'
    end
  end

  def post(data)
    header = {'Content-Type': 'text/json'}

    # Create the HTTP objects
    http = Net::HTTP.new(@uri.host, @uri.port)
    request = Net::HTTP::Post.new(@uri.request_uri, header)
    request.body = data.to_json

    # Send the request
    res = http.request(request)

    if res.is_a?(Net::HTTPSuccess)
      log_results(data, res, 'POST')
      return res.body
    elsif @retry_count < @retry_max
      @retry_count += 1
      @logger.warn "function call failed, retrying: #{@retry_count}/#{@retry_max}"
      execute(data)
    else
      @logger.error('function call failed')
      throw FunctionCallError, 'function call failed'
    end
  end

  def log_retain(data)
    @logger.info "Using Orchestrator::RETAIN"
    @logger.debug "with: \n #{data}"
    @logger.info SEPARATOR
  end

  def log_results(data, response, method)
    @logger.info "Calling #{@function_name} via #{method}"
    @logger.debug "got: \n #{data} \n and returned: \n #{response.body}"
    @logger.info SEPARATOR
  end
end

class FunctionCallError < StandardError; end
