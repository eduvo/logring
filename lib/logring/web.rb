require "slim"

module Logring
  class Web
    include Logring::Log

    def initialize(views_dir,vars)
      @vars = vars
      @views_dir = views_dir
    end

    def render
      nav = Slim::Template.new(File.join(@views_dir, 'nav.slim')).render(@vars)
      File.open(File.join(@vars.webdir, "nav.html"), "w") do |f|
        f.puts nav
      end
      @vars.nodes.to_h.each do |k,v|
        subdir = File.join(@vars.webdir, v.name)
        FileUtils.mkdir_p(subdir) unless Dir.exists? subdir
        index = Slim::Template.new(File.join(@views_dir, 'host_index.slim')).render(v)
        File.open(File.join(@vars.webdir, v.name, "index.html"), "w") do |f|
          f.puts index
        end
        hostnav = Slim::Template.new(File.join(@views_dir, 'host_nav.slim')).render(v)
        File.open(File.join(@vars.webdir, v.name, "nav.html"), "w") do |f|
          f.puts hostnav
        end
        if !File.exists? File.join(@vars.webdir, v.name, "welcome.html")
          hostwelcome = Slim::Template.new(File.join(@views_dir, 'host_welcome.slim')).render(v)
          File.open(File.join(@vars.webdir, v.name, "welcome.html"), "w") do |f|
            f.puts hostwelcome
          end
        end
        v.logs.to_h.each do |t, d|
          if !File.exists? File.join(@vars.webdir, v.name, "#{t}.html")
            hostdetails = Slim::Template.new(File.join(@views_dir, 'details.slim')).render(d)
            File.open(File.join(@vars.webdir, v.name, "#{t}.html"), "w") do |f|
              f.puts hostdetails
            end
          end
        end
      end
    end

  end
end
