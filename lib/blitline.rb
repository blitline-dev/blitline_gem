class Blitline
  require 'yajl'
  require 'blitline/attribute_jsonizer'
  require 'blitline/function'
  require 'blitline/job'
  require 'blitline/save'
  require 'blitline/s3_destination'
  require 'blitline/http_poster'

  include AttributeJsonizer
  attr_accessor :jobs

  def initialize
    @jobs = []
  end

  # Heroku users don't need to specify application_id if they have ENV['BLITLINE_URL'] defined
  def add_job(image_source, function_name, function_params, image_identifier, application_id = nil)
    job = Blitline::Job.new(image_source)
    environment_app_id = ENV['BLITLINE_URL'] && ENV['BLITLINE_URL'].split("/").last
    job.application_id = environment_app_id || application_id
    job.add_function(function_name, function_params, image_identifier)
    @jobs << job
  end

  # Heroku users don't need to specify application_id if they have ENV['BLITLINE_URL'] defined
  def add_job_with_callback(image_source, function_name, function_params, image_identifier, postback_url, application_id = nil)
    job = Blitline::Job.new(image_source)
    environment_app_id = ENV['BLITLINE_URL'] && ENV['BLITLINE_URL'].split("/").last
    job.application_id = environment_app_id || application_id
    job.add_function(function_name, function_params, image_identifier)
    job.postback_url = postback_url
    @jobs << job
  end

  def validate
    raise "At least 1 job must be present to run" if @jobs.length < 1
    @jobs.each { |j| j.validate }
  end

  def post_jobs
    validate
    result = Blitline::HttpPoster.post("http://api.blitline.com/job", { :json => Yajl::Encoder.encode(@jobs)})
    return Yajl::Parser.parse(result)
  end

end
