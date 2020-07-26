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
    targets.push('all')
    targets.push('clean')
    targets.push('install')
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
    # @cc
    # @src | Array of source file paths

    def initialize(platform,conf)
      @name = conf[:name] + "-#{platform}"
      # Setup cflags
      if platform.include?('-')
        @clean_platform = platform.slice(0...(platform.index('-')))
      else
        @clean_platform = platform
      end
      @platform = platform
      @cflags = ""
      @src = Array.new
      @obj = Array.new
      @config = conf
      @cc = @config[:cc][@clean_platform]
      @config[:include_dir]['all'].each do |idir|
        append_cflags('I', idir)
      end
      @config[:include_dir][@clean_platform].each do |idir|
        append_cflags('I', idir)
      end
      append_sflags(platform)
      append_sflags(ARGV[2]) if ARGV[2]
      # Get source files
      @config[:source_dir].each do |dir|
        unless Dir.exist?(dir)
          puts "Source directory '#{dir}' not found"
          SaturnEngineUtilities.quit
        end
        Dir.mkdir(File.join(dir,'obj')) unless Dir.exist?(File.join(dir,'obj'))
        unless Dir.exist?(File.join(dir, 'obj', platform))
          Dir.mkdir(File.join(dir, 'obj', platform))
        end
        Dir.foreach(dir) do |item|
          path = File.join(dir,item)
          next unless SaturnEngineUtilities.is_file_of_type?(path, '.c')
          @src.push(path.split('/'))
        end
      end
      # Build object files if necessary
      @src.each do |src|
        # Check for corresponding object file
        obj = src.clone
        obj = obj.insert(obj.size-1, 'obj')
        obj = obj.insert(obj.size-1, platform).join('/')
        obj[-1] = 'o'
        @obj.push(obj)
        src = src.join('/')
        if File.exist?(obj)
          p "#{obj} exists, checking for update..."
          objmtime = File.mtime(obj)
          recipe = %x{#{@cc} -M #{src} #{@cflags}}
          recipe.slice!(0..recipe.index(':'))
          recipe.gsub!("\n", '')
          recipe.gsub!("\\", '')
          recipe.squeeze!(" ")
          recipe = recipe[1..-1]
          recipe = recipe.split(" ")
          recipe.each do |dependency|
            if File.mtime(dependency) > objmtime
              p "#{src} has been updated, recompiling obj file..."
              compile(obj, src)
              break
            end
          end
        else
          p "#{obj} does not exist, compiling..."
          compile(obj, src)
        end
        # Compile obj file
      end
      # Link object files
      link(@clean_platform)
    end

    def compile(obj, src)
      command = "#{@cc} -c #{src} -o #{obj} #{@cflags}"
      p command
      %x{#{command}}
    end

    def link(plat)
      command = "#{@cc} -o bin/#{@name}"
      if (plat == "win32" || plat == "win64")
        command << ".exe"
      end
      @obj.each do |o|
        command << " #{o}"
      end
      @config[:lib]['all'].each do |l|
        l.prepend('-') if l[0] == 'l' || l[0] == 'L'
        command << " #{l}"
      end
      @config[:lib][@clean_platform].each do |l|
        l.prepend('-') if l[0] == 'l' || l[0] == 'L'
        command << " #{l}"
      end
      p command
      %x{#{command}}
    end

    def append_cflags(flag,string)
      if string[0] == '`'
        @cflags << "#{string} "
      else
        @cflags << "-#{flag}#{string} "
      end
    end

    def append_sflags(string)
      if @config[:cflag].include?(string)
        @config[:cflag][string].each do |str|
          append_cflags(str[0],str[1..-1])
        end
      end
    end

  end

end
