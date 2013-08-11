module Outliers
  class Run
    attr_accessor :credentials, :results

    def initialize
      @results = []
    end

    def process_evaluations_in_config_folder
      evaluations_path = File.join Outliers.config_path
      entries = Dir.entries(evaluations_path) - ['.', '..']
      entries.each do |e|
        file = File.join(evaluations_path, e)
        unless File.directory? file
          logger.info "Processing '#{file}'."
          self.instance_eval File.read(file)
        end
      end
    end

    def evaluate(name='unspecified')
      yield Evaluation.new :name => name, :run => self
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
