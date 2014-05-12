module UrlProcessor
  class Cache
    def initialize
      @memory = {}
    end

    def get(request)
      @memory[request]
    end

    def set(request, response)
      @memory[request] = response
    end

    def empty!
      @memory.clear
    end
  end

  class Base
    attr_reader :config

    def initialize(c)
      raise ArgumentError unless c.is_a? UrlProcessor::Config
      @config = c

      # connect to the db
      #OnlinesearchesModels::connect
    end

    def new_broken_link(params={})
      raise NotImplementedError.new "new_broken_link not implemented"
    end

    def report_broken_link(link_id, params={})
      link_data = params[:link_data]
      response_code = params[:response_code]
      begin
        link = config.get_link_by_id.call(link_id)
        broken_link = new_broken_link(
          :link_id => link.id, 
          :fips_code => link.fips_code, 
          :link_data => link_data, 
          :response_code => response_code,
          :reported_by => 'QC Report'
        )
        broken_link.save
        config.logger.debug "broken link created (#{broken_link.id}): #{broken_link.serializable_hash}".red
      rescue ActiveRecord::RecordNotFound => e
        config.logger.warn "#{e}".red
      end
    end

    def pre_process_link(link)
      # do nothing
    end

    def process_response(response)
      raise NotImplementedError.new "process_reponse is not implemented"
    end

    def new_link_request(url, params={})
      raise NotImplementedError.new "link_request is not implemented"
    end

    def find_in_batches(collection, batch_size)
      if collection.respond_to? :find_in_batches
        collection.find_in_batches(batch_size: batch_size) do |group|
          # Output progress information
          config.logger.info "PROCESSED: #{processed_links}, NEXT GROUP SIZE: #{group.size}".yellow

          yield group

          # for debuggin purposes we do not want to process everything
          if config.debug && processed_links >= config.batch_size
            config.logger.debug "FINISHED first batch (#{@batch_size} records), exiting".yellow
            return
          end

        end
      else
        elements = []
        collection.each do |element|
          elements << element
          if elements.size % batch_size == 0
            yield elements
            elements = elements.clear
          end
        end
        # done iterating, yield whatever else we have left, if we have stuff left
        if elements.size > 0
          yield elements
        end
      end
    end

    def run
      processed_links = 0
      
      # use an in-memory cache of responses (per run)
      cache = Cache.new
      Typhoeus::Config.cache = cache
      
      hydra = Typhoeus::Hydra.new(max_concurrency: config.max_concurrency, max_total_connections: config.max_total_connections)

      find_in_batches(config.links.call, config.batch_size) do |group|

        group.each do |link|
          # any custom pre-processing
          pre_process_link(link)

          if link.urls.empty?
            # In the event that we have a link that actually has no urls associated with it
            report_broken_link link.id, :response_code => :has_no_urls if config.report_records_without_urls
          else
            # Each record has 2 urls associated with it, process each separately
            link.urls.each do |url|
              config.logger.debug "link: #{link.serializable_hash}, url: #{url}".yellow

              link_request = config.new_link_request.call(
                url[:url], 
                followlocation: true, 
                method: :head, 
                ssl_verifypeer: false, 
                ssl_verifyhost: 2, 
                cookiefile: config.cookies_file, 
                cookiejar: config.cookies_file, 
                link_id: link.id,
                link_data: url[:link_data],
                timeout: config.max_timeout,
                connecttimeout: config.max_timeout,
                max_retries: config.max_retries,
                forbid_reuse: 1,
                nosignal: 1
              )

              link_request.on_complete do |response|
                processed_links += 1

                if ([:operation_timedout, :couldnt_resolve_host].include? response.return_code) && response.request.retry_request?
                  config.logger.info "#{response.return_code} - #{response.effective_url} timed out, retrying".yellow
                  hydra.queue response.request
                elsif response.return_code == :got_nothing && response.request.options[:method] != :get
                  config.logger.info "#{response.return_code} - #{response.effective_url} empty response, attempting GET request instead".yellow
                  
                  # set to GET request since HEAD may fail in some cases
                  response.request.options[:method] = :get
                  hydra.queue response.request
                else
                  config.process_response.call response
                end
              end

              hydra.queue link_request
            end
          end
        end

        hydra.run
      end

      cache.empty!
    end
  end
end