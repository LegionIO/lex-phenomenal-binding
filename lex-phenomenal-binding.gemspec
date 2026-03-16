# frozen_string_literal: true

require_relative 'lib/legion/extensions/phenomenal_binding/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-phenomenal-binding'
  spec.version       = Legion::Extensions::PhenomenalBinding::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Phenomenal Binding'
  spec.description   = 'Phenomenal binding engine for LegionIO — unifies disparate cognitive streams into coherent conscious experience'
  spec.homepage      = 'https://github.com/LegionIO/lex-phenomenal-binding'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-phenomenal-binding'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-phenomenal-binding'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-phenomenal-binding'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-phenomenal-binding/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-phenomenal-binding.gemspec Gemfile LICENSE README.md]
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
