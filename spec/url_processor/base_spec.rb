require 'spec_helper'

describe UrlProcessor::Base do
  let(:config) { UrlProcessor::Config.new }

  describe '.new' do
    it 'can be created' do
      UrlProcessor::Base.new(config)
    end

    it 'throws an error if config is not set' do
      expect { UrlProcessor::Base.new }.to raise_error ArgumentError
    end

    it 'throws an error if config is not of type UrlProcessor::Config' do
      expect { UrlProcessor::Base.new( double('not a valid type') ) }.to raise_error ArgumentError
    end
  end

  describe :attributes do
    it 'sets config' do
      url_processor = UrlProcessor::Base.new(config)
      url_processor.config.should eq config
    end
  end
end