module Outliers
  module CLI
    class Resources
      def resources
        @options = {}

        option_parser.parse!

        provider = @options[:provider]

        @logger = Outliers.logger

        unless provider
          @logger.error "Required parameter 'provider' not specified."
          exit 1
        end

        all = Outliers::Resources.collections

        list = all.select { |r| r.to_human =~ /^#{provider}_.*$/ }

        if list.any?
          list.each do |r|
            name = r.to_human
            name.slice! provider
            name[0] = ''
            puts name
            r.verifications.each { |v| puts "  #{v[:name]}(#{v[:args]}) #{v[:description]}" }
          end
        else
          puts "No resources found for '#{provider}'."
        end
      end

      def command_name
        'resources'
      end

      def command_summary
        'List available resources for a provider.'
      end

      private

      def option_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: outliers resources [options]"

          opts.on("-p", "--provider [PROVIDER]", "Provider to list resources.") do |o|
            @options[:provider] = o
          end
        end
      end

    end
  end
end
