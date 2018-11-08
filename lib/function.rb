require 'net/http'
require 'json'

class Function
  attr_accessor :function_name

  def initialize(function_name, http_method, retry_max, logger)
    @function_name = function_name
    @http_method = http_method
    @retry_max = retry_max
    @retry_count = 0
    @logger = logger
  end

  def retrying?
    @retrying
  end

  # sync vs async??
  def execute(data)
    if @http_method == 'get'
      get(data)
    elsif @http_method == 'post'
      post(data)
    end
  end

  def get(data)
    # TODO
    gateway = ENV['GATEWAY'] || ENV['gateway'] || 'gateway'
    port = ENV['GATEWAY_PORT'] || ENV['gateway_port'] || '8080'

    uri = URI.parse("http://#{gateway}:#{port}/function/#{@function_name}")
    uri.query = URI.encode_www_form(data) unless data.nil? || data.empty?

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      @logger.info "#{@function_name} got: \n #{data} \n and returned: \n #{res.body}"
      @logger.info '==================='
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
    gateway = ENV['GATEWAY'] || ENV['gateway'] || 'gateway'
    port = ENV['GATEWAY_PORT'] || ENV['gateway_port'] || '8080'

    uri = URI.parse("http://#{gateway}:#{port}/function/#{@function_name}")
    header = {'Content-Type': 'text/json'}

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data.to_json

    # Send the request
    res = http.request(request)

    if res.is_a?(Net::HTTPSuccess)
      @logger.info "#{@function_name} got: \n #{data} \n and returned: \n #{res.body}"
      @logger.info '==================='
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
end

class FunctionCallError < StandardError; end