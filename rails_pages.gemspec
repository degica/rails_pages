# frozen_string_literal: true

require_relative 'lib/rails_pages/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_pages'
  spec.version       = RailsPages::VERSION
  spec.authors       = ['Nigel Baillie']
  spec.email         = ['metreckk@gmail.com']

  spec.summary       = 'Opinionated solution for using Vue in a Rails app'
  spec.description   = <<~DESC
    RailsPages lets you define "Pages" as VueJS v3 components with a lean Ruby
    file for pulling data from your back-end.

    It's not a full SPA system, but should be easy to drop into your existing
    Rails+Webpacker monolith.

    Each "Page" can be listed and queried like a record in the database,
    allowing you to easily generate navigation components like sidebars and
    breadcrumbs based on your own directory conventions instead of hand-written
    lists of links.
  DESC
  spec.homepage      = 'https://github.com/degica/rails_pages'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 6.0'
  spec.add_development_dependency 'webpacker', '~> 5.2.1'
end
