require 'net/http'
require 'json'

class Function
  def initialize(function_name, http_method, retrying)
    @function_name = function_name
    @http_method = http_method
    @retrying = false
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
    gateway = ENV['GATEWAY'] || 'gateway'

    uri = URI.parse("http://#{gateway}:8080/function/#{@function_name}")
    uri.query = URI.encode_www_form(data) unless data.nil? || data.empty?

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      puts "#{@function_name} got: \n #{data} \n and returned: \n #{res.body}"
      puts '==================='
      return res.body
    else
      throw FunctionCallError, 'function call failed'
    end
  end

  def post(data)
    gateway = ENV['GATEWAY'] || 'gateway'

    uri = URI.parse("http://#{gateway}:8080/function/#{@function_name}")
    header = {'Content-Type': 'text/json'}

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = data.to_json

    # Send the request
    res = http.request(request)

    if res.is_a?(Net::HTTPSuccess)
      puts "#{@function_name} got: \n #{data} \n and returned: \n #{res.body}"
      puts '==================='
      return res.body
    else
      throw FunctionCallError, 'function call failed'
    end
  end
end

class FunctionCallError < StandardError; end
