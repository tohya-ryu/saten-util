module Resource
  
  # Instance Variables
  # @tmp | Hash
  # @rcnt | Int
  # @text_dir | String
  # @img_dir | String
  # @bgm_dir | String
  # @sfx_dir | String
  # @prefix | String
  # @macro

  @commands = ['update']

  RESOURCE_HEADER = "include/saturn_engine/config/build/resource.h"
  RESOURCE_TABLE  = "data/mrb/saturn_engine/config/resource_table.txt"

  @prefix    = SaturnEngineUtilities.conf[:res_macro] 

  #MACRO_IMG = "#define #{PREFIX}SPR(x) saten_resource_img(x)"
  #MACRO_SFX = "#define #{PREFIX}SFX(x) saten_resource_sfx(x)"
  #MACRO_BGM = "#define #{PREFIX}BGM(x) saten_resource_bgm(x)"
  #MACRO_TEX = "#define #{PREFIX}TEX(x) saten_resource_text(x)"

  def Resource.run
    @prefix = SaturnEngineUtilities.conf[:res_macro]
    @macro = "#define #{@prefix}(x) saten_resource_fetch(x)"
    # Initializations
    check_command
    case ARGV[1]
    when 'update'
      Resource.update
    end
  end

  def Resource.update
    @tmp=  Hash.new # table of resource id's
    @rcnt = 0
    header = File.open(RESOURCE_HEADER, 'w')
    table  = File.open(RESOURCE_TABLE, 'w')
    header.puts "#ifndef SATURN_ENGINE_CONFIG_BUILD_RESOURCE"
    header.puts "#define SATURN_ENGINE_CONFIG_BUILD_RESOURCE"
    header.puts @macro

    # Scan each resource load file
    Dir.foreach(SaturnEngineUtilities.conf[:res_dir]) do |x| 
      @text_dir = nil
      @img_dir  = nil
      @bgm_dir  = nil
      @sfx_dir  = nil
      path = SaturnEngineUtilities.conf[:res_dir] + x
      next if File.directory?(path)
      next unless File.fnmatch('*.rb', x)
      puts "Scanning #{path}"
      file = File.open(path, 'r')
      file.each_line do |line |
        # Skip comments
        next if line.begins_with?('#')
        if line.include?("Resource::Text.dir")
          a = line.split('"') if line.include?('"')
          a = line.split("'") if line.include?("'")
          @text_dir = a[1]
          @text_dir << "/" unless @text_dir[-1] == '/'
        end
        if line.include?("Resource::Sprite.dir")
          a = line.split('"') if line.include?('"')
          a = line.split("'") if line.include?("'")
          @img_dir = a[1]
          @img_dir << "/" unless @img_dir[-1] == '/'
        end
        if line.include?("Resource::BackgroundMusic.dir")
          a = line.split('"') if line.include?('"')
          a = line.split("'") if line.include?("'")
          @bgm_dir = a[1]
          @bgm_dir << "/" unless @bgm_dir[-1] == '/'
        end
        if line.include?("Resource::SoundEffect.dir")
          a = line.split('"') if line.include?('"')
          a = line.split("'") if line.include?("'")
          @sfx_dir = a[1]
          @sfx_dir << "/" unless @sfx_dir[-1] == '/'
        end
        # Get Resource
        # Sprite
        if line.include?(".load")
          dir = @img_dir if line.include?("Saten::Resource::Sprite")
          dir = @sfx_dir if line.include?("Saten::Resource::SoundEffect")
          dir = @bgm_dir if line.include?("Saten::Resource::BackgroundMusic")
          dir = @text_dir if line.include?("Saten::Resource::Text")
          if dir != @text_dir
            m = line.match(/"(.*)"/)
            rpath = m[1]
            rpath = dir + rpath
            unless @tmp.has_key? (path)
              table_write(table, rpath)
              header_write(header, rpath)
              @rcnt += 1
            end
          else
            m = line.match(/"(.*)"/)
            name = m[1].gsub("-", "_").gsub("/", "_")
            fn = @text_dir + m[1]
            tfile = File.open(fn, 'r')
            rpath = fn.slice(0..(fn.index('.'))-1)
            tfile.each_line do |tline|
              if tline.include?("Resource::Text.from_doc")
                a = tline.split('"') if tline.include?('"')
                a = tline.split("'") if tline.include?("'")
                npath = rpath + '/' + a[1] + '.txt'
                unless @tmp.has_key? (npath)
                  table_write(table, npath)
                  header_write(header, npath)
                  @rcnt += 1
                end
              end
            end
            tfile.close
          end
        end
      end
      file.close
    end
    table.close 
    puts "Wrote to '#{RESOURCE_TABLE}.'"


    header.puts "#endif /* SATURN_ENGINE_CONFIG_BUILD_RESOURCE */"
    header.close
    puts "Wrote to '#{RESOURCE_HEADER}.'"
    puts "finished running saten-util resource update"
 
  end

  def Resource.check_command
    if ARGV[1].nil? || !(@commands.include?(ARGV[1]))
      puts "Missing or invalid command for resource handler. Legal commands:"
      @commands.each do |c|
        p c
      end
      SaturnEngineUtilities.quit
    end
  end

  def Resource.table_write (table, path)
    @tmp[path] = @rcnt
    table.puts "#{path}=#{@rcnt}"
  end

  def Resource.header_write(header, path)
    path = path.slice(5..-1)
    path = path.gsub("-", "_").gsub("/", "_").upcase
    path = path.slice(0..(path.index('.'))-1)
    header.puts "#define #{path} #{@rcnt}"
  end

end
