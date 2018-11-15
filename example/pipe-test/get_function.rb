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
    elsif @retry_count < @retry_max
      @retry_count += 1
      @logger.info "Calling #{function_name} via GET failed, retrying: #{@retry_count}/#{@retry_max}"
      execute(data)
    else
      throw FunctionCallError, "Calling #{function_name} via GET failed"
    end
  end
end
