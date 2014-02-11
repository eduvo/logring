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

    def check(host)
      if @hosts[host]
        remotehost = @hosts[host]
      else
        remotehost = @hosts.values
      end
      SSHKit::Coordinator.new(remotehost).each in: :parallel do |h|
        sudo = h.properties.sudo ? "sudo" : nil
        if test "[ -d #{h.properties.path} ]"
          within h.properties.path do
            h.properties.logs.to_h.each do |k,l|
              if capture("if #{sudo} [ ! -f #{l.file} ];then echo 1;fi") == "1"
                error "#{h.properties.name} #{k}: #{l.file} does not exist on #{h.properties.name}."
              elsif !sudo and test "[ ! -r #{l.file} ]"
                error "#{h.properties.name} #{k}: #{l.file} is not readable on #{h.properties.name} (permission problem)."
              else
                info "#{h.properties.name} #{k}: #{l.file} exists and is readable."
              end
            end
          end
        else
          error "#{h.properties.name} is not initialized, Run `logring init #{h.properties.name}` first."
        end
      end
    rescue Exception => e
      error "*** Error ***"
      error "*** " + e.message
    end

    def hosts_list
      @hosts
    end

    def init(host)
      if @hosts[host]
        SSHKit::Coordinator.new(@hosts[host]).each do |h|
          if test "[ -d #{h.properties.path} ]"
            info "#{h.properties.name} is already initialized."
          else
            info capture "curl -s -L #{Logring::Config.vars.install_url} | bash -s -- --slave --dest=#{h.properties.path}"
            within h.properties.path do
              execute "#{h.properties.bundle} install"
            end
          end
        end
      else
        error "Host '#{h.properties.name}' not found."
      end
    end

    def grab(host,task)
      if @hosts[host]
        remotehost = @hosts[host]
      else
        remotehost = @hosts.values
      end
      SSHKit::Coordinator.new(remotehost).each in: :parallel do |h|
        if task
          tasks = { task => h.properties.logs[task] }
        else
          tasks = h.properties.logs.to_h
        end
        sudo = h.properties.sudo ? "sudo" : ""
        within h.properties.path do
          tasks.each do |k,l|
            if test "[ -d cache/#{k} ]"
              execute :mkdir, "cache/#{k}"
            end
            if execute "#{sudo} #{h.properties.bundle} exec request-log-analyzer --silent -f #{l.type} --file cache/#{k}/index.html --output html' #{l.file}"
              destdir = "#{Logring::Config.webdir}/#{h.properties.name}/#{k}"
              FileUtils.mkdir_p(destdir) unless Dir.exists? destdir
              download! "#{h.properties.path}/cache/#{k}/index.html", "#{Logring::Config.webdir}/#{h.properties.name}/#{k}"
            end
          end
        end
      end
    end

  end
end
