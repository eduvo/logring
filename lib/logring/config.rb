require 'logring'

module Logring
  module Config
    extend self
    def load(configfile)
      FileUtils.cp(Logring::CONFIGFILE_TEMPLATE, configfile) unless File.exists? configfile
      @__config ||= Logring::Utils.to_ostruct(YAML::load_file(configfile))
    end
  end
end
