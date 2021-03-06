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

    desc "list [HOST]", "Lists nodes controlled by this Logring, or details for HOST."
    def list(host=nil)
      puts Logring::Runner.new(options[:configfile]).show_list(host)
    end

    desc "check [HOST]", "Verifies config for all hosts or one host."
    long_desc <<-LONGDESC
      - If you provide a HOST argument it will check config for that host.

      - Without HOST specified it will check the list of all host defined in the config file.
    LONGDESC
    def check(host=nil)
      Logring::Runner.new(options[:configfile]).do('check', host)
    end

    desc "init [HOST]", "Prepare the remote host."
    def init(host)
      Logring::Runner.new(options[:configfile]).do('init', host)
    end

    desc "grab [HOST [TASK [ACTION]]]", "Perform Action for the given host."
    def grab_alarms(host=nil, task=nil, action=nil)
      Logring::Runner.new(options[:configfile]).do(action, host, task)
    end

    desc "grab_report [HOST [TASK]]", "Generate reports for the given host."
    def grab_report(host=nil, task=nil)
      Logring::Runner.new(options[:configfile]).do('report', host, task)
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
