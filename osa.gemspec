
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "osa"

Gem::Specification.new do |spec|
  spec.name          = "osa"
  spec.version       = OSA::VERSION
  spec.authors       = ["KING SABRI"]
  spec.email         = ["king.sabri@gmail.com"]

  spec.summary       = %q{OSA is OpenStack Security Auditor tool and library}
  spec.description   = %q{OSA is OpenStack Security Auditor tool and library}
  spec.homepage      = "https://github.com/TechArchSA/osa/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ['osa']
  spec.require_paths = ["lib"]

  spec.add_dependency 'openstack'
  spec.add_dependency 'terminal-table'

  spec.post_install_message = OSA::Utils.logo
end
