module UrlProcessor

  class Config
    # configuration parameters
    attr_accessor :batch_size
    attr_accessor :max_concurrency
    attr_accessor :max_retries
    attr_accessor :cookies_file
    attr_accessor :max_total_connections
    attr_accessor :max_timeout

    # debugging
    attr_reader :debug
    def debug=(val)
      @debug = val
      update_logging_level
    end

    # logging
    attr_reader :logger

    def log=(logging_location)
      @logger = Logger.new(logging_location)
      update_logging_level
    end

    # get individual link
    attr_reader :get_link_by_id
    def retrieves_links_by_id_with(&block)
      @get_link_by_id = block
    end

    # get all links
    attr_reader :links
    def retrieves_all_links_with(&block)
      @links = block
    end

    # create new link request
    attr_reader :new_link_request
    def creates_new_link_request_with(&block)
      @new_link_request = block
    end

    # process responses
    attr_reader :process_response
    def processes_response_with(&block)
      @process_response = block
    end

    def validate!
      raise NotImplementedError.new("retrieves_links_by_id_with not set") if get_link_by_id.nil?
      raise NotImplementedError.new("retrieves_all_links_with not set") if links.nil?
      raise NotImplementedError.new("creates_new_link_request_with not set") if new_link_request.nil?
      raise NotImplementedError.new("processes_response_with not set") if process_response.nil?
    end

    private

    def update_logging_level
      unless logger.nil?
        if debug
          logger.level = Logger::DEBUG
        else
          logger.level = Logger::WARN
        end
      end
    end

  end

end