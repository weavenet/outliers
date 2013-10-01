module Outliers
  class Evaluation

    attr_reader :resource_collection, :provider_name, :provider_name_array

    def initialize(args)
      @run  = args[:run]
      @name = args[:name]
    end

    def connect(credentials_name, options={})
      @credentials_name = credentials_name
      @provider_name    = merged_credentials(credentials_name, options).fetch 'provider'

      logger.info "Connecting via '#{credentials_name}' to '#{@provider_name}'."
      logger.info "Including connection options '#{options.map {|k,v| "#{k}=#{v}"}.join(',')}'." if options.any?

      set_provider_name_array

      @provider = Outliers::Provider.connect_to merged_credentials(credentials_name, options)
    end

    def resources(name, targets=[])
      logger.info "Loading '#{name}' resource collection."
      @resource_name       = name
      @resource_collection = collection_object name

      targets_array = Array(targets)

      if targets_array.any?
        logger.info "Verifying '#{targets_array.join(', ')}' from '#{name}' collection."
        resource_collection.targets = targets_array
      end
      resource_collection
    end

    def exclude(exclusions)
      resource_collection.exclude_by_key Array(exclusions)
    end

    def filter(args)
      resource_collection.filter args.keys_to_s
    end

    def verify(verification_name, arguments={})
      @resources_loaded ||= resource_collection.load_all

      verification_result = resource_collection.verify verification_name, arguments.keys_to_sym

      result = Outliers::Result.new credentials_name:  @credentials_name,
                                    failing_resources: verification_result.fetch(:failing_resources),
                                    name:              @name,
                                    passing_resources: verification_result.fetch(:passing_resources),
                                    provider_name:     @provider_name,
                                    resource_name:     @resource_name,
                                    verification_name: verification_name

      logger.info "Verification '#{verification_name}' #{result}."

      @run.results << result
    end

    private

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

    def credentials(name)
      @run.credentials.fetch name
    end

    def merged_credentials(name, options)
      credentials(name).merge! options.keys_to_s
      credentials(name).merge :name => name
    end

    def logger
      @logger ||= Outliers.logger 
    end

  end
end

