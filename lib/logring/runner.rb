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

    def init(host)
      if @hosts[host]
        SSHKit::Coordinator.new(@hosts[host]).each do |h|
          sudo = h.properties.sudo ? "sudo" : nil
          if test "[ -d #{h.properties.path} ]"
            info "#{h.properties.name} is already initialized."
          else
            info capture "curl -s -L #{Logring::Config.vars.install_url} | bash -s -- --dest=#{h.properties.path} --slave"
            within h.properties.path do
              execute "bash -l -c '#{h.properties.bundle} install'"
              execute "bash -l -c '#{sudo} /usr/local/rbenv/bin/rbenv rehash'"
            end
          end
        end
      else
        error "Host '#{h.properties.name}' not found."
      end
    end

    def do(action, host=nil, task=nil)
      if @hosts[host]
        remotehost = @hosts[host]
        options = {}
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


      SSHKit::Coordinator.new(remotehost).each options do |h|
        if task
          tasks = { task => h.properties.logs.to_h[task.to_sym] }
        else
          tasks = h.properties.logs.to_h
        end
        sudo = h.properties.sudo ? "sudo" : ""
        if action == 'report' && h.properties.logs.report
          within h.properties.path do
            tasks.each do |k,l|
              execute "#{sudo} request-log-analyzer --silent -f #{l.report} --file #{h.properties.path}/cache/#{k}.html --output html #{l.file}"
              destdir = "#{Logring::Config.vars.webdir}/#{h.properties.name}"
              FileUtils.mkdir_p(destdir) unless Dir.exists? destdir
              download! "#{h.properties.path}/cache/#{k}.html", "#{destdir}/#{k}.html"
            end
          end
        end
      end
    end

  end
end
