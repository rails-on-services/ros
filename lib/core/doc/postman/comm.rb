# frozen_string_literal: true

module Postman
  class Comm
    attr_accessor :base_url, :api_key, :endpoint

    def initialize(base_url: 'https://api.getpostman.com', endpoint: nil, api_key: Settings.postman.api_key)
      @base_url = base_url
      @api_key = api_key
      self.endpoint = endpoint if endpoint
    end

    def index
      conn.get(endpoint_url)
    end

    def show(uid)
      conn.get("#{endpoint_url}/#{uid}")
    end

    def create(workspace_id, data)
      conn.post("#{endpoint_url}/?workspace=#{workspace_id}", data)
    end

    def update(uid, data)
      conn.put("#{endpoint_url}/#{uid}", data)
    end

    def delete(uid)
      conn.delete("#{endpoint_url}/#{uid}")
    end

    def conn
      @conn ||= Faraday.new do |f|
        f.headers['X-Api-Key'] = api_key
        f.headers['Content-Type'] = 'application/json'
        f.adapter(Faraday.default_adapter) # make requests with Net::HTTP
      end
    end

    def endpoint_url
      "#{base_url}/#{endpoint}"
    end

    def endpoint=(ep)
      raise ArgumentError, "Invalid endpoint. Valid endpoints are #{valid_endpoints.join(', ')}" unless valid_endpoints.include? ep.to_s

      @endpoint = ep.to_s
    end

    def valid_endpoints
      %w(collections environments mocks monitors workspaces)
    end
  end
end
