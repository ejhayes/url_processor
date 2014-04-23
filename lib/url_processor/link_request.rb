module UrlProcessor
  class LinkRequest < RetryableRequest
    attr_accessor :link_id
    attr_accessor :url_type_code

    def initialize(base_url, options={})
      @link_id = options.delete(:link_id)
      @url_type_code = options.delete(:url_type_code)
      super(base_url, options)
    end
  end
end