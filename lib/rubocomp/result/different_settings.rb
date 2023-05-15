module Rubocomp
  module Result
    class DifferentSettings < Base
      attr_accessor :settings, :field

      def initialize(cop_name, field, settings = [])
        super(cop_name)
        @settings = settings
        @field = field
      end

      def identical? = false

      def settings_with_names = settings.transform_values { _1.map(&:name) }

      def to_h
        {cop_name => {field => settings_with_names}}
      end
    end
  end
end
