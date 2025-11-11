source "https://rubygems.org"

ruby "3.3.8"

# Rails
gem "rails", "~> 7.1.5"

#use import maps/modern JS tooling
gem "jquery-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# asset pipeline
gem "sprockets-rails"

gem "haml-rails"

group :development, :test do
    gem "sqlite3", ">= 1.4"
end

group :production do
    gem "pg", "~> 1.6"
end

# Server
gem "puma", ">= 5.0"

gem "bcrypt"

gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "bootsnap", require: false

gem "themoviedb"

group :development, :test do
    gem "rspec-rails"
    gem "rails-controller-testing"
    gem "database_cleaner-active_record"
    gem "cucumber-rails", require: false
end

group :development do
    gem "debug", platforms: %i[mri windows]
    gem "web-console"
    gem "guard-rspec"
end

group :test do
    gem "capybara"
    gem "selenium-webdriver"
    gem "simplecov"
end
