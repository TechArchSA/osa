# frozen_string_literal: true
module OSA
  module Audit
    module Rule
      class ExposedAdminPorts
        def self.run(security_groups_map)
          new.parser(security_groups_map)
        end

        def parser(security_groups_map)

        end

        def exposed_admin_ports(security_groups_map)
          # TODO
        end
      end
    end
  end
end