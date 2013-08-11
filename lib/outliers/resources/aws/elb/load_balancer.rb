module Outliers
  module Resources
    module Aws
      module Elb
        class LoadBalancer < Resource
          def self.verifications
            [
              { name: 'ssl_certificates_valid',
                description: 'Validates all SSL certificates associated with an ELB are valid for given number of days',
                args: 'days: DAYS' }
            ]
          end

          def ssl_certificates_valid?(args)
            days = args[:days]
            pass = true

            logger.debug "Load Balancer '#{id}' has no certificates." unless certificates.any?

            date = Time.now + (days.to_i * 86400)

            logger.debug "Validating no certs expire before '#{date.to_s}'."

            certificates.each do |c|
              certificate = OpenSSL::X509::Certificate.new c.certificate_body
              subject     = certificate.subject
              not_after   = certificate.not_after

              logger.debug "Certificate '#{subject}' expires '#{not_after}'."
              result = not_after > date
              logger.debug "Certificate #{result ? "valid" : "invalid"}."
              pass = false unless result
            end
            pass
          end

          private

          def certificates
            listeners.map {|l| l.server_certificate}.reject {|s| s.nil?}
          end

          def listeners
            @listeners ||= source.listeners
          end

        end
      end
    end
  end
end
