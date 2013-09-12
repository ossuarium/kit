#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'git'

namespace 'develop' do

  test_kit = File.expand_path '../test-kit', __FILE__

  desc 'Clones the skeleton kit to test-kit for unit testing.'
  task :prepare do |t|
    if File.exists? test_kit
      puts 'Test kit exists, no need to clone it.'
    else
      Git.clone 'git://github.com/razor-x/skeleton-kit.git', test_kit
    end
  end

  desc 'Updates the test-kit with git pull'
  task :update  => [ :prepare ] do |t|
    Git.open(test_kit).pull
  end

  desc 'Hard reset the test-kit to the last commit'
  task :reset => [ :prepare, :update ] do |t|
    Git.open(test_kit).reset_hard('master')
  end
end
