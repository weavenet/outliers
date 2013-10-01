module Outliers
  module CLI
    class Process
      def process
        @options = { threads: 1 }

        option_parser.parse!

        Outliers.config_path @options[:directory]

        @logger = Outliers.logger
        @run    = Run.new

        if @options[:threads] > 1
          @run.threaded     = true
          @run.thread_count = @options[:threads]
        end

        begin
          @run.credentials = Credentials.load_from_file "#{ENV['HOME']}/.outliers.yml"
          @run.process_evaluations_in_dir
        rescue Outliers::Exceptions::Base => e
          @logger.error e.message
          exit 1
        end

        passing_count = @run.passing_results.count
        failing_count = @run.failing_results.count

        @logger.info "Evaluations completed."

        @run.failing_results.each do |r|
          if r.name
            @logger.info "Results of '#{r.name}', verifying '#{r.verification}' of '#{r.resource_name}' failed."
          else
            @logger.info "Verification '#{r.verification}' of '#{r.resource_name}' failed."
          end
          @logger.info "Failing resource IDs '#{r.failing_resources.map{|r| r.id}.join(', ')}'"
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

      def option_parser
        OptionParser.new do |opts|
          opts.banner = "Usage: outliers process [options]"

          opts.on("-t", "--threads [THREADS]", "Maximum number of evaluations threads to run concurrently (Default: 1).") do |o|
            @options[:threads] = o.to_i
          end

          opts.on("-d", "--directory [DIRECTORY]", "Directory containing evaluations to load.") do |o|
            @options[:directory] = o
          end
        end
      end

    end
  end
end
