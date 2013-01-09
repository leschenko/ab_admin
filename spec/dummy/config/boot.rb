require 'rubygems'
$:.unshift File.expand_path('../../../../lib', __FILE__)

gemfile = File.expand_path('../../../../Gemfile', __FILE__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end
