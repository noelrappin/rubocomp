module Rubocomp
  RSpec.describe Comparator, :aggregate_failures do
    let(:configuration_1) { Configuration.new("dir_one") }
    let(:configuration_2) { Configuration.new("dir_two") }
    let(:comparator) { Comparator.new(configuration_1, configuration_2) }

    describe "pair of comparisons" do
      before do
        allow(configuration_1)
          .to receive(:load_configuration)
          .and_return(YAML.load_file("spec/fixtures/configuration_one.yml"))
        allow(configuration_2)
          .to receive(:load_configuration)
          .and_return(YAML.load_file("spec/fixtures/configuration_two.yml"))
      end

      describe "#configurations" do
        before do
          configuration_1.init_configuration
          configuration_2.init_configuration
        end

        it "returns the configurations" do
          expect(comparator.configurations).to eq([configuration_1, configuration_2])
        end

        it "can tell the union of the configurations" do
          expect(comparator.known_cops).to match_array(
            %w[
              Bundler/DuplicatedGem
              Bundler/GemComment
              Bundler/GemFilename
              Bundler/GemVersion
              Rails/BulkChangeTable
            ]
          )
        end
      end

      describe "comparisons" do
        before do
          configuration_1.init_configuration
          configuration_2.init_configuration
        end

        it "can tell that two identical cops are actually identical" do
          expect(comparator.compare_all_at("Bundler/GemComment")).to have(1).result
          result = comparator.compare_all_at("Bundler/GemComment").first
          expect(result).to be_identical
          expect(result).not_to be_different
        end

        it "says that disabled against nonexistant is identical" do
          expect(comparator.compare_all_at("Bundler/GemVersion")).to have(1).result
          result = comparator.compare_all_at("Bundler/GemVersion").first
          expect(result).to be_identical
          expect(result).not_to be_different
        end

        it "says that enabled against nonexistant is different" do
          expect(comparator.compare_all_at("Bundler/DuplicatedGem")).to have(1).result
          result = comparator.compare_all_at("Bundler/DuplicatedGem").first
          expect(result).to be_different
          expect(result).not_to be_identical
        end

        it "can tell that different enable settings gives an enabled result" do
          configuration_2.configuration["Bundler/GemFilename"]["Enabled"] = false
          expect(comparator.compare_all_at("Bundler/GemFilename")).to have(1).result
          result = comparator.compare_all_at("Bundler/GemFilename").first
          expect(result).to be_different
          expect(result).not_to be_identical
          expect(result.cop_name).to eq("Bundler/GemFilename")
          expect(result.enabled).to eq(["dir_one"])
          expect(result.disabled).to eq(["dir_two"])
        end

        it "can tell that different other settings gives a different settings result" do
          configuration_2.configuration["Bundler/GemFilename"]["EnforcedStyle"] = "gems.rb"
          expect(comparator.compare_all_at("Bundler/GemFilename")).to have(1).result
          result = comparator.compare_all_at("Bundler/GemFilename").first
          expect(result).to be_different
          expect(result).not_to be_identical
          expect(result.cop_name).to eq("Bundler/GemFilename")
          expect(result.field).to eq("EnforcedStyle")
          expect(result.settings["Gemfile"].map { _1.dir_name }).to eq(["dir_one"])
          expect(result.settings["gems.rb"].map { _1.dir_name }).to eq(["dir_two"])
        end

        it "does not mind if the setting difference is in an ignored setting" do
          configuration_2.configuration["Bundler/GemFilename"]["Description"] = ["cheese"]
          expect(comparator.compare_all_at("Bundler/GemFilename")).to have(1).result
          result = comparator.compare_all_at("Bundler/GemFilename").first
          expect(result).to be_identical
          expect(result).not_to be_different
        end

        it "allows for multiple results for settings changes" do
          configuration_2.configuration["Bundler/GemFilename"]["EnforcedStyle"] = "gems.rb"
          configuration_2.configuration["Bundler/GemFilename"]["Include"] = ["**/Gemfile"]
          expect(comparator.compare_all_at("Bundler/GemFilename")).to have(2).results
          results = comparator.compare_all_at("Bundler/GemFilename")
          expect(results.all? { _1.different? }).to be_truthy
          expect(results.all? { _1.identical? }).to be_falsey
          expect(results.map { _1.cop_name }).to eq(
            %w[Bundler/GemFilename Bundler/GemFilename]
          )
          expect(results.first.settings["Gemfile"].map { _1.dir_name }).to eq(["dir_one"])
          expect(results.first.settings["gems.rb"].map { _1.dir_name }).to eq(["dir_two"])
          expect(results.second.settings["**/Gemfile,**/gems.rb,**/Gemfile.lock,**/gems.locked"]
            .map { _1.dir_name }).to eq(["dir_one"])
          expect(results.second.settings["**/Gemfile"].map { _1.dir_name }).to eq(["dir_two"])
        end

        it "works when the configuration has a blank element" do
          expect(comparator.compare_all_at("Rails/BulkChangeTable")).to have(1).result
          result = comparator.compare_all_at("Rails/BulkChangeTable").first
          expect(result).to be_identical
        end
      end
    end

    describe "trio of comparisons" do
      let(:configuration_1) { Configuration.new("dir_one") }
      let(:configuration_2) { Configuration.new("dir_two") }
      let(:configuration_3) { Configuration.new("dir_three") }
      let(:comparator) { Comparator.new(configuration_1, configuration_2, configuration_3) }

      before do
        allow(configuration_1)
          .to receive(:load_configuration)
          .and_return(YAML.load_file("spec/fixtures/configuration_one.yml"))
        allow(configuration_2)
          .to receive(:load_configuration)
          .and_return(YAML.load_file("spec/fixtures/configuration_two.yml"))
        allow(configuration_3)
          .to receive(:load_configuration)
          .and_return(YAML.load_file("spec/fixtures/configuration_three.yml"))
        configuration_1.init_configuration
        configuration_2.init_configuration
        configuration_3.init_configuration
      end

      it "can tell that three identical cops are actually identical" do
        expect(comparator.compare_all_at("Bundler/GemComment")).to have(1).result
        result = comparator.compare_all_at("Bundler/GemComment").first
        expect(result).to be_identical
        expect(result).not_to be_different
      end

      it "handles two enabled and one disabled" do
        configuration_2.configuration["Bundler/GemFilename"]["Enabled"] = false
        expect(comparator.compare_all_at("Bundler/GemFilename")).to have(1).result
        result = comparator.compare_all_at("Bundler/GemFilename").first
        expect(result).to be_different
        expect(result).not_to be_identical
      end

      it "handles two enabled with different settings and one disabled" do
        configuration_2.configuration["Bundler/GemFilename"]["Enabled"] = false
        configuration_3.configuration["Bundler/GemFilename"]["EnforcedStyle"] = "gems.rb"
        expect(comparator.compare_all_at("Bundler/GemFilename")).to have(2).results
        results = comparator.compare_all_at("Bundler/GemFilename")
        first = results.first
        expect(first).to be_different
        expect(first.enabled).to eq(%w[dir_one dir_three])
        expect(first.disabled).to eq(["dir_two"])
        second = results.second
        expect(second).to be_different
        expect(second.field).to eq("EnforcedStyle")
        expect(second.settings["Gemfile"].map { _1.dir_name }).to eq(%w[dir_one dir_two])
        expect(second.settings["gems.rb"].map { _1.dir_name }).to eq(["dir_three"])
      end
    end
  end
end
