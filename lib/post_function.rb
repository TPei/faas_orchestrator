class PostFunction < Function
  def execute(data)
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
    else
      handle_error(data)
    end
  end
end
