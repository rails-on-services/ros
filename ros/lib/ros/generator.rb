
module Ros
  module Generator
    class << self
      def new(options)
        require_relative 'generator/project.rb'
        project = Project.new(ARGV, options)
        project.execute
      end

      # Initialize all service databases: drop/create/migrate/seed
      def init(options)
        Dir["./**/config/application.rb"].each do |path|
          apath = path.split('/')
          service = apath[1].eql?('ros') ? apath[2].gsub('ros-', '') : apath[1]
          next if %w(sdk core).include? service
          binding.pry
          prefix = path.include?('dummy') ? 'app:' : ''
          %x(docker-compose exec #{service} bundle exec rails #{prefix}ros:db:reset #{prefix}ros:#{service}:db:seed)
        end
      end

      def lpass(options)
        binding.pry
        lpass_name = "#{File.basename(Dir.pwd)}/development"
        unless action = ARGV.shift and %w(add show edit).include? action
          STDOUT.puts "invliad action #{action}. valid actions are: add, show, edit"
          return
        end
        %x(lpass login #{options.lpass}) if options.login
        %x(lpass add --non-interactive --notes #{lpass_name} < app.env)
      end


      def generate(options)
        unless artifact = ARGV.shift
          puts 'generate what?'
          return
        end
        unless artifact = valid_types.select { |a| a[0].eql? artifact[0] }.first
          puts "Invalid type '#{artifact}'. Valid types are: #{valid_types.join(', ')}"
          return
        end
        require_relative "generator/#{artifact}.rb"
        service = Object.const_get("Ros::Generator::#{artifact.capitalize}").new(ARGV, options)
        service.execute
      end

      def valid_types; %w(service env) end
    end
  end
end
