# frozen_string_literal: true

# https://perx-tech.postman.co/integrations/services/pm_pro_api/configured?workspace=3e6ef171-dccd-4164-ae0d-cc3abbb43bad
module Postman
  class Workspace
    attr_accessor :id, :name, :comm
    attr_accessor :collections, :environments, :mocks, :monitors #, :workspaces

    def initialize(id: nil, name: nil, comm: nil)
      @id = id
      @name = name
      @comm = comm
    end

    def collection(name)
      col = collections.each.select{ |c| c['name'].eql?(name) }.first || {}
      OpenStruct.new(col.merge(type: :collections))
    end

    def collection_names; collections.map{ |a| a['name'] } end
    def collections; @collections ||= data['collections'] || [] end

    def environment(name)
      col = environments.each.select{ |c| c['name'].eql?(name) }.first || {}
      OpenStruct.new(col.merge(type: :environments))
    end

    def environment_names; environments.map{ |a| a['name'] } end
    def environments; @environments ||= data['environments'] || [] end

    # Convert data to payload format expected by Postman API
    def payload(endpoint, json_data)
      # { endpoint.type.to_s.singularize => JSON.parse(data) }.to_json
      { endpoint.type.to_s.singularize => json_data }.to_json
    end

    # POST to create or PUT to update
    def publish(endpoint, payload)
      comm.endpoint = endpoint.type
      response = endpoint.uid ? comm.update(endpoint.uid, payload) : comm.create(id, payload)
      response.status.eql?(200) ? 'ok' : response.body
    end

    def data
      comm.endpoint = :workspaces
      if name
        payload = comm.index
        json = JSON.parse(payload.body)['workspaces']
        result = json.each.select { |c| c['name'].eql?(name) }.first
        self.id = result['id']
      end
      payload = comm.show(id)
      ws = JSON.parse(payload.body)['workspace']
      self.name ||= ws['description']['name']
      ws
    end
  end
end
