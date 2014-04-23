require 'spec_helper'

describe UrlProcessor do

  describe :gem_attributes do
    it 'should have a version number' do
      UrlProcessor::VERSION.should_not be_nil
    end
  end

  describe '.create' do

    it 'requires a block with a config argument' do
      UrlProcessor::Config.any_instance.stub(:validate!)
      UrlProcessor::Config.any_instance.should_receive(:some_random_call)

      UrlProcessor.create do |config|
        config.some_random_call
      end
    end

    it 'throws an error if a block is not passed' do
      expect { UrlProcessor.create }.to raise_error NoMethodError
    end

    it 'returns a runner' do
      processor = UrlProcessor.create do |config|
        config.stub(:validate!)
      end

      processor.should be_a UrlProcessor::Runner
    end

  end

end
