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
        set_logger(File.join(@config.logdir, 'logring.log'), @config.loglevel)
      rescue Exception => e
        error "*** " + e.message
      end
    end

    def check
      SSHKit::Coordinator.new(@hosts.values).each in: :parallel do |host|
        if test "[ -d #{host.properties.path} ]"
          within host.properties.path do
            host.properties.logs.to_h.each do |k,l|
              execute :pwd
              info capture :echo, :bundle, 'exec', 'request-log-analyzer', '-f', k, l
            end
          end
        else
          error "#{host.properties.name} is not initialized, Run `logring init #{host.properties.name}` first."
        end
      end
    rescue Exception => e
      error "*** Error ***"
      error "*** " + e.message
    end

    def hosts_list
      @hosts.keys
    end

    def init(host)
      if @hosts[host]
        SSHKit::Coordinator.new(@hosts[host]).each do |h|
          info capture(:uptime)
        end
      else
        error "Host '#{host}' not found."
      end
    end

  end
end
