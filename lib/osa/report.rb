# frozen_string_literal: true
require 'osa/report/terminal'
require 'osa/report/sheet'

module OSA
  module Report
    HEADER = ['Server name', 'Status', 'Public address', 'Private address', 'Security groups', 'Protocol',
              'From port', 'To port', 'IP range', 'Remote group' ]

    def self.create(report_type, security_groups_map)
      return OSA::Report::Terminal.generate(security_groups_map) if report_type == :terminal
      return OSA::Report::Sheet.new    if report_type == :sheet
    end
  end
end
