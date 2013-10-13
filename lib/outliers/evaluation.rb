module Outliers
  class Evaluation

    attr_reader :resource_collection, :provider_name, :provider_name_array

    def initialize(args)
      @run  = args[:run]
      @name = args[:name]
    end

    def connect(account_name, options={})
      @account_name  = account_name
      @provider_name = merged_account(account_name, options).fetch 'provider'

      logger.info "Connecting via '#{account_name}' to '#{@provider_name}'."
      logger.info "Including connection options '#{options.map {|k,v| "#{k}=#{v}"}.join(',')}'." if options.any?

      set_provider_name_array

      @provider = Outliers::Provider.connect_to merged_account(account_name, options)
    end

    def resources(name, targets=nil)
      logger.debug "Loading '#{name}' resource collection."

      @resource_name       = name
      @resource_collection = collection_object name

      load_targets targets
      resource_collection
    end

    def filter(action, args)
      resource_collection.filter action, args.keys_to_s
    end

    def verify(verification_name, arguments=nil)
      @resources_loaded ||= resource_collection.load_all

      args_to_send = convert_verification_arguments arguments

      verification_result = resource_collection.verify verification_name, args_to_send

      result = Outliers::Result.new account_name:      @account_name,
                                    failing_resources: verification_result.fetch(:failing_resources),
                                    name:              @name,
                                    passing_resources: verification_result.fetch(:passing_resources),
                                    arguments:         Array(args_to_send),
                                    provider_name:     @provider_name,
                                    resource_name:     @resource_name,
                                    verification_name: verification_name

      logger.info "Verification '#{verification_name}' #{result.passed? ? 'passed' : 'failed'}."

      @run.results << result
    end

    private

    def load_targets(targets)
      case targets.class.to_s
      when "Hash"
        t = targets.keys_to_sym
        if t.has_key? :include
          list = Array(t.fetch :include)
          logger.info "Targeting '#{list.join(', ')}' from '#{@resource_name}' collection."
          resource_collection.targets = list
        elsif t.has_key? :exclude
          list = Array(t.fetch :exclude)
          logger.info "Excluding '#{list.join(', ')}' from '#{@resource_name}' collection."
          resource_collection.exclude_by_key list
        else
          logger.info "Targeting all resources in '#{@resource_name}' collection."
        end
      when "String", "Array"
        list = Array(targets)
        logger.info "Targeting '#{list.join(', ')}' from '#{@resource_name}' collection."
        resource_collection.targets = list
      when "Nil"
        logger.info "Targeting all resources in '#{@resource_name}' collection."
      end
    end

    def convert_verification_arguments(arguments)
      return Array(arguments) if arguments.is_a?(Array) || arguments.is_a?(String)
      return nil if arguments.is_a?(NilClass)
      raise Outliers::Exceptions::InvalidArguments.new "Verification arguments '#{arguments}' invalid. Must be a string or array."
    end

    def set_provider_name_array
      begin
        array = Outliers::Providers.name_map.fetch(provider_name).to_s.split('::')
        @provider_name_array = array[2..array.size]
      rescue KeyError
        raise Outliers::Exceptions::UnknownProvider.new "Unkown provider '#{provider_name}'"
      end
    end

    def collection_object(name)
      collection_object = name.split('_').map {|c| c.capitalize}.join('') + 'Collection'
      collection_array = ['Outliers', 'Resources'] + provider_name_array + [collection_object]
      collection_array.inject(Object) {|o,c| o.const_get c}.new(@provider)
    rescue NameError
      raise Outliers::Exceptions::UnknownCollection.new "Unknown collection '#{name}'."
    end

    def account(name)
      @run.account.fetch name
    end

    def merged_account(name, options)
      account(name).merge! options.keys_to_s
      account(name).merge :name => name
    end

    def logger
      @logger ||= Outliers.logger 
    end

  end
end
