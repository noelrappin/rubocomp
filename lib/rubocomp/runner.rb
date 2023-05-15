module Rubocomp
  class Runner
    def execute(args)
      configurations = args.map { |arg| Configuration.new(arg) }
      configurations.each(&:init_configuration)
      comparator = Comparator.new(*configurations)
      results = comparator.compare
      results = results.select { |result| result.different? }
      puts YAML.dump(results.map(&:to_h))
    end
  end
end
