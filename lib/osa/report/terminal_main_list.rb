# frozen_string_literal: true
module OSA
  module Report
    #
    # TerminalMainList handles all terminal table formatting tasks, then generate the table
    #
    class TerminalMainList
      HEADER = ['Server name', 'Status', 'Public address', 'Private address', 'Security groups', 'Protocol',
                'From port', 'To port', 'IP range', 'Remote group' ]

      def self.generate(security_groups_map)
        new.build_table(security_groups_map.clone)
      end

      # build table instance
      #
      # @param [Array <OSA::Servers::Server>]
      #
      # @return [Terminal::Table]
      #
      def build_table(security_groups_map)
        rows = build_table_data(security_groups_map)
        ::Terminal::Table.new(:title => "OpenStack Security Group Overview".bold, :headings => HEADER) do |t|
          t.style = {:all_separators => true, :border_i => "+"}
          rows.each { |row| t.add_row row }
        end
      end

      private
      # parse the table's  rows
      #
      # @param [Array <OSA::Servers::Server>]
      #
      # @return [Array]
      #
      def build_table_data(security_groups_map)
        rows = []
        security_groups_map.each do |_server|
          name         = _server.name
          status       = _server.status
          public_addr  = _server.addresses.public
          private_addr = _server.addresses.private
          sec_grp      = []
          protocol     = []
          from_port    = []
          to_port      = []
          ip_range     = []
          group        = []
          # server's security group details
          _server.security_groups.map do |sg|
            rules =  sg.rules
            rules.map do |rule|
              protocol     << rule.ip_protocol
              from_port    << rule.from_port
              to_port      << rule.to_port
              ip_range     << rule.ip_range
              # as we need security group to be aligned with its rules we've to
              # add the first label to the first rule then add nil for its other rules to
              # be a space when we .join("\n")
              sec_grp.include?(rule.parent_group_name)?  sec_grp << nil  : sec_grp << rule.parent_group_name
              group << rule.group
            end
          end

          rows << [ name, status, public_addr.join("\n"), private_addr.join("\n"),
                    sec_grp.join("\n"), protocol.join("\n"), from_port.join("\n"),
                    to_port.join("\n"), ip_range.join("\n"), group.join("\n") ]
        end

        rows
      end
    end
  end
end
