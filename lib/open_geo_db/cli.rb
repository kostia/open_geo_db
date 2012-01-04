require "mixlib/cli"
require "yaml"

module OpenGeoDb
  class CLI
    include Mixlib::CLI

    option(:action,
       :required => true,
       :short => "-a ACTION",
       :long => "--action ACTION",
       :proc => Proc.new { |l| l.to_sym },
       :description => "Action to do (`create` or `destroy`)")

    option(:config,
        :default => "open_geo_db.yml",
        :short => "-c CONFIG",
        :long => "--config CONFIG",
        :description => "The configuration file to use (default `open_geo_db.yml`)")

    option(:help,
        :boolean => true,
        :on => :tail,
        :short => "-h",
        :long => "--help",
        :description => "Show this message",
        :show_options => true,
        :exit => 0)

    def run
      parse_options

      if File.exist?(config[:config])
        yaml = YAML.load_file(config[:config])["open_geo_db"]
        @database = yaml["database"]
        @username = yaml["username"]
        @password = "-p#{yaml["password"]}" if yaml["password"] and yaml["password"].any?
      end
      @database ||= "open_geo_db"
      @username ||= "root"

      action = config[:action]

      case action
      when :create then create
      when :destroy then destroy
      else
        puts("Unknown action `#{action}`. For usage see `open_geo_db --help`")
        exit 1
      end
    end

    private

    def create
      sh("mysqladmin -u#{@username} #{@password} create #{@database}")
      %w(opengeodb-begin DE DEhier AT AThier CH CHhier opengeodb-end).each do |basename|
        file = File.join(File.dirname(__FILE__), %w(.. .. vendor sql), "#{basename}.sql")
        sh("mysql -u#{@username} #{@password} #{@database} < #{file}")
      end
    end

    def destroy
      sh("mysqladmin -u#{@username} #{@password} drop -f #{@database}")
    end

    def sh(command)
      puts(command)
      %x{#{command}}
    end
  end
end
