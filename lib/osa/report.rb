# frozen_string_literal: true
require 'osa/report/terminal_main_list'
require 'osa/report/terminal_audit'
# require 'osa/report/sheet'

module OSA
  module Report
    def self.main(report_type, security_groups_map)
      OSA::Report::TerminalMainList.generate(security_groups_map) if report_type == :terminal
      #  OSA::Report::TerminaMainSheet.new    if report_type == :sheet # TODO
    end

    def self.audit(report_type, security_groups_map, rule_name, options = {})
      audit_result = OSA::Audit.rule(security_groups_map, rule_name, options)
      OSA::Report::TerminalAudit.generate(audit_result) if report_type == :terminal
    end
  end
end
