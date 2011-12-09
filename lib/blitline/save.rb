class Blitline
  class Save
    include AttributeJsonizer
    attr_accessor :image_identifier, :s3_destination

    def initialize(image_identifier)
      @image_identifier = image_identifier
    end

    def add_s3_destination(key, bucket)
      @s3_destination = Blitline::S3Destination.new(key, bucket)
    end

    def validate
      raise "Save must have an image_identifier. This value is returned with results and let's you, the client, identify what image this is" if @image_identifier.nil?
      @s3_destination.validate unless @s3_destination.nil?
    end
  end
end