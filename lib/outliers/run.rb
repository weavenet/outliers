module Outliers
  class Run
    attr_accessor :credentials, :results

    def initialize
      @results = []
    end

    def process_evaluations_in_config_folder
      evaluations_path = File.join Outliers.config_path
      files = Dir.glob(File.join(evaluations_path, '**', '*'))
      files.each do |file|
        next if File.directory? file
        next if File.extname(file) != '.rb'
        logger.info "Processing '#{file}'."
        self.instance_eval File.read(file)
      end
    end

    def evaluate(name='unspecified', &block)
      Evaluation.new(:name => name, :run => self).instance_eval &block
    end

    def passed
      @results.select {|r| r.passed?}
    end

    def failed
      @results.reject {|r| r.passed?}
    end

    private

    def logger
      @logger ||= Outliers.logger
    end

  end
end
