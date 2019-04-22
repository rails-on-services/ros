# frozen_string_literal: true

module Ros
  class Exec
    def execute(task)
      Ros.services.each do |service, values|
        string = exec_string(values, task)
        prefix = docker? ? "docker-compose #{docker_string} #{values.name} " : ''
        full_string = "#{prefix}bundle exec rails #{string}"
        STDOUT.puts "Running #{full_string} on #{values.name}"
        if docker?
          system(full_string)
        else
          Dir.chdir(values.root.to_s) { system(full_string) }
        end
      end
    end

    def docker?; ARGV.include?('-d') end
    def docker_string; ARGV.include?('-r') ? 'run' : 'exec' end

    def exec_string(values, task)
      "#{values.engine ? 'app:' : ''}ros:#{task}" #" #{values[:prefix]}ros:#{values[:name]}:db:seed"
    end
  end
end
