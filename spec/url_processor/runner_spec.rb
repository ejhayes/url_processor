require 'spec_helper'

describe UrlProcessor::Runner do
  let(:config) { UrlProcessor::Config.new }

  describe ".new" do
    describe :happy do
      it 'can be created' do
        UrlProcessor::Runner.new(config)
      end

      it 'creates a UrlProcessor::Base with the configuration object' do
        UrlProcessor::Base.should_receive(:new).with(config)
        runner = UrlProcessor::Runner.new(config)
      end
    end

    describe :sad do
      it 'raises an error if configuration not provided' do
        expect { UrlProcessor::Runner.new }.to raise_error ArgumentError
      end

      it 'raises an error if configuration is not a UrlProcessor::Config type' do
        invalid_config = double('invalid_config')

        expect { UrlProcessor::Runner.new(invalid_config) }.to raise_error ArgumentError
      end
    end
  end

  describe ".run" do

    it 'can be called' do
      runner = UrlProcessor::Runner.new(config)
      runner.should respond_to :run
    end

    it 'calls the run on the base runner' do
      UrlProcessor::Base.any_instance.should_receive(:run)

      runner = UrlProcessor::Runner.new(config)
      runner.run
    end

  end
  
end