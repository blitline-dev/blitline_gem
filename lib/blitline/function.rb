class Blitline
  class Function
    include AttributeJsonizer
    attr_accessor :name, :params, :save, :functions

    def initialize(name, params = nil)
      @name = name
      @params = params unless params.nil?
      @functions = []
    end

    def add_save(image_identifier, s3_key = nil, s3_bucket = nil, headers = {})
      save = Blitline::Save.new(image_identifier)
      if s3_key && s3_bucket
        save.add_s3_destination(s3_key, s3_bucket, headers)
      end
      @save = save
    end

    def add_function(function_name, function_params)
      function = Blitline::Function.new(function_name, function_params)
      @functions << function
      return function
    end

    def validate
      raise "Function must have a name" if @name.nil?
      raise "Params must be a hash" if @params && !@params.is_a?(Hash)
      @save.validate if @save
      @functions.each { |f| f.validate } if @functions
    end
  end
end
