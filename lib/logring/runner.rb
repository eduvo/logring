module Logring
  class Runner

    def initialize(config)
      @config = config
      @hosts = config.nodes.to_h.collect do |h,i|
        b = ""
        b += "#{i.user}@" if i.respond_to? :user
        b += h.to_s
        b += ":#{i.port}" if i.respond_to? :port
        host = SSHKit::Host.new(b)
        host.properties.logs = i.logs
        host.properties.path = i.path
        host.properties.name = i.name
        host
      end
    end

    def check
      SSHKit::Coordinator.new(@hosts).each in: :parallel do |host|
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
      puts "*** Error ***"
      puts "*** " + e.message
    end

    def hosts_list
      @hosts.map(&:properties).map(&:name)
    end

    def init(host)
      puts host
    end

  end
end
