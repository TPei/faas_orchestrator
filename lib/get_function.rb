class GetFunction < Function
  def execute(data)
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
    else
      handle_error(data)
    end
  end
end
