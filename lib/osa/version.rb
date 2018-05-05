module OSA
  VERSION = "0.1.0"

  module Version

    def current_version
      OSA::VERSION
    end

    # Get remote version from rubygem.org
    # @return [String] of the report version
    def remote_version
      rubygem_api = JSON.parse open("https://rubygems.org/api/v1/versions/osa.json").read
      rubygem_api.first["number"]
    rescue Exception => e
      puts "[!] ".yellow  + " Couldn't check the latest version, please check internet connectivity."
      exit!
    end

    # Check if latest version
    # @return [Boolean]
    def latest_version?
      remote_version.eql?(current_version)? true : false
    end

  end
end
