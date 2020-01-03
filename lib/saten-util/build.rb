module Build

  # Instance Variables
  # @config
  # @targets
  #
  

  BUILD_CONF_FILENAME = 'saten-util-build-conf.yaml'

  def Build.run
    @config = SaturnEngineUtilities.load_config(BUILD_CONF_FILENAME)
    @targets = @config[:platform]
    @targets.push 'all'
    @targets.push 'clean'
    SaturnEngineUtilities.check_command(@targets, ARGV[1])
  end

end
