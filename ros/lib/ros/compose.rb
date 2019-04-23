# frozen_string_literal: true

require 'bump'

module Ros
  class Compose
    class << self
      attr_accessor :user_envs

      def write_env_file
        f = Tempfile.new
        f.puts("# .env\n# This file was auto generated\n# Compose Variables\n")
        envs.keys.sort.each { |key| f.puts("#{key}=#{envs[key]}") }
        f.close
        FileUtils.mv(f.path, env_file)
      end

      def env_file; @env_file ||= Ros.root.join('.env') end

      def envs
        {
          'COMPOSE_PROJECT_NAME' => Ros.platform.config.compose_project_name,
          'COMPOSE_FILE' => compose_files,
          # TODO: Only set IMAGE_TAG upon build, not just up; so tag defaults to 'latest'
          'IMAGE_TAG' => [version, branch, sha].compact.join('-'),
          'IMAGE_REPOSITORY' => Ros.platform.config.image_repository,
          'RAILS_ENV' => Ros.env,
          # NOTE: When running in 'ros' dir then CONTEXT_DIR is not set or is ..
          'CONTEXT_DIR' => Ros.is_ros? ? '..' : '../ros'
        }.merge(user_envs || {})
      end

      def compose_files
        Ros.platform.config.compose_files.each_with_object([]) do |cfile, ary|
          ary << cfile if File.exists?(cfile)
        end.join(':') 
      end

      def version; Bump::Bump.current end

      def branch
        return @branch if @branch
        return unless system('git rev-parse --git-dir > /dev/null 2>&1')
        @branch = %x(git rev-parse --abbrev-ref HEAD).chomp
      end

      def sha
        return @sha if @sha
        return unless system('git rev-parse --git-dir > /dev/null 2>&1')
        @sha = %x(git rev-parse --short HEAD).chomp
      end
    end
  end
end
