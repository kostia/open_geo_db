require "yaml"
require "mixlib/cli"
require "open_geo_db/database"

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
      action = config.keys.first
      @config_file = config.values.first
      if action == :generate
        generate
      else
        puts("Using config file #{@config_file}")
        database = OpenGeoDb::Database.new(YAML.load_file(@config_file)["open_geo_db"])
        database.execute(action)
      end
    end

    private

    def generate
      @config_file = config.values.first
      puts("Writing config to #{@config_file}")
      File.open(@config_file, "w") { |f| f.write(DEFAULT_CONFIG.to_yaml) }
    end
  end
end
