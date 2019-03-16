# frozen_string_literal: true

require 'active_record'

module Ros
  module Migrations
    module Create
      module Tenant
        def change
          create_table :tenants do |t|
            t.string :schema_name, null: false, index: { unique: true }

            t.timestamps null: false
          end
        end
      end
    end
  end
end
