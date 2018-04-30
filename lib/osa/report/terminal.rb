# frozen_string_literal: true
module OSA
  module Report
    class Terminal

      def self.generate(security_groups_map)
        new.build_table(security_groups_map.clone)
      end

      #
      # build table instance
      #
      # @param [Array <OSA::Servers::Server>]
      #
      # @return [Terminal::Table]
      #
      def build_table(security_groups_map)
        rows = build_table_data(security_groups_map)
        ::Terminal::Table.new(:title => "OpenStack Security Group Overview".bold, :headings => Report::HEADER) do |t|
          t.style = {:all_separators => true, :border_i => "+"}
          rows.each { |row| t.add_row row }
        end
      end

      private
      #
      # parse and create the table's  rows
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
          sec_grp      = _server.security_groups.map(&:name)
          protocol     = []
          from_port    = []
          to_port      = []
          ip_range     = []
          remote_group = []
          _server.security_groups.map do |sg|
            rules =  sg.rules
            rules.map do |rule|
              protocol     << rule.ip_protocol
              from_port    << rule.from_port
              to_port      << rule.to_port
              ip_range     << rule.ip_range
              remote_group << rule.group
            end
          end
          rows << [
              name,
              status,
              public_addr.join("\n"),
              private_addr.join("\n"),
              sec_grp.join("\n"),
              protocol.is_a?(Array)             ? protocol.join("\n")     : protocol,
              from_port.is_a?(Array)            ? from_port.join("\n")    : from_port,
              to_port.is_a?(Array)              ? to_port.join("\n")      : to_port,
              ip_range.compact.is_a?(Array)     ? ip_range.join("\n")     : ip_range,
              remote_group.compact.is_a?(Array) ? remote_group.join("\n") : remote_group
          ]
        end

        rows
      end

    end
  end
end
