module Outliers
  module Verifications
    module Shared

      def none_exist?
        list
      end

      def equals?(args)
        keys = Array(args[:keys])
        logger.debug "Verifying '#{list.join(',')}' equals '#{list.empty? ? 'no resources' : list_by_key.join(',')}'."
        list.reject {|r| keys.include? r.id}
      end

    end
  end
end
