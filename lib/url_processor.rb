require 'typhoeus'
require 'colorize'
require 'ostruct'
require 'url_processor/version'
require 'url_processor/error'
require 'url_processor/runner'
require 'url_processor/config'
require 'url_processor/base'
require 'url_processor/retryable_request'
require 'url_processor/link_request'

module UrlProcessor

  def self.create(&block)
    config = Config.new
    block.call config

    # validate before returning
    config.validate!

    Runner.new(config)
  end

end
