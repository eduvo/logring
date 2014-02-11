require 'logring'

module Logring
  module Config
    extend self

    CONFIGFILE_TEMPLATE = File.expand_path("../../../config.default.yml", __FILE__)

    def load(configfile)
      @__configfile = configfile
    end

    def vars
      FileUtils.cp(CONFIGFILE_TEMPLATE, configfile) unless File.exists? configfile
      @__config ||= Logring::Utils.to_ostruct(YAML::load_file(configfile))
      @__config
    end

    def configfile
      @__configfile
    end

  end
end
