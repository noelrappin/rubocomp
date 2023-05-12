module Rubocomp
  module Result
    class Base
      attr_accessor :cop_name

      def initialize(cop_name)
        @cop_name = cop_name
      end

      def different? = !identical?
    end
  end
end
