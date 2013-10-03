require 'net/http'

module Outliers
  module Handlers
    class JSON
      def post(result)
        host = 'localhost'
        port = '3000'
        path = '/results'

        req = Net::HTTP::Post.new(path, initheader = { 'Content-Type' => 'application/json',
                                                       'Accept'       => 'application/vnd.outliers-v1+json' })
        req.body = result.to_json
        
        response = Net::HTTP.new(host, port).start {|http| http.request(req) }

        logger.debug response.body

        if response
          logger.debug "Handler completed succesfully."
          true
        else
          logger.debug "Handler failed."
          false
        end
      end

      private

      def logger
        @logger ||= Outliers.logger
      end

    end
  end
end
