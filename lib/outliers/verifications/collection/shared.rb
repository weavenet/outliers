module Outliers
  module Verifications
    module Collection
      module Shared

        def none_exist?
          resources = {}
          list.each {|r| resources.merge! id: r, status: 2}
          { resources: resources, passing: resources.any? }
        end

        def equals?(args)
          keys = Array(args)
          logger.debug "Verifying '#{keys.join(',')}' equals '#{list.empty? ? 'no resources' : list_by_key.join(',')}'."
          resources = {}
          list.each {|r| resources.merge! id: r, status: 2}
          { resources: resources, passing: FIXME_WITH_EQUALS_LOGIC }
        end

      end
    end
  end
end
