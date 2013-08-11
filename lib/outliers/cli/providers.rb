module Outliers
  module CLI
    class Providers
      def providers
        option_parser.parse!
        list = Outliers::Providers.name_map
        list.each_pair do |k,v|
          puts k
          v.credential_arguments.each_pair { |k,v| puts "  #{k}: #{v}" }
        end
      end

      def command_name
        'providers'
      end

      def command_summary
        'List available providers.'
      end

      def option_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: outliers providers"
        end
      end

    end
  end
end
