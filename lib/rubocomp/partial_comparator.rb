module Rubocomp
  class PartialComparator
    attr_reader :cop, :configurations, :enabled, :disabled

    IGNORED_FIELDS = %w[
      Description
      Enabled
      StyleGuide
      VersionAdded
      VersionChanged
      Safe
      SafeAutoCorrect
      SupportedStyles
      Exclude
    ]

    def initialize(cop, configurations)
      @cop = cop
      @configurations = configurations
      @enabled = []
      @disabled = []
    end

    def partition_enabled
      @enabled, @disabled = configurations.partition { _1.enabled_at?(cop) }
    end

    def reference_config
      configurations.find { _1.configuration.key?(cop) }&.cop_at(cop) || {}
    end

    def reference_keys
      reference_config.keys - IGNORED_FIELDS
    end

    def compare_settings
      return [] if enabled.empty?
      reference_keys.map do |field|
        settings = configurations
          .map { _1.setting_at(cop, field) }
          .uniq
          .compact
        next if settings.size == 1
        Result::DifferentSettings.new(
          cop,
          field,
          configurations.group_by { _1.setting_at(cop, field) }
            .transform_keys { Array(_1).join(",") }
        )
      end.compact
    end

    def compare_status
      return Result::Identical.new(cop) if enabled.empty? || disabled.empty?
      Result::DifferentStatus.new(
        cop,
        enabled: enabled.map(&:name),
        disabled: disabled.map(&:name)
      )
    end

    def compare
      partition_enabled
      settings_result = compare_settings
      status_result = compare_status
      if status_result.identical? && settings_result.present?
        return settings_result
      end
      [status_result, settings_result].flatten
    end
  end
end
