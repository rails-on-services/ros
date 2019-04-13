# frozen_string_literal: true

module Postman
  class OpenApi
    attr_accessor :file_name, :openapi_dir, :postman_dir

    def initialize(file_name: nil, openapi_dir: nil, postman_dir: nil)
      @file_name = file_name
      @openapi_dir = openapi_dir
      @postman_dir = postman_dir
    end

    def source; "#{openapi_dir}/#{file_name}" end
    def target; "#{postman_dir}/#{file_name}" end

    def convert_to_postman
      raise raise FileNotFoundException.new('File not found') unless File.exists?(source)
      FileUtils.mkdir_p(postman_dir)
      `openapi2postmanv2 -p -s #{source} -o #{target}`
    end

    def data
      @data ||= File.read(target)
    end
  end
end
