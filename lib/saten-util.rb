require 'yaml'

class String
  def begins_with?(x)
    test = self.lstrip
    test[0] == x
  end
end

module SaturnEngineUtilities
    
    COMMANDS = ['scene', 's', 'resource', 'r', 'build', 'b']

    def SaturnEngineUtilities.main
      # Initializations
      check_command(COMMANDS, ARGV[0])
      case ARGV[0]
      when 'scene', 's'
        Scene.run
      when 'resource', 'r'
        Resource.run
      when 'build', 'b'
        Build.run
      end
    end

    def SaturnEngineUtilities.quit
      puts "abort"
      exit
    end

    def SaturnEngineUtilities.check_command(list, cmd)
      if cmd.nil? || !(list.include?(cmd))
        puts "Missing or invalid command. Legal commands:"
        list.each do |c|
          p c
        end
        quit
      end
    end

    def SaturnEngineUtilities.load_config(fn)
      yaml = Hash.new
      if File.exists?(fn)
        begin
          file = File.open(fn, 'r')
          #@config =  YAML.load_stream(file)
          yaml =  YAML.load(file)
          file.close
        rescue StandardError
          puts "Failed to load config file."
          quit
        end
      else
        puts "File '#{fn}' not found. Please run this program"\
          " from a Saturn Engine project directory and make sure the"\
          " file exists inside of it."
        quit
      end
      yaml
    end

  # Load utilities
  require 'saten-util/scene.rb'
  require 'saten-util/resource.rb'
  require 'saten-util/build.rb'

end

