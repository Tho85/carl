source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.

gem 'cassandra-cql', '~> 1.0.2'

group :development do
  gem "rspec", "~> 2.5.0"
  gem "guard-rspec", "~> 0.5.9"
  gem "bundler", "~> 1.0.0"
  gem "jeweler", "~> 1.6.4"
  gem "rcov", ">= 0"
end

group :development, :linux do
  gem 'rb-inotify'
  gem 'libnotify'
end
