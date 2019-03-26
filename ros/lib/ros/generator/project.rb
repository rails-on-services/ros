
module Ros
  module Generator
    class Project
      attr_accessor :name, :args, :options

      def initialize(args, options)
        self.name = args.shift
        self.args = args
        self.options = options
      end

      def execute 
        create_project
        Dir.chdir(name) do
          create_files
          ARGV.unshift('env')
          ARGV.unshift(name)
          Ros::Generator.generate(options)
          Ros::Generator.lpass(options) if options.lpass
        end
      end

      def create_project
        dir = Pathname(File.dirname(__FILE__)).join('../../../files/project').to_s
        FileUtils.mkdir_p(name)
        FileUtils.cp_r("#{dir}/.", name)
      end

      def create_files
        %x(git clone https://github.com/rails-on-services/ros.git) if options.dev
        %x(git clone https://github.com/rjayroach/rails-templates.git)
        gsub_file('Dockerfile', 'service', name)
      end

      def gsub_file(file, original, replace)
        text = File.read(file).gsub(original, replace)
        File.open(file, 'w').write(text)
      end
    end
  end
end
