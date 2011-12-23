require 'helper'

class TestService < Test::Unit::TestCase
  if ENV['BLITLINE_APPLICATION_ID']
    require 'yajl'
    SAMPLE_IMAGE_SRC = "http://www.google.com/intl/en_com/images/srpr/logo3w.png"

    should "be able to commit a simple job to service" do
      blitline = Blitline.new
      job =  Blitline::Job.new(SAMPLE_IMAGE_SRC)
      job.application_id = ENV['BLITLINE_APPLICATION_ID']
      job.add_function("blur", nil, "my_image")
      blitline.jobs << job
      returned_values = blitline.post_jobs
      assert(returned_values.length > 0, "No results returned")
      assert(returned_values['results'][0]['images'].length > 0, "No images returned")
    end

    should "be able to commit a multi-function job to service" do
      blitline = Blitline.new
      job =  Blitline::Job.new(SAMPLE_IMAGE_SRC)
      job.application_id = ENV['BLITLINE_APPLICATION_ID']
      blur_function = job.add_function("blur", nil)
      blitline.jobs << job
      # Add a rotate function inside the blur function (so it will blur first, then rotate)
      rotate_function = blur_function.add_function("rotate", { "amount" => -90 }, "Finished rotated image")
      returned_values = blitline.post_jobs
      assert(returned_values.length > 0, "No results returned")
      assert(returned_values['results'][0]['images'].length > 0, "No images returned")
    end
  else
    puts "Cannot test service with ENV['BLITLINE_APPLICATION_ID']"
  end
end
