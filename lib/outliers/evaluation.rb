module Outliers
  class Evaluation

    attr_reader :collection, :provider_name, :provider_name_array

    def initialize(args)
      @run  = args[:run]
      @name = args[:name]
    end

    def connect(name, options={})
      @provider_name = merged_credentials(name, options).fetch 'provider'

      logger.info "Connecting via '#{name}' to '#{@provider_name}'."
      logger.info "Including connection options '#{options.map {|k,v| "#{k}=#{v}"}.join(',')}'." if options.any?

      set_provider_name_array

      @provider = Outliers::Provider.connect_to merged_credentials(name, options)
    end

    def resources(name, targets=[])
      logger.info "Loading '#{name}' resource collection."
      @collection = collection_object name

      targets_array = Array(targets)

      if targets_array.any?
        logger.info "Verifying against '#{targets_array.join(', ')}' from '#{name}' collection."
        collection.targets = targets_array
      end
      collection
    end

    def exclude(exclusions)
      collection.exclude_by_key Array(exclusions)
    end

    def verify(verification, arguments={})
      @resources_loaded ||= collection.load_all

      verification_result = collection.verify verification, arguments.keys_to_sym

      result = Outliers::Result.new evaluation:        @name,
                                    failing_resources: verification_result.fetch(:failing_resources),
                                    passing_resources: verification_result.fetch(:passing_resources),
                                    resource:          @collection,
                                    verification:      verification

      logger.info "Result: '#{result}'."

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

