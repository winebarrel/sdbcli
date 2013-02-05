Gem::Specification.new do |spec|
  spec.name              = 'sdbcli'
  spec.version           = '1.4.7'
  spec.summary           = 'sdbcli is an interactive command-line client of Amazon SimpleDB.'
  spec.require_paths     = %w(lib)
  spec.files             = %w(README) + Dir.glob('bin/**/*') + Dir.glob('lib/**/*')
  spec.author            = 'winebarrel'
  spec.email             = 'sgwr_dts@yahoo.co.jp'
  spec.homepage          = 'https://bitbucket.org/winebarrel/sdbcli'
  spec.bindir            = 'bin'
  spec.executables << 'sdbcli'
  spec.add_dependency('nokogiri')
  spec.add_dependency('json')
end
