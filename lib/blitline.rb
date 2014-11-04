class Blitline
  require 'multi_json'
  require 'blitline/attribute_jsonizer'
  require 'blitline/function'
  require 'blitline/job'
  require 'blitline/save'
  require 'blitline/s3_destination'
  require 'blitline/http_poster'
  require 'net/http'
  
  include AttributeJsonizer
  attr_accessor :jobs

  def initialize
    @jobs = []
    @domain = ENV['BLITLINE_DOMAIN'] || "api"
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

  def add_job_via_hash(hash)
    @jobs << hash
  end

  def validate
    raise "At least 1 job must be present to run" if @jobs.length < 1
    @jobs.each do |j|
      unless j.is_a?(Hash)
        j.validate
      end
    end
  end

  def post_jobs
    validate
    result = Blitline::HttpPoster.post("http://#{@domain}.blitline.com/job", { :json => MultiJson.dump(@jobs)})
    @jobs = [] # clear jobs
    return MultiJson.load(result)
  end

  def post_job_and_wait_for_poll
    validate
    raise "'post_job_with_poll' requires that there is only 1 job to submit" unless @jobs.length==1
    result = Blitline::HttpPoster.post("http://#{@domain}.blitline.com/job", { :json => MultiJson.dump(@jobs)})
    json_result = MultiJson.load(result)
    raise "Error posting job: #{result.to_s}" if result["error"]
    job_id = json_result["results"][0]["job_id"]
    return poll_job(job_id)
  end

  def poll_job(job_id)
    raise "Invalid 'job_id'" unless job_id && job_id.length > 0
    url = "/listen/#{job_id}"

    response = {}

    begin
      Terminator.terminate 2 do
        response = Net::HTTP.get('cache.blitline.com', url)
      end
    rescue Terminator.error
    end

    json_response = MultiJson.load(response)

    return json_response
  end

end
