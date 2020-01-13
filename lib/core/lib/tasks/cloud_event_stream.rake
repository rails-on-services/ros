# frozen_string_literal: true

namespace :ros do
  namespace :cloud_event_stream do
    desc 'backfill active records of each TENANTS from a SERVICE'
    task :backfill, %i[timestamp] => :environment do |_task, args|
      next unless Settings.event_logging.enabled

      ApplicationRecord.descendants.each do |model|
        Rake::Task['ros:cloud_event_stream:backfill_a_model'].invoke(model, args[:timestamp])
      end
    end

    task :backfill_a_model, %i[model timestamp] => :environment do |_task, args|
      next unless Settings.event_logging.enabled

      model = args[:model].to_s.classify.constantize
      timestamp = Time.zone.parse(args[:timestamp] || '0000-01-01')
      type = "#{Settings.service_name}.#{model.name.underscore.downcase}"
      Tenant.all.each do |t|
        next if t.schema_name == 'public'

        Apartment::Tenant.switch(t.schema_name) do
          model.where('updated_at >= ?', timestamp).each do |record|
            Ros::CloudEventStreamJob.perform_now(type: type, message_id: record.id, data: record.cloud_event_data)
          end
        end
      end
    end
  end
end
