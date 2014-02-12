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
      runner = Logring::Runner.new options[:configfile]
      puts "Found #{runner.hosts_list.count} configured hosts:"
      runner.hosts_list.each do |h,d|
        puts "    #{h}:"
        d.properties.logs.to_h.each do |t,l|
          puts "      #{t}: #{l.file}"
          if l.report
            puts "        #{l.report}"
          end
        end
      end
    end

    desc "check [HOST]", "Verifies config for all hosts or one host."
    long_desc <<-LONGDESC
      - If you provide a HOST argument it will check config for that host.

      - Without HOST specified it will check the list of all host defined in the config file.
    LONGDESC
    def check(host=nil)
      Logring::Runner.new(options[:configfile]).check(host)
    end

    desc "init [HOST]", "Prepare the remote host."
    def init(host)
      Logring::Runner.new(options[:configfile]).init(host)
    end

    desc "grab_report [HOST] [TASK]", "Generate reports for the given host."
    def grab_report(host=nil,task=nil)
      Logring::Runner.new(options[:configfile]).grab_report(host,task)
    end

    desc "grab_alarms [HOST] [TASK]", "Generate reports for the given host."
    def grab_alarms(host=nil,task=nil)
      Logring::Runner.new(options[:configfile]).grab_alarms(host,task)
    end

    desc "build", "Builds the reports webpages."
    def build
      Logring::Config.load options[:configfile]
      directory "www", Logring::Config.vars.webdir
      web = Logring::Web.new File.join(Logring::Cli.source_root, 'views'), Logring::Config.vars
      web.render
    end

  end

end
