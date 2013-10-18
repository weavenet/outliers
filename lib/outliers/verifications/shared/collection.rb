module Outliers
  module Verifications
    module Shared
      module Collection

        def none_exist?
          resources = list.map do |r|
            { id: r.id, status: 2 }
          end
          { resources: resources, passing: resources.none? }
        end

        def equals?(args)
          keys = Array(args)
          logger.debug "Verifying '#{keys.join(',')}' equals '#{list.empty? ? 'no resources' : list_by_key.join(',')}'."
          resources = list.map do |r|
            { id: r.id, status: 2 }
          end
          passing = list.map{|r| r.id} == keys
          { resources: resources, passing: passing }
        end

      end
    end
  end
end
