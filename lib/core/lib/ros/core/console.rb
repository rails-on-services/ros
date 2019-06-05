# frozen_string_literal: true

# Add commands to the Pry command set for all services
# Change the pry cli prompt to displace the current tenant
      # "[#{PryRails::Prompt.project_name}][#{PryRails::Prompt.formatted_env}][#{Apartment::Tenant.current}] " \

def ab
  Apartment::Tenant.current
rescue ActiveRecord::ConnectionNotEstablished
  'n/a'
end
#     "[#{PryRails::Prompt.project_name}][#{PryRails::Prompt.formatted_env}][#{ab}] " \

if Pry::Prompt.respond_to?(:add)
  desc = "Includes the current Rails environment and project folder name.\n" \
          "[1] [project_name][Rails.env][Apartment::Tenant.current] pry(main)>"
  Pry::Prompt.add 'ros', desc, %w(> *) do |target_self, nest_level, pry, sep|
    "[#{pry.input_ring.size}] " \
      "[#{Settings.dig(:service, :name)}][#{PryRails::Prompt.formatted_env}][#{ab}] " \
    "#{pry.config.prompt_name}(#{Pry.view_clip(target_self)})" \
    "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
  end

  Pry.config.prompt = Pry::Prompt[:ros][:value]
end

module Ros
  module Console
    module Methods
      def fbc(type, *options)
        try_count ||= 0
        FactoryBot.create(type, options)
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

        def init; end
        def xinit
          es = Set.new
          models.each do |model|
            idx = model.index('/app/models/') + 12
            name = model[idx..-1].gsub('.rb', '')
            next if name.starts_with? 'concerns'
            klass = "#{name.classify}#{name.ends_with?('s') ? 's' : ''}".constantize
            next unless klass.is_a? Class
            next if klass.abstract_class?
            next unless klass.new.is_a? ApplicationRecord
            name.gsub('_', '').split('').each_with_object([]) do |char, ary|
              ary << char
              id = ary.join
              if es.add?(id)
                es.add("#{id}a")
                es.add("#{id}cr")
                es.add("#{id}f")
                es.add("#{id}l")
                es.add("#{id}p")
                define_method("#{id}a") { klass.all }
                # TODO: just using "#{id}c" causes an error. Find out why
                define_method("#{id}cr") { fbc(name) }
                define_method("#{id}f") { Rails.configuration.x.memoized_shortcuts["#{id}f"] ||= klass.first }
                define_method("#{id}l") { Rails.configuration.x.memoized_shortcuts["#{id}l"] ||= klass.last }
                define_method("#{id}p") { |*columns| klass.pluck(columns) }
                break
              end
            end
          end
        rescue ActiveRecord::NoDatabaseError => e
          # If the database doesn't exist then just fail silently
        rescue ActiveRecord::StatementInvalid => e
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

=begin
  # TODO: move to a module/class in core for jobs; namesapced on the queue type
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
=end

  class ToggleLogger < Pry::ClassCommand
    match 'toggle-logger'
    group 'ros'
    description 'Toggle the Rails Logger on/off'

    def process(state = nil)
      unless state.nil?
        return if (state == 'off' and ActiveRecord::Base.logger.nil?) or (state == 'on' and not ActiveRecord::Base.logger.nil?)
      end
      swap_logger(ActiveRecord::Base)
      swap_logger(ActiveJob::Base)
    end

    def swap_logger(mod)
      logger_instance = mod.logger
      mod.logger = Rails.configuration.x.loggers[mod.name]
      Rails.configuration.x.loggers[mod.name] = logger_instance
    end

    Ros::PryCommandSet.add_command(self)
  end
end

Pry.config.commands.import Ros::PryCommandSet
Pry.config.commands.alias_command 'r', 'reload'
Pry.config.commands.alias_command 'st', 'select-tenant'
Pry.config.commands.alias_command 'to', 'toggle-logger'
