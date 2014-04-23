module UrlProcessor
  class Runner

    #attr_reader :callbacks

    def initialize(config)
      raise ArgumentError.new("invalid config '#{config}', expected ::Config") unless config.is_a? UrlProcessor::Config
      @runner = Base.new(config)
    end

    def run
      @runner.run
    end

  end
end