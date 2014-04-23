# url_processor [![Build Status](https://travis-ci.org/ejhayes/url_processor.png?branch=master)](https://travis-ci.org/ejhayes/url_processor) [![Gem Version](https://badge.fury.io/rb/url_processor.png)](http://badge.fury.io/rb/url_processor) [![Code Climate](https://codeclimate.com/github/ejhayes/url_processor.png)](https://codeclimate.com/github/ejhayes/url_processor)

Fast and easy way to process urls.

## Installation

Add this line to your application's Gemfile:

    gem 'url_processor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install url_processor

## Usage

Example use case:

    require 'url_processor'
    require 'trollop'

    opts = Trollop::options do
      banner <<-EOS
    This utility validates the quality of links used by courtreference.com.
    EOS
      opt :log, "output to logfile (default is STDOUT)", :type => :string
      opt :debug, "enable debugging mode"
      opt :batch_size, "maximum batch size (records to retrieve at a time before processing urls)", :default => 100
      opt :max_concurrency, "maximum number of threads to spawn", :type => :int, :default => 20
      opt :max_retries, "maximum number of times to try a url before failing", :type => :int, :default => 3
      opt :max_timeout, "maximum duration in seconds to wait for url to load", :type => :int, :default => 5
      opt :cookies_file, "file to store cookie information", :type => :string, :default => '/tmp/whatever_cookies'
      opt :max_total_connections, "maximum number of connections to keep open at a time", :type => :int, :default => 100
    end

    # Additional validations
    opts[:log] = STDOUT if opts[:log] == nil

    link_check = UrlProcessor.create do |config|
      config.log = opts[:log]
      config.debug = opts[:debug]
      config.batch_size = opts[:batch_size]
      config.max_concurrency = opts[:max_concurrency]
      config.max_retries = opts[:max_retries]
      config.cookies_file = opts[:cookies_file]
      config.max_total_connections = opts[:max_total_connections]

      config.retrieves_links_by_id_with do |link_id|
        puts "I was called with #{link_id}"
      end

      config.retrieves_all_links_with do
        links = []
        (1..3).each do |i|
          links << OpenStruct.new(:id => i, :urls => [{:url => 'http://www.example.com'}])
        end
        links
      end

      config.creates_new_link_request_with do |url, params|
        UrlProcessor::LinkRequest.new(url, params)
      end

      config.processes_response_with do |response|
        if response.return_code == :ok
          config.logger.info "#{response.return_code} - #{response.effective_url}".green
          destroyed_broken_link = OpenStruct.new(:id => 1, :serializable_hash => { :about => 'Not a real record' })
          config.logger.debug "broken link destroyed (#{destroyed_broken_link.id}): #{destroyed_broken_link.serializable_hash}".green
        else
          config.logger.info "#{response.return_code} - #{response.effective_url}".red
        end
      end
    end

    puts "Running this thing..."
    link_check.run

## Updating this gem

If you are making changes to this gem, here's some stuff you will need to know:

## Running the executables

If you have an exetable file called "my_executable" in the bin folder, you can run it by doing:

    bundle exec my_executable

If you want to play around in the interactive console with the gem already loaded, you can do this:

    bundle exec rake console

To run the tests

    bundle exec rake spec

Please note that we are using simplecov for code coverage.

## Contributing

1. Fork it ( http://github.com/ejhayes/url_processor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
