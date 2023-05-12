module Rubocomp
  class Comparator
    attr_accessor :configurations

    def initialize(*configurations)
      @configurations = configurations
    end

    def known_cops
      configurations.map(&:configuration).map(&:keys).flatten.uniq
    end

    def compare
      known_cops.map { |cop| compare_all_at(cop) }.flatten
    end

    def compare_all_at(cop)
      PartialComparator.new(cop, configurations).compare
    end
  end
end
