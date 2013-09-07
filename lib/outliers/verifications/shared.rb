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

      module_function

      def verifications
         [
           { name: 'none_exist',
             description: 'Verify no resources exist.' },
           { name: 'equals',
             description: 'Verify resources match the given list of keys.',
             args: 'keys: [KEY1,KEY2]' }
         ]
      end

    end
  end
end
