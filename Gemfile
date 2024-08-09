# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "bundler"
# Pinning the fastlane version, as I had an authentication error with the newest version (2.220.0)
# see: https://github.com/fastlane/fastlane/issues/21965
gem "fastlane", '2.219.0'
gem "xcode-install"
gem "xcov", '>=1.7.5'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

