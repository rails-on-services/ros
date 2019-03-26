#!/usr/bin/env ruby

require 'ostruct'
require 'optparse'

# What actions are useful and therefore what options will be useful here?
# Actions
# generate a new ros engine using specific settings passed to 'rails new' including the location of the template
# generate a new ros based project, e.g. for perx, so this is the docker-compose files, Dockerfile, nginx, etc, does a git clone of ros repo
# when a new project is added, e.g. survey, then update nginx-services.conf, init script, docker-compose, etc
# this could take over the init thing so it could be 'ros init project|--all'
 
# NOTE: This is a lightweight thing that manages the repetitive things in the project that apply to all services and/or projects

module Ros
module Cli
  class OptionsParser
    def parse
      options = OpenStruct.new
      if File.exists?('app.env')
        banner = 'ros init|lpass|generate service|env [options]'
      else
        banner = 'ros new AAP_PATH [options]'
      end
                    
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage:\n  #{banner}\n\nOptions:"

        opts.on( '--version', '# Display the version and exit' ) do
          STDOUT.puts '0.1.0'
          exit
        end

        opts.on( '--login=USER', '# Login to lastpass to sync a secure note to project secrets (app.env)' ) do |user|
          options.lpass = user
        end

        opts.on( '--dev', '# Setup the project with ros development repository' ) do
          options.dev = true
        end

        opts.on('-h', '--help', '# Display this screen') do
          if File.exists?('app.env')
            puts opts
          # TODO: If Dir.pwd is a prepd project then putput the 'runtime' commands here
          # Otherwise output the 'prepd new --help' is appropriate
          else
            puts opts
            puts "\nExample:\n   ros new ~/my/new/project\n"
            puts "\n   This generates a skeletal ros installation in ~/my/new/project"
          end
          exit
        end

        opts.on('-v', '--verbose', '# Display additional information') do
          options.verbose = true
        end

        # opts.on( '-m', '--machine', '# Create a new virtual machine' ) do |value|
        #   options.create_type = :machine
        # end

        # opts.on('-n', '--no-op', '# Show what would happen but do not execute') do
        #   options.no_op = true
        #   options.verbose = true
        # end

        # opts.on( '-p', '--project', '# Create a new project' ) do |value|
        #   options.create_type = :project
        # end

        # opts.on('--yes', '# Automatically say yes') do
        #   options.yes = true
        # end
      end
      optparse.parse!
      options.to_h
    end
  end
end
end
