require "github_api"

module Outliers
  module Providers
    class Github < Provider

      def settings(args)
        @token = args[:token]
      end

      def connect
        c = ::Github.new 
        c.oauth_token = @token if @token
        c
      end

      def self.credential_arguments
        { 'token' => 'Github API token.' }
      end

    end
  end
end
