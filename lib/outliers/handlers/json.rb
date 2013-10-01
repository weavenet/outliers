require 'net/http'

module Outliers
  module Handlers
    class JSON
      def post(result)
        payload = result.to_json
        host = 'localhost'
        port = '80'
        path = '/input'
        req = Net::HTTP::Post.new(path, initheader = {'Content-Type' =>'application/json'})
        req.body = payload
        logger.info "Posting results to #{host}#{path}."
        response = Net::HTTP.new(host, port).start {|http| http.request(req) }
        if response
          logger.info "Successfully."
        else
          logger.error "Failed."
        end
        puts response.body
      end

      private

      def logger
        @logger ||= Outliers.logger
      end

    end
  end
end
