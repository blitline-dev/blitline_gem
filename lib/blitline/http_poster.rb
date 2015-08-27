class Blitline
  require 'net/http'
  require 'uri'

  class HttpPoster
    # Perform a POST request.
    # Optionally takes a form_data hash.
    # Optionally takes a block to receive chunks of the response.
    def self.post(path, form_data=nil, &block)
      uri = URI.parse(path) unless path.is_a?(URI)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true if uri.port == 443
      request = Net::HTTP::Post.new(path)
      request.set_form_data(form_data) if form_data
      @http.request(request) do |response|
        if response.is_a? Net::HTTPSuccess
          return response.read_body(&block)
        else
          result_data = response.read_body(&block)
          raise "Post to Blitline.com failed. #{response.code}: #{result_data}"
        end
      end
    end
  end
end