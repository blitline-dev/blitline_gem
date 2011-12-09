class Blitline
  class S3Destination
    include AttributeJsonizer
    attr_accessor :key, :bucket

    def initialize(key, bucket)
      @key = key
      @bucket = bucket
    end

    def validate
      raise "S3Destination must have a key" if @key.nil?
      raise "S3Destination must have a bucket" if @bucket.nil?
    end
  end
end