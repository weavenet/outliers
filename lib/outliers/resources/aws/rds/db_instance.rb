module Outliers
  module Resources
    module Aws
      module Rds
        class DbInstance < Resource
          def self.key
            'db_instance_identifier'
          end

          def self.verifications
            [ 
              { name: 'backup_retention_period',
                description: 'Validate the backup retention period equals given days for the db_instance.',
                args: 'days: DAYS' },
              { name: 'multi_az',
                description: 'RDS Multi AZ set to yes.' }
            ]
          end

          def backup_retention_period?(args)
            days = args[:days]

            current = source.backup_retention_period
            logger.debug "Verifying '#{id}' retention period of '#{current}' equals '#{days}' days."
            current.to_i == days.to_i
          end

          def multi_az?
            source.multi_az?
          end
        end
      end
    end
  end
end
