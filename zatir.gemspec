# frozen_string_literal: true

require 'rake'

require_relative 'lib/zatir/version'

Gem::Specification.new do |spec|
  spec.add_development_dependency('minitest', '~> 5.14.0')
  spec.add_development_dependency('rdoc', '~> 6.3.0')
  spec.add_development_dependency('rubocop', '~> 1.9.0')
  spec.add_runtime_dependency('systemu', '~> 2.6.0')
  spec.authors = ['Markus Prasser', 'Vassilis Rizopoulos']
  spec.email = 'markuspg@users.noreply.github.com'
  spec.files = Dir.glob('lib/**/*.rb')
  spec.files += Dir.glob('test/**/*')
  spec.files += ['LICENSE.txt', 'README.md']
  spec.homepage = 'https://github.com/markuspg/zatir'
  spec.license = 'MIT'
  spec.name = 'Zatir'
  spec.required_ruby_version = '~> 2.5'
  spec.summary = 'Zatir (Zühlke Project Automation Tools in Ruby) provides' \
    ' libraries for use in project automation tools'
  spec.version = Zatir::Version::STRING
end
