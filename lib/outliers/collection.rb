require 'enumerator'

module Outliers
  class Collection

    include Enumerable
    include Outliers::Verifications::Shared::Collection

    attr_reader :provider
    attr_accessor :targets

    def self.to_human
      (self.to_s.split('::') - ['Outliers', 'Resources']).map { |p| p.underscore }.join('_').downcase.gsub(/_collection$/, '')
    end

    def self.verifications
       Outliers::Verifications::Shared::Collection.verifications + self.resource_class.verifications 
    end

    def self.filters
      []
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
      list.each do |resource|
        block.call resource
      end  
    end

    def exclude_by_key(exclusions)
      save = list.reject {|u| exclusions.include? u.public_send key}
      @list = save
    end

    def filter(action, args)
      name  = args.keys.first
      value = args.fetch name

      unless self.public_methods.include? "filter_#{name}".to_sym
        raise Exceptions::UnknownFilter.new "Unknown filter '#{name}'."
      end

      filtered_list = self.public_send "filter_#{name}", value

      case action
      when 'include'
        logger.info "Including resources filtered by '#{name}' with value '#{value}'."
        logger.warn "No resources match filter." unless (filtered_list & @list).any?
        @list = filtered_list & @list
      when 'exclude'
        logger.info "Excluding resources filtered by '#{name}' with value '#{value}'."
        @list -= filtered_list
      else
        raise Exceptions::UnknownFilterAction.new "Filters must be either 'include' or 'exclude'."
      end
    end

    def verify(name, arguments=nil)
      logger.debug "Verifying '#{name}'."

      name += "?" unless name =~ /^.*\?$/

      return { resources: [], passing: true } unless list.any?

      set_target_resources name if targets.any?

      logger.debug "Target resources '#{list_by_key.join(', ')}'."

      unless verification_exists? name
        raise Exceptions::UnknownVerification.new "Unkown verification '#{name}'."
      end

      if collection_verification? name
        send_collection_verification name, arguments
      else
        send_resources_verification name, arguments
      end
    end

    def list
      @list ||= load_all
    end

    def key
      resource_class.key
    end

    def resource_class
      self.class.resource_class
    end

    private

    def verification_exists?(name)
      m = resource_class.instance_methods - resource_class.class.instance_methods
      m += Outliers::Verifications::Shared::Collection.instance_methods
      m -= [:source, :id, :method_missing]
      m.include? name.to_sym
    end

    def list_by_key
      list.map {|r| r.public_send key}
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
      logger.debug "Setting target resource(s) to '#{targets.join(', ')}'."

      @list = list.select {|r| targets.include? r.id }

      unless list.any?
        raise Outliers::Exceptions::TargetNotFound.new "No resources found matching one or more of '#{targets}'."
      end

      @list
    end

    def send_resources_verification(verification, arguments)
      failing_resources = reject do |resource|
        r = send_verification resource, verification, arguments
        logger.debug "Verification of resource '#{resource.id}' #{r ? 'passed' : 'failed'}."
        r
      end
      passing_resources = list - failing_resources
      resources = []
      resources += passing_resources.map { |r| { id: r.id, status: 0 } }
      resources += failing_resources.map { |r| { id: r.id, status: 1 } }
      { resources: resources, passing: failing_resources.none? }
    end

    def send_collection_verification(verification, arguments)
      send_verification self, verification, arguments
    end

    def send_verification(object, verification, arguments) 
      if object.method(verification).arity.zero?
        unless arguments.nil?
          raise Outliers::Exceptions::NoArgumentRequired.new "Verification '#{verification}' does not require an arguments."
        end
        object.public_send verification
      else
        if arguments.nil?
          raise Outliers::Exceptions::ArgumentRequired.new "Verification '#{verification}' requires arguments."
        end
        object.public_send verification, arguments
      end
    end

  end
end
