module Outliers
  module CLI
    class Evaluate
      def evaluate
        @options = { arguments: [], exclude: [], filter: [], credentials: [], target_resources: [] }
        @credentials = {}

        option_parser.parse!

        Outliers.config_path @options[:config]

        @logger = Outliers.logger
        @run    = Run.new

        load_credentials

        @options[:parsed_arguments] = parse_arguments
        @options[:parsed_filters] = parse_filters

        # Make options available global
        # Required to read by instance_eval in @run.evaluate 
        @@options = @options

        begin
          @run.evaluate "Running verification provided via CLI." do
            connect 'cli'
            resources @@options[:resource], @@options[:target_resources]
            exclude @@options[:exclude] if @@options[:exclude].any?
            filter @@options[:parsed_filters] if @@options[:filter].any?
            verify @@options[:verification], @@options[:parsed_arguments]
          end
        rescue Outliers::Exceptions::Base => e
          @logger.error e.message
          exit 1
        end

        exit 1 if @run.results.first.failed?
      end

      def command_name
        'evaluate'
      end

      def command_summary
        'Evaluate the given verification.'
      end

      private

      def load_credentials
        credentials_name = @options[:credential_name]
        credentials = Credentials.load_from_file("#{ENV['HOME']}/.outliers.yml").fetch credentials_name
        credentials.merge! 'provider' => @options[:provider]

        if @options[:credentials].any?
          @options[:credentials].each do |c|
            key = c.split('=').first
            value =  c.split('=').last
            credentials.merge! key => value
          end
        end

        @run.credentials = { 'cli' => credentials }
      end
      
      def parse_filters
        filters = {}

        @options[:filter].each do |a|
          key = a.split('=').first
          value = a.split('=').last
          filters.merge! key => value
        end

        filters
      end

      
      def parse_arguments
        arguments = {}

        @options[:arguments].each do |a|
          key = a.split('=').first
          value = a.split('=').last
          value = value.split(',') if value.include?(',')
          arguments.merge! key => value
        end

        arguments
      end

      def option_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: outliers evaluate [options]"

          opts.on("-a", "--argument [NAME]", "Equals seperated key and value to pass as argument to verification (can be specified multiple times).") do |o|
            @options[:arguments] << o
          end

          opts.on("-c", "--credential_name [CREDENTIAL_NAME]", "Name to load from credentials file.") do |o|
            @options[:credential_name] = o
          end

          opts.on("-e", "--exclude [EXCLUDE]", "Exclude resources in collection with the given key (can be specified multiple times).") do |o|
            @options[:exclude] << o
          end

          opts.on("-f", "--fitler [FILTER]", "Equals seperated filter name and value (can be specified multiple times).") do |o|
            @options[:filter] << o
          end

          opts.on("-p", "--provider [PROVIDER]", "Provider of target resources.") do |o|
            @options[:provider] = o
          end

          opts.on("-r", "--resources [RESOURCES]", "Name of resource collection to evaluate.") do |o|
            @options[:resource] = o
          end

          opts.on("-t", "--target_resources [TARGET_RESOURCES]", "Target resources with key name (can be specified more than once).") do |o|
            @options[:target_resources] << o
          end

          opts.on("-v", "--verification [VERIFICATION]", "Verification to perform against collection of resources.") do |o|
            @options[:verification] = o
          end

          opts.on("--credentials [CREDENTIALS]", "Equals seperated key and value to include as credentials (can be specified multiple times).") do |o|
            @options[:credentials] << o
          end
        end
      end

    end
  end
end
