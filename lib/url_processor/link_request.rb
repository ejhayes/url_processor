module UrlProcessor
  class LinkRequest < RetryableRequest
    attr_accessor :link_id
    attr_accessor :link_data # information about the link

    def initialize(base_url, options={})
      @link_id = options.delete(:link_id)
      @link_data = options.delete(:link_data)
      super(base_url, options)
    end
  end
end