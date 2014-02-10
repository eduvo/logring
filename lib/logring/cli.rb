require "thor"
require "logring"

module Logring

  class Cli < Thor
    include Thor::Actions

    default_task :help
    class_option :configfile,
      aliases: "-c",
      banner: "PATH",
      default: File.expand_path("config.yml", Dir.pwd),
      desc: "Path to the configuration file to use"

    desc "list", "Lists nodes controlled by this Logring."
    def list
      config = Logring::Config.load options[:configfile]
      runner = Logring::Runner.new config
      puts "Found #{runner.hosts_list.count} configured hosts:"
      runner.hosts_list.each do |h,d|
        puts "    #{h}"
        d.properties.logs.to_h.each do |t,l|
          puts "      #{t}: #{l.type} - #{l.file}"
        end
      end
    rescue Exception => e
      puts "*** Error ***"
      puts "*** " + e.message
      puts "*************"
    end

    desc "check", "Verifies that config file is usable."
    def check
      config = Logring::Config.load options[:configfile]
      runner = Logring::Runner.new config
      runner.check
    rescue Exception => e
      puts "*** Error ***"
      puts "*** " + e.message
      puts "*************"
    end

    desc "init", "Prepare the remote node."
    def init(host)
      config = Logring::Config.load options[:configfile]
      runner = Logring::Runner.new config
      runner.init(host)
    rescue Exception => e
      puts "*** Error ***"
      puts "*** " + e.message
      puts "*************"
    end

  end

end
