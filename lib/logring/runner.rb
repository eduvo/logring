module Logring
  class Runner
    include Logring::Log

    def initialize(config)
      @config = config
      @hosts = config.nodes.to_h.reduce({}) do |a,(h,i)|
        b = ""
        b += "#{i.user}@" if i.respond_to? :user
        b += h.to_s
        b += ":#{i.port}" if i.respond_to? :port
        host = SSHKit::Host.new(b)
        host.properties.logs = i.logs
        host.properties.path = i.path
        host.properties.name = i.name
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
        if test "[ -d #{h.properties.path} ]"
          within h.properties.path do
            h.properties.logs.to_h.each do |k,l|
              execute :pwd
              info capture :echo, :bundle, 'exec', 'request-log-analyzer', '-f', k, l
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
            execute "curl -s -L #{Logring::Config.install_url} | bash -s -- --slave --dest=#{h.properties.path}"
          end

        end
      else
        error "Host '#{h.properties.name}' not found."
      end
    end

  end
end
