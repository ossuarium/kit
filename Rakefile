#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'git'

namespace 'develop' do

  test_kit = File.expand_path '../test_kit', __FILE__

  task :prepare do |t|
    puts 'Test kit exists, no need to clone it.' if File.exists? test_kit
    Git.clone 'git://github.com/razor-x/kits_skeleton.git', test_kit unless File.exists? test_kit
  end

  task :update  => [ :prepare ] do |t|
    Git.open(test_kit).pull
  end

  task :reset => [ :prepare, :update ] do |t|
    Git.open(test_kit).reset_hard('master')
  end
end
