# frozen_string_literal: true
module OSA
  module Audit
    module Rule
      class InsecureProtocols
        PORTS = [20, 21, 22, 23, 110, 143, 135, 139,
                 161, 389, 445, 1521,3389, 8080, 2525]

        # main function return self of parsing the security_groups_map and it's options.
        #   Note: All audit rule has the same method
        #
        # @param security_groups_map [Servers]
        #   expected to be security_group_map list
        #
        # @param options [Hash]
        #   of any other options that might the rule needs.
        #   expected to contain :pub_ports and :prv_ports
        #
        # @return [ExposedAdminPorts]
        #
        def self.run(security_groups_map, options = {})
          {
              rule_name: "Exposed Administrative Ports",
              result: parser(security_groups_map, options)
          }
        end


        def self.auditor(security_groups_map, options)
          puts "[]".yellow + "Not yet implemented"
          eixt!
        end



        private_class_method :auditor
      end
    end
  end
end
