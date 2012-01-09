require "mixlib/cli"
require "yaml"

module OpenGeoDb
  class CLI
    include Mixlib::CLI

    DEFAULT_CONFIG = {"open_geo_db" =>
        {"database" => "open_geo_db", "username" => "root", "password" => ""}}

    def self.action_option(name, description)
      option(name, :short => "-#{name.to_s[0].chr} config", :long => "--#{name} CONFIG",
          :description => description)
    end

    action_option(:create, "Create database with config file CONFIG")
    action_option(:destroy, "Destroy database with config file CONFIG")
    action_option(:generate, "Generate config file CONFIG")

    option(:help, :boolean => true, :on => :tail, :short => "-h", :long => "--help",
        :description => "Show this message", :show_options => true, :exit => 0)

    def run
      parse_options
      send(config.keys.first)
    end

    private

    def load_config
      config_file = config.values.first
      puts("Using config file #{config_file}")
      yaml = YAML.load_file(config_file)["open_geo_db"]
      @database = yaml["database"]
      @username = yaml["username"]
      @password = "-p#{yaml["password"]}" if yaml["password"] and yaml["password"].any?
    end

    def create
      load_config
      sh("mysqladmin -u#{@username} #{@password} create #{@database}")
      %w(opengeodb-begin DE DEhier AT AThier CH CHhier opengeodb-end).each do |basename|
        file = File.join(File.dirname(__FILE__), %w(.. .. vendor sql), "#{basename}.sql")
        sh("mysql -u#{@username} #{@password} #{@database} < #{file}")
      end
    end

    def destroy
      load_config
      sh("mysqladmin -u#{@username} #{@password} drop -f #{@database}")
    end

    def generate
      config_file = config.values.first
      puts("Writing config to #{config_file}")
      File.open(config_file, "w") { |f| f.write(DEFAULT_CONFIG.to_yaml) }
    end

    def sh(command)
      puts(command)
      %x{#{command}}
    end
  end
end
