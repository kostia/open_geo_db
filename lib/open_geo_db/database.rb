module OpenGeoDb
  class Database
    class UnknownActionError < ArgumentError
    end

    def initialize(config)
      @database = config["database"]
      @username = config["username"]
      @password = "-p#{config["password"]}" if config["password"] and config["password"].any?
    end

    def execute(action)
      case action
      when :create then create
      when :destroy then destroy
      else
        raise UnknownActionError, action
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
