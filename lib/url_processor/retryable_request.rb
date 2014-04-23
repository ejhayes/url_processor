module UrlProcessor
  class RetryableRequest < Typhoeus::Request
    def initialize(base_url, options={})
      @attempts = 0
      @max_retries = options.delete(:max_retries) || 3
      super(base_url, options)
    end

    def on_complete(&block)
      @attempts += 1
      super(&block)
    end

    def retry_request
      if retry_request?
        options[:method] = :get
        return self
      else
        return nil
      end
    end

    def retry_request?
      @attempts <= @max_retries
    end
  end
end