module Rubocomp
  RSpec.describe Configuration do
    let(:configuration) { Configuration.new("dir_one") }

    before do
      allow(configuration)
        .to receive(:load_configuration)
        .and_return(YAML.load_file("spec/fixtures/configuration_one.yml"))
    end

    it "can return enabled status for a cop" do
      configuration.init_configuration
      expect(configuration.enabled_at?("Bundler/DuplicatedGem")).to be_truthy
      expect(configuration.enabled_at?("Bundler/GemComment")).to be_falsey
    end
  end
end
