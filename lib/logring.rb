require "yaml"
require "awesome_print"
require "sshkit"

require "logring/version"
require "logring/config"
require "logring/utils"
require "logring/logger"
require "logring/runner"

module Logring
  CONFIGFILE_TEMPLATE = File.expand_path("../../config.default.yml", __FILE__)
  INSTALL_URL = "https://raw.github.com/eduvo/logring/master/install"
end
