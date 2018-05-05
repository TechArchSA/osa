# frozen_string_literal: true

module OSA
  module Utils
    SEPARATOR = '-----=-|-=-----'
    # def current_version
    #   OSA::VERSION
    # end
    #
    # def remote_version
    #   rubygem_api = JSON.parse open("https://rubygems.org/api/v1/versions/osa.json").read
    #   rubygem_api.first["number"]
    # rescue Exception => e
    #   puts "[!] ".yellow  + " Couldn't check the latest version, please check internet connectivity."
    #   exit!
    # end
    # # Check latest version
    # def latest_version
    #   begin
    #     # current_version = OSA::VERSION
    #     # rubygem_api     = JSON.parse open("https://rubygems.org/api/v1/versions/osa.json").read
    #     # remote_version  = rubygem_api.first["number"]
    #     latest          = remote_version.eql?(current_version)? true : false
    #
    #     latest ? current_version : remote_version
    #   rescue Exception => e
    #     puts "[!] ".yellow  + " Couldn't check the latest version, please check internet connectivity."
    #     exit!
    #   end
    # end
    #
    # def latest_version?
    #   remote_version.eql?(current_version)? true : false
    # end

    def self.logo
      slogan = 'The Cyber Daemons - '.reset + 'TechArch'.bold
      %Q{
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
                     #{slogan}
      }.red.bold
    end
  end
end