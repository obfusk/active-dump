require File.expand_path('../lib/active-dump/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'active-dump'
  s.homepage    = 'https://github.com/obfusk/active-dump'
  s.summary     = 'dump and restore activerecord from/to yaml'

  s.description = <<-END.gsub(/^ {4}/, '')
    dump and restore activerecord from/to yaml

    ...
  END

  s.version     = ActiveDump::VERSION
  s.date        = ActiveDump::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ GPLv2 EPLv1 }

  s.files       = %w{ .yardopts README.md Rakefile } \
                + %w{ active-dump.gemspec } \
                + Dir['{lib,spec}/**/*.rb']

  s.add_runtime_dependency 'activerecord'
  s.add_runtime_dependency 'rake'

  s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
