class Blitline
  class S3Destination
    include AttributeJsonizer
    attr_accessor :key, :bucket, :headers

    def initialize(key, bucket, headers = {})
      @key = key
      @bucket = bucket
      @headers = headers
    end

    def validate
      raise "S3Destination must have a key" if @key.nil?
      raise "S3Destination must have a bucket" if @bucket.nil?
      raise "S3Destination headers must be a hash" if @headers && !@headers.is_a?(Hash)
    end
  end
end