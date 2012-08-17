Gem::Specification.new do |spec|
  spec.name              = 'sdbcli'
  spec.version           = '0.2.1'
  spec.summary           = 'sdbcli is an interactive command-line client of Amazon SimpleDB.'
  spec.require_paths     = %w(lib)
  spec.files             = %w(README) + Dir.glob('bin/**/*') + Dir.glob('lib/**/*')
  spec.author            = 'winebarrel'
  spec.email             = 'sgwr_dts@yahoo.co.jp'
  spec.homepage          = 'https://bitbucket.org/winebarrel/sdbcli'
  spec.bindir            = 'bin'
  spec.executables << 'sdbcli'
  spec.add_dependency('nokogiri')
end
