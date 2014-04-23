require 'spec_helper'

describe UrlProcessor::Config do
  let(:config) { UrlProcessor::Config.new }

  describe :validation do
    before(:each) do
      config.debug = true
      config.batch_size = 1
      config.max_concurrency = 1
      config.max_retries = 1
      config.cookies_file = 'test'
      config.max_total_connections = 1
      config.max_timeout = 1
      config.log = STDOUT

      config.retrieves_links_by_id_with do |val|
      end

      config.retrieves_all_links_with do
      end

      config.creates_new_link_request_with do |url, params|
      end

      config.processes_response_with do |response|
      end
    end

    it 'is valid' do
      config.validate!
    end

    it 'throws an error if get_link_by_id is not set' do
      config.stub(:get_link_by_id).and_return(nil)
      expect { config.validate! }.to raise_error NotImplementedError
    end

    it 'throws an error if links is not set' do
      config.stub(:links).and_return(nil)
      expect { config.validate! }.to raise_error NotImplementedError
    end

    it 'throws an error if new_link_request is not set' do
      config.stub(:new_link_request).and_return(nil)
      expect { config.validate! }.to raise_error NotImplementedError
    end

    it 'throws an error if process_response is not set' do
      config.stub(:process_response).and_return(nil)
      expect { config.validate! }.to raise_error NotImplementedError
    end
  end

  describe :attributes do
    it 'sets attributes' do
      [
        :debug,
        :batch_size,
        :max_concurrency,
        :max_retries,
        :cookies_file,
        :max_total_connections,
        :max_timeout
      ].each do |param|
        config.should respond_to(param)
        config.should respond_to("#{param}=")
      end
    end
  end

  describe :logging do
    it 'is nil by default' do
      config.logger.should be_nil
    end

    it 'creates a valid logger object when log= is set' do
      config.log = STDOUT
      config.logger.should be_a Logger
    end

    # Debug
    it 'sets logging level to DEBUG if debug is set first' do
      config.debug = true
      config.log = STDOUT
      config.logger.level.should eq Logger::DEBUG
    end

    it 'sets logging level to DEBUG if debug is set last' do
      config.log = STDOUT
      config.debug = true
      config.logger.level.should eq Logger::DEBUG
    end

    it 'sets logging level to WARN if debug level is not specified' do
      config.log = STDOUT
      config.logger.level.should eq Logger::WARN
    end

    it 'sets logging level to WARN if debug is changed from true -> false' do
      config.debug = true
      config.log = STDOUT
      config.debug = false
      config.logger.level.should eq Logger::WARN
    end
  end

  describe :callbacks do
    
    it 'sets get_link_by_id' do
      config.retrieves_links_by_id_with do |link_id|
        link_id.should eq 456
      end

      config.get_link_by_id.call(456)
    end

    it 'sets links' do
      expected_response = double('expected_response')
      config.retrieves_all_links_with do
        expected_response
      end

      config.links.call.should eq expected_response
    end

    it 'sets new_link_request' do
      expected_response = double('expected_response')
      config.creates_new_link_request_with do |url, params|
        expected_response
      end

      config.new_link_request.call.should eq expected_response
    end

    it 'sets process_response' do
      expected_response = double('expected_response')
      config.processes_response_with do |response|
        expected_response
      end

      config.process_response.call.should eq expected_response
    end
  end
  
end