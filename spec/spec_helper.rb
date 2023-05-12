# frozen_string_literal: true

require "rubocomp"

require "simplecov"
SimpleCov.start unless SimpleCov.running

require "rspec/collection_matchers"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.order = :random
  config.filter_gems_from_backtrace "bundler"
  config.default_formatter = "doc" if config.files_to_run.one?
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus
  Kernel.srand config.seed
end
