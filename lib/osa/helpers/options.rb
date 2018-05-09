# frozen_string_literal: true
require 'osa/audit'
module OSA
  module Helpers

    #
    # A helper module for all commandline options
    #
    module Options
      include OSA::Audit

      # helper for OSA version
      def version
        puts "-[#{'Current version'.green}]----"
        puts current_version
        if latest_version?
          puts "[+] ".dark_green + "You have latest version."
        else
          puts "-[#{'Latest version'.green}]----"
          puts remote_version
          puts "[+] ".dark_green + "Please update. (gem update osa)"
        end
      end

      # option helper to generate the general report
      #   OSA::Helper::Options --> OSA::Report#main --> OSA::Report::TerminalMainList#generate
      #
      # @param report_type [Symbol]
      #   report type, expects :terminal or :sheet
      # @param security_groups_map [security_groups_map]
      #   security groups map
      #
      def report_main(report_type, security_groups_map)
        puts OSA::Report.main(report_type, security_groups_map) if report_type == :terminal
        # OSA::Report.main(report_type, security_groups_map)      if report_type == :sheet   # TODO
        puts "[!] Report as sheet feature is not yet implemented!" if report_type == :sheet
      end

      # option helper for audit rules
      #   OSA::Helper::Options --> OSA::Report#audit --> OSA::Report::TerminalAudit#generate
      #
      # @param report_type [Symbol]
      #   report type, expects :terminal or :sheet
      # @param security_groups_map [security_groups_map]
      #   security groups map
      # @param rule_name [String]
      #   rule name to audit the security groups
      # @param options [Hash]
      #   the options is data store for all rules_options
      #   each rule will extract the data it need from the hash
      #   so the options belongs to everyone
      #
      # @return [OSA::Audit::Rule]
      #
      def report_audit(report_type, security_groups_map, rule_name, options = {})
        puts OSA::Report.audit(report_type, security_groups_map, rule_name, options)  if report_type == :terminal
        OSA::Report.audit(report_type, security_groups_map, rule_name, options)       if report_type == :sheet
      end

      # help for openstack connection
      #
      # @param file [String]
      #   the JSON file that contains the OpenStack connection settings
      #
      def connect(file = '')
        if File.exists? file.to_s
          begin
            connection = JSON.parse(open(file).read, :symbolize_names => true)
            openstack  = OpenStack::Connection.create(connection)
            security_groups = OSA::SecurityGroups.parse(openstack.security_groups).clone
            servers         = OSA::Servers.parse(openstack.server_details).clone
            servers.map_security_groups(security_groups)
          rescue JSON::ParserError => e
            puts "[x] ".red + " Invalid JSON format!. please use -c/--connect without argument to generate a template file"
            exit!
          rescue OpenStack::Exception => e
            puts "[x] ".red + e
            puts e.backtrace
            puts e.message
            exit!
          rescue Exception => e
            puts "[x] ".red + e
          end
        else
          puts "[-] ".yellow + "Creating connection template file 'connection.json', please edit and try again."
          conn_file = <<~FILE
            {
               "auth_url:"https://api-example.com/identity/v3",
               "auth_method":"password",
               "user_domain":"datacenter1",
               "username":"YOURUSER",
               "api_key":"YOURPASSWORD",
               "project_domain_name":"datacenter1",
               "project_name":"OUR_CLOUD_PROJECT",
               "service_type":"compute"
            }
          FILE

          File.write('connection.json', conn_file)
          exit!
        end
      end

      # helper do read the security groups' dump file.
      #   The [OSA::SecurityGroups#parse] and [OSA::Servers#parse] will load (using [YAML.load]),
      #   then parse the content
      #
      # @param file [String]
      #   dump file path
      # @param password [String]
      #   decryption key of the encrypted file
      #
      def dump(file, password = nil)
        if File.exist? file
          begin
            dump = decrypt(file, password)
            # dump = open(file).read.split(OSA::Utils::SEPARATOR)
            security_groups = OSA::SecurityGroups.parse(YAML.load(dump[0])).clone
            servers         = OSA::Servers.parse(YAML.load(dump[1])).clone
            servers.map_security_groups(security_groups)
          rescue Exception => e
            puts "[x] ".red + "#{e}"
          end
        else
          puts "[!] " + "File not exist! '#{file}'"
          exit!
        end
      end

      # TODO: Decrypt the file here  using the given password. waiting OSE to see the encryption method
      # Decrypts a given file if encrypted
      #   The file is a YAML file contains two parts separated by ( *-----=-|-=-----* )
      #   Security Groups and Server details respectively.
      #
      # @param file [String]
      #   dump file path
      # @param password [String]
      #   decryption key of the encrypted file
      #
      # @return [Array <SecurityGroups, Servers>]
      #
      def decrypt(file, password)
        file_content = open(file).read if password.nil?
        file_content = open(file).read if password
        file_content.split(OSA::Utils::SEPARATOR)
      end
    end
  end
end