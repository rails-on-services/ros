# frozen_string_literal: true

class ApplicationDoc
  include OpenApi::DSL

   def self.ros_api_dry
   # route_base = try(:controller_path) || instance_variable_get('@route_base')
   #    ::OpenApi::Generator.get_actions_by_route_base(route_base)&.each do |action|
   #      api_dry action do
   #        # Common :index parameters
   #        if action == 'index'
   #          query :created_from, DateTime, desc: 'YY-MM-DD (HH:MM:SS, optional)', as: :start
   #          query :created_to,   DateTime, desc: 'YY-MM-DD (HH:MM:SS, optional)', as: :end
   #          query :search_value, String
   #          query :page, Integer, range: { ge: 1 }, dft: 1
   #          query :rows, Integer, desc: 'per page, number of result', range: { ge: 1 }, dft: 10
   #        end

   #        # Common :show parameters
   #        if action == 'show'
   #          path! :id, Integer
   #        end

   #        # Common :destroy parameters
   #        if action == 'destroy'
   #          path! :id, Integer
   #        end

   #        # Common :update parameters
   #        if action == 'update'
   #          path! :id, Integer
   #        end
	end

end

require_relative 'tenants_doc'
