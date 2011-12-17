class Blitline
  class Job
    include AttributeJsonizer
    attr_accessor :application_id, :src, :postback_url, :functions

    def initialize(image_src, application_id = nil)
      @src = image_src
      @functions = []
    end

    def add_function(function_name, function_params, image_identifier = nil)
      function = Blitline::Function.new(function_name, function_params)
      function.add_save(image_identifier) if image_identifier
      @functions << function
      return function
    end

    def validate
      raise "Job must have an application_id" if @application_id.nil?
      raise "Job must have an image_src to work on" if @src.nil?
      @functions.each { |f| f.validate }
    end
  end
end