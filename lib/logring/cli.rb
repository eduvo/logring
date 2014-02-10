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
          puts "        #{t}: #{l.type} - #{l.file}"
        end
      end
    rescue Exception => e
      puts "*** Error ***"
      puts "*** " + e.message
      puts "*************"
    end

    desc "check [HOST]", "Verifies config for all hosts or one host."
    long_desc <<-LONGDESC
      - If you provide a HOST argument it will check config for that host.

      - Without HOST specified it will check the list of all host defined in the config file.
    LONGDESC
    def check(host=nil)
      config = Logring::Config.load options[:configfile]
      runner = Logring::Runner.new config
      runner.check(host)
    rescue Exception => e
      puts "*** Error ***"
      puts "*** " + e.message
      puts "*************"
    end

    desc "init [HOST]", "Prepare the remote host."
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
