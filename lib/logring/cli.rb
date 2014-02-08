require "thor"
require "logring"

module Logring

  class Cli < Thor
    include Thor::Actions

    def self.source_root
      File.expand_path("../../../templates", __FILE__)
    end

    default_task :help
    class_option :configfile,
      aliases: "-c",
      banner: "PATH",
      default: File.expand_path("config.yml", Dir.pwd),
      desc: "Path to the configuration file to use"

    desc "list", "Lists nodes controlled by this Logring."
    def list
      config = Logring::Config.load options[:configfile]
    rescue Exception => e
      puts "*** Error ***"
      puts "*** " + e.message
      puts "*************"
    end

  end

end
