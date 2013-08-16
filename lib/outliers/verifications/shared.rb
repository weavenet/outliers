module Outliers
  module Verifications
    module Shared

      def none_exist?
        logger.debug 'Verifying no resources exist.'
        logger.debug "Found #{all.empty? ? 'no resources' : all_by_key.join(',')}."
        all
      end

      def equals?(args)
        list = Array(args[:keys])
        logger.debug "Verifying '#{list.join(',')}' equals #{all.empty? ? 'no resources' : all_by_key.join(',')}."
        all_by_key - list
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
