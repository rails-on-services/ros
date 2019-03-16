# frozen_string_literal: true

# Add commands to the Pry command set for all services
# Change the pry cli prompt to displace the current tenant
      # "[#{PryRails::Prompt.project_name}][#{PryRails::Prompt.formatted_env}][#{Apartment::Tenant.current}] " \

def ab
  Apartment::Tenant.current
rescue ActiveRecord::ConnectionNotEstablished
  'n/a'
end

if Pry::Prompt.respond_to?(:add)
  desc = "Includes the current Rails environment and project folder name.\n" \
          "[1] [project_name][Rails.env][Apartment::Tenant.current] pry(main)>"
  Pry::Prompt.add 'ros', desc, %w(> *) do |target_self, nest_level, pry, sep|
    "[#{pry.input_ring.size}] " \
      "[#{PryRails::Prompt.project_name}][#{PryRails::Prompt.formatted_env}][#{ab}] " \
    "#{pry.config.prompt_name}(#{Pry.view_clip(target_self)})" \
    "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
  end

  Pry.config.prompt = Pry::Prompt[:ros][:value]
end

module Ros
  module Console
    module Methods
      def fbc(type)
        try_count ||= 0
        FactoryBot.create(type)
      rescue KeyError
        try_count += 1
        Ros::Console::Methods.factories.each { |f| require f }
        retry if try_count < 2
      end

      class << self
        def factories
          Ros.config.factory_paths.each_with_object([]) do |path, ary|
            ary << Dir[Pathname.new(path).join('**', '*.rb')]
          end.flatten
        end

        def models
          Ros.config.model_paths.each_with_object([]) do |path, ary|
            ary << Dir[Pathname.new(path).join('**', '*.rb')]
          end.flatten
        end unless Ros::Console::Methods.methods.include? :models

        def init
          models.each do |model|
            next if model.include? '/concerns/'
            name = File.basename(model).gsub('.rb', '')
            next if name.eql?('application_record') || name.ends_with?('join')
            id = name.split('_').map{ |m| m[0] }.join
            define_method("#{id}a") { name.classify.constantize.all }
            define_method("#{id}c") { fbc(name) }
            define_method("#{id}f") { Rails.configuration.x.memoized_shortcuts["#{id}f"] ||= name.classify.constantize.first }
            define_method("#{id}l") { Rails.configuration.x.memoized_shortcuts["#{id}l"] ||= name.classify.constantize.last }
            define_method("#{id}p") { |column| name.classify.constantize.pluck(column) }
          end
        end
      end

      def ct; Rails.configuration.x.memoized_shortcuts[:ct] ||= Tenant.find_by(schema_name: Apartment::Tenant.current) end
    end
  end
end

Ros::PryCommandSet = Pry::CommandSet.new

module Ros::Console::Commands
  class TenantSelect < Pry::ClassCommand
    match 'select-tenant'
    group 'ros'
    description 'Select Tenant'
    banner <<-BANNER
      Usage: select-tenant [id]

      'id' is the numerical id returned from `select-tenant` when no id is passed
      If the id is passed that tenant's schema will become the active schema
      If the id that is passed doesn't exist then the default schema 'public' will become the active schema
    BANNER

    def process(id = nil)
      if id.nil?
        # NOTE: This is dumb, but passing an array of field names to #pluck results in a noisy DEPRECATION WARNING
        if Tenant.column_names.include? 'name'
          output.puts Tenant.order(:id).pluck(:id, :schema_name, :name).each_with_object([]) { |a, ary| ary << a.join(' ') }
        else
          output.puts Tenant.order(:id).pluck(:id, :schema_name).each_with_object([]) { |a, ary| ary << a.join(' ') }
        end
        return
      end
      Apartment::Tenant.switch! Tenant.schema_name_for(id: id)
      Rails.configuration.x.memoized_shortcuts = {}
    end

    Ros::PryCommandSet.add_command(self)
  end

  class Reload < Pry::ClassCommand
    match 'reload'
    group 'ros'
    description 'reload rails and reset memoized'

    def process
      Rails.configuration.x.memoized_shortcuts = {}
      TOPLEVEL_BINDING.eval('self').reload!
    end

    Ros::PryCommandSet.add_command(self)
  end

  class RabbitMQ < Pry::ClassCommand
    match 'mq-send'
    group 'ros'
    description 'send a message on the mq bus'

    # TODO: refactor
    def process
      return unless ENV['AMQP_URL']
      record = { bucket: 'test', key: 'path/to/object' }
      conn = Bunny.new(ENV['AMQP_URL'])
      conn.start
      ch = conn.create_channel
      puts "#{record[:bucket]}/#{record[:key]}"
      puts ENV['AMQP_QUEUE_NAME']
      puts record.merge!({ tenant: 'hsbc', environment: 'development' })

      res = ch.default_exchange.publish("#{record[:bucket]}/#{record[:key]}",
                                        routing_key: ENV['AMQP_QUEUE_NAME'],
                                        headers: record.merge({ version: ENV['AMQP_VERSION'].to_s }))

      puts 'Here is output from bunny'
      puts res
      conn.close
    end
  end

  class ToggleLogger < Pry::ClassCommand
    match 'toggle-logger'
    group 'ros'
    description 'Toggle the Rails Logger on/off'

    def process(state = nil)
      unless state.nil?
        return if (state == 'off' and ActiveRecord::Base.logger.nil?) or (state == 'on' and not ActiveRecord::Base.logger.nil?)
      end
      if ActiveRecord::Base.logger.nil?
        ActiveRecord::Base.logger = Rails.configuration.x.old_logger
      else
        Rails.configuration.x.old_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
      end
    end

    Ros::PryCommandSet.add_command(self)
  end
end

Pry.config.commands.import Ros::PryCommandSet
Pry.config.commands.alias_command 'r', 'reload'
Pry.config.commands.alias_command 'st', 'select-tenant'
Pry.config.commands.alias_command 'to', 'toggle-logger'
