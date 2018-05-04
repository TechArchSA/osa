# frozen_string_literal: true

module OSA
  module Helpers

    #
    # A helper module for all commandline options
    #
    module Options

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

      # help for openstack connection
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

      # helper do read the security groups' dump file. Decrypt it if encrypted
      def dump(file, password = nil)
        if File.exist? file
          begin
            if password
              file = file # TODO: Decrypt the file here  using the given password. waiting OSE to see the ecrtpytion method
            end
            dump = open(file).read.split(OSA::Utils::SEPARATOR)
            security_groups = OSA::SecurityGroups.parse(YAML.load(dump[0])).clone
            servers         = OSA::Servers.parse(YAML.load(dump[1])).clone
            security_groups_map = servers.map_security_groups(security_groups)
            # puts OSA::Report.create(:terminal, security_groups_map)
            # audit(security_groups_map) # TODO handle ports pub and prv
          rescue Exception => e
            puts "[x] ".red + "#{e}"
          end
        else
          puts "[!] " + "File not exist! '#{file}'"
          exit!
        end
      end

      # helper for security group table
      def table(security_groups_map)
        puts OSA::Report.create(:terminal, security_groups_map)
      end

      # helper for rules audit
      def audit(security_groups_map, pub_ports = nil, prv_ports = nil)
        # if ports is not given then consider the defaults
        pub_ports = pub_ports.map(&:to_i) || Helpers::Audit::PUB_PORTS
        prv_ports = prv_ports.map(&:to_i) || Helpers::Audit::PRV_PORTS

        puts "[+] ".bold + "Audit"
        security_groups_map.each do |server|
          server_name  = server.name
          public_addr  =  server.addresses.public
          next if public_addr.empty?  # skip if no public ip
          server.security_groups.map do |sec_grp|
            sec_grp.rules.map do |rule|
              protocol = rule.ip_protocol
              src_ip   = rule.ip_range
              dst_port = [rule.to_port].flatten

              next unless (pub_ports & dst_port).empty?                   # Skip if it's naturally a public service
              if src_ip == '0.0.0.0/0' && !(prv_ports & dst_port).empty?  # Report if administrative port is publicly accessible
                report :warning, server_name, public_addr, rule, src_ip, protocol, dst_port.join('')
              end
            end
          end
        end
      end

      # Helper to generate audit warnings
      def report(type, server_name, public_addr, rule, src_ip, protocol, dst_port)
        case type
        when :warning
          puts "[+] ".red + " Warning: #{rule.parent_group_name} | #{server_name}(#{public_addr.join(', ')}) : #{src_ip} ->  #{protocol}/#{dst_port}"
        when :observation
        end
      end

    end
  end
end