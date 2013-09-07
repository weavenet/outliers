module Outliers
  module Resources
    module Aws
      module Iam
        class User < Resource

          def no_access_keys?
            logger.debug "#{id} has #{access_keys.count} access key(s)."
            !access_keys.any?
          end

          def no_password_set?
            !source.login_profile.exists?
          end

          def mfa_enabled?
            source.mfa_devices.count > 0
          end

          private

          def access_keys
            @access_keys ||= source.access_keys
          end

        end
      end
    end
  end
end
