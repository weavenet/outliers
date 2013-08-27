module Outliers
  module CLI
    class Process
      def process
        @options = {}

        option_parser.parse!

        Outliers.config_path @options[:directory]

        @logger = Outliers.logger
        @run    = Run.new concurrent: @options[:concurrent]

        begin
          @run.credentials = Credentials.load_from_file "#{ENV['HOME']}/.outliers.yml"
          @run.process_evaluations_in_dir
        rescue Outliers::Exceptions::Base => e
          @logger.error e.message
          exit 1
        end

        passed = @run.passed.count
        failed = @run.failed.count

        @logger.info "Evaluations completed."

        @run.failed.each do |f|
          @logger.info "Evaluation '#{f.evaluation}' verification '#{f.verification}' of '#{f.resource}' failed."
          @logger.debug "Failing resource IDs '#{f.failing_resources.map{|r| r.id}.join(', ')}'"
        end

        @logger.info "(#{failed} evaluations failed, #{passed} evaluations passed.)"

        exit 1 unless failed.zero?
      end

      def command_name
        'process'
      end

      def command_summary
        'Process evaluations in config folder.'
      end

      private

      def option_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: outliers process [options]"

          opts.on("-c", "--concurrent [CONCURRENT]", "Maximum number of evaluations to run concurrently.") do |o|
            @options[:concurrent] = o.to_i
          end

          opts.on("-d", "--directory [DIRECTORY]", "Directory containing evaluations to load.") do |o|
            @options[:directory] = o
          end
        end
      end

    end
  end
end
