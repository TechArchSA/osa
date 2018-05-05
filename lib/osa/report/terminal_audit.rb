# frozen_string_literal: true
module OSA
  module Report
    #
    # TerminalAudit handles all terminal formatting tasks for audit rules, then generate the table
    #
    class TerminalAudit

      def self.generate(audit_rule_result)
        new.build_table(audit_rule_result.clone)
      end

      # build table instance
      #
      # @param [Array <OSA::Servers::Server>]
      #
      # @return [Terminal::Table]
      #
      def build_table(audit_rule_result)
        rule_name   = audit_rule_result[:rule_name]
        rule_result = audit_rule_result[:result]
        # from the result find a hash that has keys. to be the report headers
        header    = audit_rule_result[:result].select {|hash| hash unless hash.nil? || hash.empty? }.first.keys
        rows = build_table_data(rule_result)
        ::Terminal::Table.new(:title => "Audit Result of: #{rule_name}".bold, :headings => header) do |t|
          t.style = {:all_separators => true, :border_i => "+"}
          rows.each { |row| t.add_row row }
        end
      end

      private
      # parse the table's rows
      #
      # @param [Array <OSA::Servers::Server>]
      #
      # @return [Array]
      #
      def build_table_data(rule_result)
        rule_result.delete_if {|result| result.nil? or result.empty?}
        rule_result.map do |result|
          result[:public_addr] = result[:public_addr].join("\n")
          result[:dst_ports]   = result[:dst_ports].join("\n")
          result[:severity]    = colorize_severity(result[:severity])
          result.values
        end
      end

      def colorize_severity(severity)
        case severity
        when "High" then "High".red
        when "Medium" then "Medium".yellow
        when "Low" then "Medium".green
        when "Informational" then "Medium".cyan
        else
          severity
        end
      end

    end
  end
end











