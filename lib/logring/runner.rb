module Logring
  class Runner
    include Logring::Log

    def initialize(configfile)
      Logring::Config.load configfile
      @config = Logring::Config.vars
      @hosts = @config.nodes.to_h.reduce({}) do |a,(h,i)|
        b = ""
        b += "#{i.user}@" if i.respond_to? :user
        b += h.to_s
        b += ":#{i.port}" if i.respond_to? :port
        host = SSHKit::Host.new(b)
        host.properties.logs = i.logs
        host.properties.path = i.path
        host.properties.name = i.name
        host.properties.sudo = i.sudo
        host.properties.bundle = i.bundle || "bundle"
        a[i.name] = host
        a
      end
      begin
        if @config.logdir == 'STDOUT'
          set_logger(STDOUT, @config.loglevel)
        else
          set_logger(File.join(@config.logdir, 'logring.log'), @config.loglevel)
        end
      rescue Exception => e
        puts "*** " + e.message
      end
    end

    def show_list(host=nil)
      output = ""
      if host
        if @hosts[host]
          hosts_list = { host => @hosts[host] }
        else
          return "#{host} not found. Check `logring list`."
        end
      else
        hosts_list = @hosts
        output += "Found #{@hosts.count} configured hosts:\n"
      end
      hosts_list.each do |h,d|
        output += "    #{h}:\n"
        d.properties.logs.to_h.each do |t,l|
          output += "      #{t}: #{l.file}\n"
          if l.report
            output += "        report type: #{l.report}\n"
          end
        end
      end
      output
    end

    def do(action, host=nil, task=nil)
      if host
        if @hosts[host]
          remotehost = @hosts[host]
          options = {}
        else
          error "#{host} not found."
          return false
        end
      else
        remotehost = @hosts.values
        options = { in: :parallel }
      end
      if Logring::Actions.respond_to? action.to_sym
        Logring::Actions.send(action.to_sym, remotehost, options, task)
      else
        error "#{action} unknown."
      end
      return true
    end

  end
end
