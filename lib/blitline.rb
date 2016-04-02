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
    if result.is_a?(Hash)
       json_result = result
     else
       json_result = MultiJson.load(result)
     end
    @jobs = [] # clear jobs
    return json_result
  end

  def post_job_and_wait_for_poll(timeout_secs = 60)
     validate
     raise "'post_job_with_poll' requires that there is only 1 job to submit" unless @jobs.length==1
     result = Blitline::HttpPoster.post("http://#{@domain}.blitline.com/job", { :json => MultiJson.dump(@jobs)})
     if result.is_a?(Hash)
       json_result = result
     else
       json_result = MultiJson.load(result)
     end

     raise "Error posting job: #{result.to_s}" if result["error"]

     # handle async group jobs if existing
     job_id = json_result["results"][0]["group_completion_job_id"]
     # otherwise assume regular job poll
     job_id = json_result["results"][0]["job_id"] unless job_id
     return poll_job(job_id, timeout_secs)
  end

  def poll_job(job_id, timeout_secs = 60)
     raise "Invalid 'job_id'" unless job_id && job_id.length > 0
     url = "/listen/#{job_id}"

     response = fetch(url, timeout_secs)

     if response.is_a?(Hash)
       json_result = response
     else
       json_result = MultiJson.load(response)
     end

     # Change 2.5.0 -> 2.5.1 (Return JSON instead of string)
     if json_result["results"].is_a?(Hash)
       return_results = json_result["results"]
     else
       return_results = MultiJson.load(json_result["results"])
     end

     return return_results
  end

  def fetch(uri_str, timeout_secs, limit = 10)
    raise "Too Many Redirects" if limit == 0

    http = Net::HTTP.new("cache.blitline.com")
    http.read_timeout = timeout_secs
    request = Net::HTTP::Get.new(uri_str)
    response = http.request(request, uri_str)
    MultiJson.load(response.body)
  end
end
