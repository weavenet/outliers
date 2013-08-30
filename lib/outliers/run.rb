module Outliers
  class Run
    attr_accessor :credentials, :results, :threads, :threaded, :thread_count

    def initialize(options={})
      @results                  = []
      @threads                  = []
      @threaded                 = false
      @thread_count             = 1
      Thread.abort_on_exception = true
    end

    def process_evaluations_in_dir
      files.each do |file|
        next if File.directory? file
        next if File.extname(file) != '.rb'
        logger.info "Processing '#{file}'."
        self.instance_eval File.read(file)
      end

      threads.each {|t| t.join}
    end

    def evaluate(name='unspecified', &block)
      while Thread.list.count > thread_count
        logger.info "Maximum concurrent threads running, sleeping."
        sleep 2
      end

      evaluation = Proc.new { Evaluation.new(:name => name, :run => self).instance_eval &block }

      threaded ? threads << Thread.new { evaluation.call } : evaluation.call
    end

    def passed
      @results.select {|r| r.passed?}
    end

    def failed
      @results.reject {|r| r.passed?}
    end

    private

    def files
      evaluations_path = File.join Outliers.config_path
      files = Dir.glob File.join(evaluations_path, '**', '*')
    end

    def logger
      @logger ||= Outliers.logger
    end

  end
end
