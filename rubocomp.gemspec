# frozen_string_literal: true

require_relative "lib/rubocomp/version"

Gem::Specification.new do |spec|
  spec.name = "rubocomp"
  spec.version = Rubocomp::VERSION
  spec.authors = ["Noel Rappin"]
  spec.email = ["noelrap@hey.com"]

  spec.summary = "Compares multiple Rubocop installations and provides useful output."
  spec.description = "Compares multiple Rubocop installations and provides useful output"
  spec.homepage = "https://github.com/noelrappin/rubocomp"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/noelrappin/rubocomp"
  spec.metadata["changelog_uri"] = "https://github.com/noelrappin/rubocomp/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"

  spec.add_runtime_dependency "zeitwerk"
  spec.add_runtime_dependency "awesome_print"
  spec.add_runtime_dependency "activesupport"
  # spec.add_runtime_dependency "rubocop"
end
