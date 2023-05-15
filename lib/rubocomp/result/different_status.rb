module Rubocomp
  module Result
    class DifferentStatus < Base
      attr_accessor :enabled, :disabled

      def initialize(cop_name, enabled: [], disabled: [])
        super(cop_name)
        @enabled = enabled
        @disabled = disabled
      end

      def identical? = false

      def enabled_names = enabled.map { _1.name }

      def disabled_names = disabled.map { _1.name }

      def to_h
        {cop_name => {enabled: enabled, disabled: disabled}}
      end
    end
  end
end
