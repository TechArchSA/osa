# frozen_string_literal: true
module OSA
  module Audit
    module Rule
      #
      # ExposedAdminPorts extracts all rules that has administrative ports
      #  exposed to public (0.0.0.0/0).
      # @see (OSA::Audit::PRV_PORTS  and OSA::Audit::PUB_PORTS)
      #
      # @example
      #   ports = {pub_ports: [80, 443], prv_ports: [445, 22, 3389]}
      #   exposed = ExposedAdminPorts.run(security_groups_map, ports)
      #
      class ExposedAdminPorts
        PUB_PORTS = [80, 443, 25, 993, -1]
        PRV_PORTS = [20, 21, 22, 23, 135, 139, 389, 445, 3389, 8080, 2525]

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
              result: auditor(security_groups_map, options)
          }
        end

        # The core audit of security_groups_map and  options
        #
        # @param security_groups_map [Servers]
        #   expected to be security_group_map list
        #
        # @param options [Hash]
        #   of any other options that might the rule needs
        #
        # @return [Array <Hash>]
        #
        def self.auditor(security_groups_map, options)
          __pub_ports, prv_ports = get_ports(options)
          security_groups_map.map do |server|
            data_store = []
            server_name  = server.name
            public_addr  =  server.addresses.public
            next if public_addr.empty?                                      # skip if no public ip, no risk here.
            server.security_groups.map do |sec_grp|
              sec_grp.rules.map do |rule|
                protocol  = rule.ip_protocol
                src_ip    = rule.ip_range
                dst_port  = [rule.to_port]
                dst_ports = dst_port.select {|p| prv_ports.include?(p)}
                rule_data =
                    {
                        severity: 'High', server_name: server_name,
                        public_addr: public_addr, sec_grp_name: rule.parent_group_name,
                        protocol: protocol, dst_ports: dst_ports
                    }
                  data_store << rule_data if src_ip == '0.0.0.0/0' && !dst_ports.empty?  # [Core Logic] Report if administrative port is publicly accessible
              end
            end
            data_store
          end.flatten
        end

        # get public port from options
        #
        # @param pub_ports [Array]
        #
        # @param prv_ports [Array]
        #
        # @return [Hash]
        #   of { pub_ports: pub_ports, prv_ports: prv_ports }
        #
        def self.get_ports(options)
          pub_ports = (options[:pub_ports].map(&:to_i) if options[:pub_ports].is_a?(Array)) || PUB_PORTS
          prv_ports = (options[:prv_ports].map(&:to_i) if options[:prv_ports].is_a?(Array)) || PRV_PORTS
          [ pub_ports.flatten, prv_ports.flatten ]
        end

        private_class_method :auditor, :get_ports
      end
    end
  end
end