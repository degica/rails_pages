source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in rails_pages.gemspec.
gemspec

group :development do
  gem 'sqlite3'
end

group :test do
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'fakefs', require: 'fakefs/safe'
end

group :development, :test do
  gem 'pry-byebug'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
