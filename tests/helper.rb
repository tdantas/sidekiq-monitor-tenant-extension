$:.unshift File.expand_path('../../app', __FILE__)

require 'minitest/autorun'
require 'minitest/pride'

require 'sidekiq'
require 'sidekiq/web'

ENV['RACK_ENV'] = 'test'
ENV['CONFIG_FILE'] = File.expand_path('../config.yml', __FILE__)

require 'bundler/setup'
Bundler.require :test, :default

require 'boot'
Sidekiq::Test = Minitest::Test
