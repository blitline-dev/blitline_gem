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

    should "be able to commit a job with multiple embedded functions" do
      blitline = Blitline.new
      job =  Blitline::Job.new(SAMPLE_IMAGE_SRC)
      job.application_id = ENV['BLITLINE_APPLICATION_ID']
      watermark_function = job.add_function("watermark", {text:"Jason"})
      watermark_function.add_save("watermarked")#, @key, @s3_config['bucket_name'])

      # begin sub-functions
      original_function = watermark_function.add_function("resize_to_fit", {width:2000, height:2000})
      original_function.add_save("original")#, key('original'), @s3_config['bucket_name'])

      sm_gallery_function = watermark_function.add_function("resize_to_fill", {width:200, height:200})
      sm_gallery_function.add_save("smgallery")#, key('sm_gallery'), @s3_config['bucket_name'])

      # if I add a third subfunction, the job appears to fail. If I remove these two lines below, the job works.
      thumb_function = watermark_function.add_function("resize_to_fit", {width:100, height:100})
      thumb_function.add_save("thumb")#, key('thumb'), @s3_config['bucket_name'])

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
      rotate_function = blur_function.add_function("rotate", { "amount" => -90 })
      rotate_function.add_save("rotate_only_result")
      returned_values = blitline.post_jobs
      assert(returned_values.length > 0, "No results returned")
      assert(returned_values['results'][0]['images'].length > 0, "No images returned")
    end
  else
    puts "Cannot test service with ENV['BLITLINE_APPLICATION_ID']"
  end
end
