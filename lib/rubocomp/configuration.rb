module Rubocomp
  class Configuration
    attr_reader :configuration, :dir_name

    def initialize(dir_name)
      @dir_name = dir_name
      @configuration = {}
    end

    def name = dir_name.split("/").last

    def load_configuration
      yaml_config = `cd #{dirname} && rubocop --show-cops --format yaml`
      YAML.safe_load(yaml_config, permitted_classes: [Regexp, Symbol])
    end

    def init_configuration
      @configuration = load_configuration
    end

    def cop_at(name)
      configuration[name]
    end

    def enabled_at?(name)
      return false unless cop_at(name)
      cop_at(name)["Enabled"]
    end

    def setting_at(cop, setting)
      return nil unless cop_at(cop)
      cop_at(cop)[setting]
    end
  end
end
