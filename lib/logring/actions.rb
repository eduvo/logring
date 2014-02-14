require 'logring'

module Logring
  module Actions
    extend self
    extend Logring::Log

    def check(hosts, options, *args)
      SSHKit::Coordinator.new(hosts).each options do |h|
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
    end

    def init(hosts, options, *args)
      SSHKit::Coordinator.new(hosts).each options do |h|
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
    end

    def report(hosts, options, task=nil)
      SSHKit::Coordinator.new(hosts).each options do |h|
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
