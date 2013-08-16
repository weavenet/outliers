require 'enumerator'

module Outliers
  class Collection

    include Enumerable
    include Outliers::Verifications::Shared

    attr_reader :provider
    attr_accessor :targets

    def self.to_human
      (self.to_s.split('::') - ['Outliers', 'Resources']).map { |p| p.underscore }.join('_').downcase.gsub(/_collection$/, '')
    end

    def self.verifications
       Outliers::Verifications::Shared.verifications + self.resource_class.verifications 
    end

    def self.resource_class
      array = self.to_s.gsub(/Collection$/, '').split('::')
      array.inject(Object) {|o,c| o.const_get c}
    end

    def to_s
      self.class.to_human
    end

    def initialize(provider)
      @targets   = []
      @provider = provider
      @logger   = Outliers.logger
    end

    def each &block  
      all.each do |resource|
        block.call resource
      end  
    end

    def exclude_by_key(exclusions)
      @logger.info "Excluding the following resources: '#{exclusions.join(',')}'."
      save = all.reject {|u| exclusions.include? u.public_send key}
      @all = save
    end

    def verify(name, arguments={})
      name << "?" unless name =~ /^.*\?$/

      logger.debug "Verifying resources '#{all_by_key.join(', ')}'."

      if collection_verification? name
        send_collection_verification name, arguments
      else
        send_resources_verification name, arguments
      end
    end

    def all
      @all ||= load_all
    end

    def key
      resource_class.key
    end

    def resource_class
      self.class.resource_class
    end

    private

    def all_by_key
      all.map {|r| r.public_send key}
    end

    def connect
      @provider.connect
    end

    def logger
      @logger
    end

    def collection_verification?(name)
      self.public_methods.include? name.to_sym
    end

    def set_target_resources(verification)
      logger.info "Verifying target '#{targets.join(', ')}'."

      @all = all.select {|r| targets.include? r.id }

      unless all.any?
        raise Outliers::Exceptions::TargetNotFound.new "No resources found matching one or more of '#{targets}'."
      end

      @all
    end

    def send_resources_verification(verification, arguments)
      set_target_resources verification if targets.any?

      failing_keys = reject do |resource|
        result = send_verification resource, verification, arguments
        logger.debug "Verification of resource '#{resource.id}' #{result ? 'passed' : 'failed'}."
        result
      end
      { failing_keys: failing_keys, passing_keys: all - failing_keys }
    end

    def send_collection_verification(verification, arguments)
      failing_keys = send_verification(self, verification, arguments)
      { failing_keys: failing_keys, passing_keys: all - failing_keys }
    end

    def send_verification(object, verification, arguments) 
      if object.method(verification).arity.zero?
        if arguments.any?
          raise Outliers::Exceptions::NoArgumentRequired.new "Verification '#{verification}' does not require an arguments."
        end
        object.public_send verification
      else
        if arguments.none?
          raise Outliers::Exceptions::ArgumentRequired.new "Verification '#{verification}' requires arguments."
        end
        object.public_send verification, arguments
      end
    end

  end
end
