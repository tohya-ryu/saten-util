module Builder

  # Instance Variables
  # @config
  # @targets
  # @target
  # @cflags
  #
  

  BUILD_CONF_FILENAME = 'saten-util-build-conf.yaml'

  def Builder.run
    @config = SaturnEngineUtilities.load_config(BUILD_CONF_FILENAME)
    targets = @config[:platform].clone
    controllers = @config[:control].clone
    targets.push('all')
    targets.push('clean')
    @config[:control].each do |c|
      targets.push(c)
    end
    ARGV[1..-1].each do |arg|
      SaturnEngineUtilities.check_command(targets, arg)
      case arg
      when 'all'
      @config[:platform].each do |p|
        Builder.build(p)
      end
      when 'clean'
      when 'install'
      else
        Builder.build(arg) if @config[:platform].include?(arg)
        #Builder.control(arg) if controllers.include?(arg)
      end
    end
  end

  def Builder.clean
  end

  def Builder.install
  end

  def Builder.build(platform)
    Build.new(platform, @config)
  end

  class Build

    # Instance Variables
    # @config
    # @cflags
    # @src | Array of source file paths

    def initialize(platform,conf)
      # Setup cflags
      @cflags = ""
      @config = conf
      @config[:include_dir]['all'].each do |idir|
        append_cflags('I', idir)
      end
      @config[:include_dir][platform].each do |idir|
        append_cflags('I', idir)
      end
      append_sflags(platform)
      append_sflags(ARGV[2]) if ARGV[2]
      p @cflags
      # get source files
      @config[:source_dir].each do |dir|
        unless Dir.exist?(dir)
          puts "Source directory '#{dir}' not found"
          SaturnEngineUtilities.quit
        end
        Dir.foreach(dir) do |item|
          path = File.join(dir,item)
          next unless SaturnEngineUtilities.is_file_of_type?(path, '.c')
          p path
        end
      end
      # build obj files if needed
    end

    def append_cflags(flag,string)
      if string[0] == '`'
        @cflags << "#{string} "
      else
        @cflags << "-#{flag}#{string} "
      end
    end

    def append_sflags(string)
      if @config[:sflag].include?(string)
        @config[:sflag][string].each do |str|
          append_cflags('D',str)
        end
      end
    end

  end

end
