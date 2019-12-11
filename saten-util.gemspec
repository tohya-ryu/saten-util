Gem::Specification.new do |s|
  s.name = 'saten-util'
  s.version = '0.0.0'
  s.executables << 'saten-util'
  s.date = '2019-12-11'
  s.summary = 'Utilities to assist in developing with Saturn Engine'
  s.description = 'Command line utilities to assist in developing with Saturn'\
    ' Engine.'
  s.authors = ["tohya ryu"]
  s.email = 'ryu@tohya.net'
  s.files = ["lib/saten-util.rb",
             "lib/saten-util/scene.rb",
             "lib/saten-util/resource.rb",
             "lib/saten-util/build.rb"]
  s.homepage = 'https://github.com/tohya-ryu/saten-util'
  s.license = 'MIT'
end
