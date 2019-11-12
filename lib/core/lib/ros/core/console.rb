# frozen_string_literal: true

# Add commands to the Pry command set for all services
# Change the pry cli prompt to display [service][Rails.env][current tenant]
#     "[#{PryRails::Prompt.formatted_env}][#{Apartment::Tenant.current}] " \

# def ab
#   Apartment::Tenant.current
# rescue ActiveRecord::ConnectionNotEstablished
#   'n/a'
# end

if Pry::Prompt.respond_to?(:add)
  desc = "Includes the current Rails environment and project folder name.\n" \
          '[1] [project_name][Rails.env][Apartment::Tenant.current] pry(main)>'
  Pry::Prompt.add 'ros', desc, %w[> *] do |target_self, nest_level, pry, sep|
    "[#{pry.input_ring.size}] [#{Settings.dig(:service, :name)}]" \
      "[#{PryRails::Prompt.formatted_env}][#{Apartment::Tenant.current}] " \
    "#{pry.config.prompt_name}(#{Pry.view_clip(target_self)})" \
    "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
  end

  Pry.config.prompt = Pry::Prompt[:ros][:value]
end

module Ros
  module Console
    module Methods
      # These methods will be available in the Rails console
      def fbc(type, *options)
        options.empty? ? create(type) : create(type, *options)
      end

      def fbp; FactoryBot.definition_file_paths end

      def ct
        Rails.configuration.x.memoized_shortcuts[:ct] ||=
          Tenant.find_by(schema_name: Apartment::Tenant.current)
      end

      class << self
        # TODO: Some commands don't get created b/c the abbreviations are duplicates
        # Implement a strategy that handles this
        # TODO: Some commands step on pry commands, e.g. `up` for User.pluck is `up` in stack navigation
        def load_shortcuts
          return unless Rails.configuration.x.memoized_shortcuts.empty?

          unique_shortcuts = Set.new
          Ros.table_names.each do |table_name|
            klass = table_name.classify.constantize
            name = klass.to_s
            type = name.underscore.to_sym
            cmd = name.scan(/\p{Upper}/).join.downcase
            if unique_shortcuts.add?(cmd)
              define_method(cmd.to_s) { klass }
              define_method("#{cmd}a") { klass.all }
              define_method("#{cmd}c") { fbc(type) }
              define_method("#{cmd}f") { Rails.configuration.x.memoized_shortcuts["#{cmd}f"] ||= klass.first }
              define_method("#{cmd}l") { Rails.configuration.x.memoized_shortcuts["#{cmd}l"] ||= klass.last }
              define_method("#{cmd}p") { |*columns| klass.pluck(*columns) }
              defined_shortcuts[cmd] = name
            else
              undefined_shortcuts[cmd] = name
            end
          end
          reset_shortcuts
          TOPLEVEL_BINDING.eval('self').extend(self)
        # If the database doesn't exist then fail and output a message
        rescue ActiveRecord::NoDatabaseError => e
          STDOUT.puts "WARNING: Error loading model shortcuts: #{e.message}"
        rescue ActiveRecord::StatementInvalid => e
          STDOUT.puts "WARNING: Error loading model shortcuts: #{e.message}"
        end

        def defined_shortcuts; @defined_shortcuts ||= {} end

        def undefined_shortcuts; @undefined_shortcuts ||= {} end

        def reset_shortcuts
          Rails.configuration.x.memoized_shortcuts = {}
          Rails.configuration.x.memoized_shortcuts[:loaded] = true
        end
      end
    end
  end
end

Ros::PryCommandSet = Pry::CommandSet.new
# rubocop:disable Style/ClassAndModuleChildren
module Ros::Console::Commands
  class TenantSelect < Pry::ClassCommand
    match 'select-tenant'
    group 'ros'
    description 'Select Tenant (short-cut alias: "st")'
    banner <<-BANNER
      Usage: select-tenant [id]

      'id' is the numerical id returned from `select-tenant` when no id is passed
      If the id is passed that tenant's schema will become the active schema
      If the id that is passed doesn't exist then the default schema 'public' will become the active schema
    BANNER

    def process(id = nil)
      if id.nil?
        columns = Tenant.column_names.include?('alias') ? %i[id schema_name alias] : %i[id schema_name]
        output.puts Tenant.order(:id).pluck(*columns).each_with_object([]) { |a, ary| ary << a.join(' ') }
        return
      end
      Rails.configuration.x.memoized_shortcuts[:ct]&.clear_credential
      Ros::Console::Methods.reset_shortcuts
      Apartment::Tenant.switch! Tenant.schema_name_for(id: id)
      Rails.configuration.x.memoized_shortcuts[:ct] = Tenant.find_by(schema_name: Apartment::Tenant.current)
      Rails.configuration.x.memoized_shortcuts[:ct]&.set_role_credential
    end

    Ros::PryCommandSet.add_command(self)
  end

  class Reload < Pry::ClassCommand
    match 'reload'
    group 'ros'
    description 'reload rails and reset cached shortcuts (short-cut alias: "r")'

    def process
      Ros::Console::Methods.reset_shortcuts
      TOPLEVEL_BINDING.eval('self').reload!
      Rails.configuration.x.memoized_shortcuts[:ct] = Tenant.find_by(schema_name: Apartment::Tenant.current)
    end

    Ros::PryCommandSet.add_command(self)
  end

  class Infra < Pry::ClassCommand
    match 'ir'
    group 'ros'
    description 'infrastructure resources'

    def process(resource_type = nil, name = nil, *options)
      if resource_type.nil?
        output.puts Ros::Infra.resources.keys
        return
      elsif Ros::Infra.resources[resource_type].nil?
        output.puts 'Unknown resource'
        return
      elsif name.nil?
        output.puts Ros::Infra.resources[resource_type].keys
        return
      end
      resource = Ros::Infra.resources[resource_type][name]
      if options.size == 0
        output.puts resource
      elsif options.size == 1
        output.puts resource.send(options.shift)
      else
        output.puts resource.send(options.shift, options)
      end
    end

    Ros::PryCommandSet.add_command(self)
  end

  class ToggleLogger < Pry::ClassCommand
    match 'toggle-logger'
    group 'ros'
    description 'Toggle the Rails Logger on/off (short-cut alias: "to")'

    def process(state = nil)
      unless state.nil?
        return if ((state == 'off') && ActiveRecord::Base.logger.nil?) ||
                  ((state == 'on') && !ActiveRecord::Base.logger.nil?)
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

  class Shortcuts < Pry::ClassCommand
    match 'show-shortcuts'
    group 'ros'
    description 'Display defined model shortcuts (short-cut alias: "sc")'

    # TODO: Also show undefined shortcuts with a param to #process
    def process
      output.puts 'Model               Class  All     Create  First   Last    Pluck'
      Ros::Console::Methods.defined_shortcuts.sort.to_h.each_pair do |cmd, name|
        buf = ' ' * (7 - cmd.length)
        output.puts "#{name}#{' ' * (20 - name.length)}#{cmd}#{buf}#{cmd}a#{buf}#{cmd}c#{buf}#{cmd}" \
          "f#{buf}#{cmd}l#{buf}#{cmd}p"
      end
    end

    Ros::PryCommandSet.add_command(self)
  end

  # TODO: move to a module/class in core for jobs; namesapced on the queue type
  # class RabbitMQ < Pry::ClassCommand
  #   match 'mq-send'
  #   group 'ros'
  #   description 'send a message on the mq bus'

  #   # TODO: refactor
  #   def process
  #     return unless ENV['AMQP_URL']
  #     record = { bucket: 'test', key: 'path/to/object' }
  #     conn = Bunny.new(ENV['AMQP_URL'])
  #     conn.start
  #     ch = conn.create_channel
  #     puts "#{record[:bucket]}/#{record[:key]}"
  #     puts ENV['AMQP_QUEUE_NAME']
  #     puts record.merge!({ tenant: 'hsbc', environment: 'development' })

  #     res = ch.default_exchange.publish("#{record[:bucket]}/#{record[:key]}",
  #                                       routing_key: ENV['AMQP_QUEUE_NAME'],
  #                                       headers: record.merge({ version: ENV['AMQP_VERSION'].to_s }))

  #     puts 'Here is output from bunny'
  #     puts res
  #     conn.close
  #   end
  # end
end
# rubocop:enable Style/ClassAndModuleChildren

Pry.config.commands.import Ros::PryCommandSet
Pry.config.commands.alias_command 'r', 'reload'
Pry.config.commands.alias_command 'sc', 'show-shortcuts'
Pry.config.commands.alias_command 'st', 'select-tenant'
Pry.config.commands.alias_command 'to', 'toggle-logger'

Pry.hooks.add_hook(:before_session, 'load_shortcuts') do |output, _binding, _pry|
  unless Rails.const_defined?('Server')
    output.puts "\nModel Shortcut Console Commands:"
    Ros::Console::Methods.load_shortcuts
    Ros::Console::Commands::Shortcuts.new(output: output).process
    output.puts "\nType `help ros` for additional console commands"
  end
end

Pry.hooks.add_hook(:after_session, 'thanks') do |output, _binding, _pry|
  if Rails.env.development? && !Rails.const_defined?('Server')
    output.puts 'Thanks for using ros. Documentation at http://guides.rails-on-services.org'
  end
end
