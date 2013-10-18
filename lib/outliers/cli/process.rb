module Outliers
  module CLI
    class Process
      def process
        @options = { threads: 1, log_level: 'info' }

        option_parser.parse!

        Outliers.config_path @options[:directory]

        @logger = Outliers.logger
        @run    = Run.new

        if @options[:threads] > 1
          @run.threaded     = true
          @run.thread_count = @options[:threads]
        end

        log_level = @options.fetch(:log_level).upcase

        unless ["DEBUG", "INFO", "WARN", "ERROR"].include? log_level
          @logger.error "Invalid log level. Valid levels are debug, info, warn, error."
          exit 1
        end

        @logger.level = Logger.const_get log_level

        begin
          @run.account = Account.load_from_file "#{ENV['HOME']}/.outliers.yml"
          @run.process_evaluations_in_dir
        rescue Outliers::Exceptions::Base => e
          @logger.error e.message
          exit 1
        end

        passing_count = @run.results.select {|r| r.passed? }.count
        failing_count = @run.results.select {|r| r.failed? }.count

        @logger.info "Evaluations completed."

        if key
          @logger.info "Running report handlers."
          @run.results.each do |result|
            unless Outliers::Handlers::OutliersApi.new.post result, key, results_url
              @logger.error "Report handler failed."
              exit 1
            end
          end
          @logger.info "Report handlers completed."
        else
          @logger.info "OUTLIERS_KEY not set, not sending results."
        end

        failed_results = @run.results.select {|r| r.failed? }

        failed_results.each do |r|
          if r.name
            @logger.info "Results of '#{r.name}', verifying '#{r.verification_name}' of '#{r.provider_name}:#{r.resource_name}' via '#{r.account_name}' failed."
          else
            @logger.info "Verification '#{r.verification_name}' of '#{r.provider_name}:#{r.resource_name}' via '#{r.account_name}' failed."
          end
        end

        @logger.info "(#{failing_count} evaluations failed, #{passing_count} evaluations passed.)"

        exit 1 unless failing_count.zero?
      end

      def command_name
        'process'
      end

      def command_summary
        'Process evaluations in config folder.'
      end

      private

      def key
        ENV['OUTLIERS_KEY']
      end

      def url
        ENV['OUTLIERS_URL'] ||= 'https://api.getoutliers.com'
      end

      def results_url
        "#{url}/results"
      end

      def option_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: outliers process [options]"

          opts.on("-d", "--directory [DIRECTORY]", "Directory containing evaluations to load.") do |o|
            @options[:directory] = o
          end

          opts.on("-l", "--log_level [LOG_LEVEL]", "Log level (Default: info).") do |o|
            @options[:log_level] = o
          end

          opts.on("-t", "--threads [THREADS]", "Maximum number of evaluations threads to run concurrently (Default: 1).") do |o|
            @options[:threads] = o.to_i
          end
        end
      end

    end
  end
end
