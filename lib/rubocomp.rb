# frozen_string_literal: true

require "awesome_print"
require "fileutils"
require "yaml"
require "active_support/all"
require_relative "rubocomp/version"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Rubocomp
  class Error < StandardError; end
  # Your code goes here...
end
