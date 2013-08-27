module Outliers
  class Run
    attr_accessor :credentials, :results

    def initialize(options={})
      @results      = []
      @threaded     = false
      @threads      = []
      @thread_count = options[:concurrent] || 5
    end

    def process_evaluations_in_dir
      @threaded = true
      evaluations_path = File.join Outliers.config_path
      files = Dir.glob(File.join(evaluations_path, '**', '*'))
      files.each do |file|
        next if File.directory? file
        next if File.extname(file) != '.rb'
        logger.info "Processing '#{file}'."
        self.instance_eval File.read(file)
      end
      threads.each {|t| t.join}
    end

    def evaluate(name='unspecified', &block)
      if Thread.list.count > thread_count
        logger.debug "Maximum concurrent evaluations running, sleeping"
        sleep 2
      end
      evaluation = Proc.new { Evaluation.new(:name => name, :run => self).instance_eval &block }
      if threaded
        threads << Thread.new { evaluation.call }
      else
        evaluation.call
      end
    end

    def passed
      @results.select {|r| r.passed?}
    end

    def failed
      @results.reject {|r| r.passed?}
    end

    private

    def threaded
      @threaded
    end

    def thread_count
      @thread_count
    end

    def threads
      @threads
    end

    def logger
      @logger ||= Outliers.logger
    end

  end
end
