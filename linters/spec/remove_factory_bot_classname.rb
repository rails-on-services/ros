# frozen_string_literal: true

require 'pry'

module RuboCop
  module Cop
    module Spec
      class RemoveFactoryBotClassname < RuboCop::Cop::Cop
        MSG = 'Exclude FactoryBot classname when creating/building records'
        FACTORY_BOT_METHODS = %i[create build build_stubbed].freeze

        def on_block(node)
          node.each_descendant(:send) do |send_node|
            next unless factory_bot_invoked?(send_node.children[0]) && record_built_or_created?(send_node.children[1])

            add_offense(send_node, location: :expression)
          end
        end

        private

        def factory_bot_invoked?(node)
          node.to_a.include?(:FactoryBot)
        end

        def record_built_or_created?(node)
          FACTORY_BOT_METHODS.include?(node)
        end
      end
    end
  end
end
