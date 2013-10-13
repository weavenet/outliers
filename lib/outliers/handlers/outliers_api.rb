require 'json'
require 'net/http'
require 'uri'

module Outliers
  module Handlers
    class OutliersApi
      def post(result, key, url)
        uri = URI.parse url

        host = uri.host
        port = uri.port
        path = uri.path
        use_ssl = uri.scheme == 'https'

        req = Net::HTTP::Post.new path, header
        
        req.body = body(key, result)

        logger.debug "Hanlder URL: #{url}"
        logger.debug "Posting: #{body("XXX", result)}"

        session = Net::HTTP.new(host, port)
        session.use_ssl = use_ssl

        begin
          response = session.start {|http| http.request(req) }
        rescue Errno::ECONNREFUSED
          logger.error "Connection to '#{url}' refused."
          return false
        end

        if response.code == "200"
          logger.debug "Received: #{response.body}"
          logger.debug "Handler completed succesfully."
          true
        else
          logger.error "Received: #{response.body}"
          logger.error "Handler failed with code #{response.code}."
          false
        end
      end

      private

      def logger
        @logger ||= Outliers.logger
      end

      def header
        { 'Content-Type' => 'application/json',
          'Accept'       => 'application/vnd.outliers-v1+json' }
      end

      def body(key, result)
        { 'key'    => key,
          'result' => result.to_hash }.to_json
      end

    end
  end
end
