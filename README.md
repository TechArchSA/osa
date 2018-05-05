# OpenStack Security Auditor (OSA)

> OSA is OpenStack Security Auditor tool and library

If you are working on auditing and reviewing OpenStack Security Group rules, you'll directly recognize how tedious this task is. There's no direct way to list all security groups' rules related to each server. OpenStack has great API but it's abstract so you can merely list server details which contain "security group name" only, so you have to retrieve all security groups, inspect its rules to know the server's rules. This task is trivial if you have on or two servers and security group, but not in bigger environments.

## Features
- Easy and intuitive API 
- Support OpenStack APIv2 and APIv3
- Parsing Servers' details and Security Groups
- Resolve all referencing data into rich objects
- Mapping Servers with Security Groups
- Generate Terminal and Sheet yet neat reports 

## Installation

    $ gem install ossa

## Usage

### As a tool

```
$> osa -h


              ______
        '!!""""""""""""*!!'
     .u$"!'            .!!"$"
     *$!        'z`        ($!
     +$-       .$$&`       !$!
     +$-      `$$$$3       !$!
     +$'   !!  '!$!   !!   !$!
     +$'  ($$.  !$!  '$$)  !$!
     +$'  $$$$  !$!  $$$$  !$!
     +$'  $Ɛ    !$!   3$   !$!
     ($!  `$%`  !3!  .$%   ($!
      ($(` '"$!    `*$"` ."$!
       `($(` '"$!.($". ."$!
         `($(` !$$%. ."$!
           `!$%$! !$%$!
              `     `
                     The Cyber Daemons - TechArch
      
OpenStack Security Auditor (OSA) - Tool to extract, map, run_audit OpenStack security groups with servers.

Help menu:
   -c, --connect [JSON_FILE]        connect to OpenStack using given json file.
                                      (leave the file blank to generate a template file "connect.json")
   -d, --dump FILE                  import security group and server details dump file,
                                      (use OSE "https://github.com/TechArchSA/ose" tool.)
   -k, --key PASSWORD               decrypt the given security group file, if encryption option used in OSE tool.
                                      (used with -d/--dump)
   -a, --audit [AUDITRULE]          audit the given security groups,
                                      (default: all)
       --report-as [terminal|sheet] show the report as terminal table or as a sheet,
                                      (default: terminal)
   -v, --version                    Check current and latest version
   -h, --help                       Show this help message

Audit modules Options:
- exposed_admin_ports
   -p, --pub-ports PORTS            public ports that are naturally public. ports separated by comma with no spaces.
                                      (default: [80, 443, 25, 993, -1])
   -P, --prv-ports PORTS            private ports that used to access critical services. ports separated by comma with no spaces.
                                      (default: [20, 21, 22, 23, 135, 139, 389, 445, 3389, 8080, 2525])
- insecure_protocols
   -i, --insec-ports PORTS          public ports that are naturally public. ports separated by comma with no spaces.
                                      (default: [80, 443, 25, 993, -1])
- overlap_rules

Usage:
osa <OPTIONS>

Example:
osa -c connection.json
osa -c connection.json -a exposed_admin_ports -P 3389,22,445 
osa -d security_groups_map.yml -a exposed_admin_ports -P 3389,22,445 
```


### As a library
```ruby
connection = {
    auth_url:            'https://api-example.com/identity/v3',
    auth_method:         'password',
    user_domain:         'datacenter1',
    username:            'YOURUSER',
    api_key:             'YOURPASSWORD',
    project_domain_name: 'datacenter1',
    project_name:        'OUR_CLOUD_PROJECT',
    service_type:        'compute',
    # is_debug: true
}
openstack = OpenStack::Connection.create(connection)
security_groups = SecurityGroups.parse(openstack.security_group)
pp security_groups.list
servers = Servers.parse(openstack.servers_detail)
pp servers.list
security_groups_map = servers.map_security_groups(security_groups)
server = servers_details[0] 
pp server

# generate a terminal report
puts OSA::Report.create(:terminal, security_groups_map)
```


## Contributing

1. Fork it ( https://github.com/TechArchSA/osa/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
