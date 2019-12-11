require 'yaml'
module SaturnEngineUtilities
    
    @config = Hash.new
    @commands = ['scene', 'resource', 'build' ]

    CONF_FILENAME = 'saten-util-conf.yaml'

    def SaturnEngineUtilities.main
      # Initializations
      check_command
      load_config
      case ARGV[0]
      when 'scene'
        Scene.run
      when 'resource'
        Resource.run
      when 'build'
        Build.run
      end
    end

    def SaturnEngineUtilities.quit
      puts "abort"
      exit
    end

    def SaturnEngineUtilities.check_command
      if ARGV.empty? || !(@commands.include?(ARGV[0]))
        puts "  Missing or invalid command. Legal commands:"
        @commands.each do |c|
          p c
        end
      end
    end

    def SaturnEngineUtilities.load_config
      if File.exists?(CONF_FILENAME)
        begin
          file = File.open(CONF_FILENAME, 'r')
          @config =  YAML.load(file)
          file.close
        rescue StandardError
          puts "Failed to load config file."
          quit
        end
      else
        puts "  File '#{CONF_FILENAME}' not found. Please run this program"\
          " from a Saturn Engine project directory and make sure the"\
          " file exists inside of it."
        quit
      end
    end

  # Load utilities
  require 'saten-util/scene.rb'
  require 'saten-util/resource.rb'
  require 'saten-util/build.rb'

end

