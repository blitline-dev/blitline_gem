require 'helper'

class TestBlitline < Test::Unit::TestCase

  should "raise exception if missing jobs" do
    assert_raises RuntimeError do
      blitline = Blitline.new
      blitline.post_jobs
    end
  end

  should "raise exception if job missing application id" do
    assert_raises RuntimeError do
      blitline = Blitline.new
      blitline.jobs << Blitline::Job.new("http://ww.foo.com")
      blitline.post_jobs
    end
  end

  should "raise exception if job missing image identifier" do
    assert_raises RuntimeError do
      blitline = Blitline.new
      job =  Blitline::Job.new("http://ww.foo.com")
      job.application_id = "foo"
      job.add_function("blue", nil)
      blitline.jobs << job
      blitline.post_jobs
    end
  end

  should "raise exception if job missing image identifier" do
    assert_raises RuntimeError do
      blitline = Blitline.new
      job =  Blitline::Job.new("http://ww.foo.com")
      job.application_id = "foo"
      job.add_function("blur", nil, "my_image")
      blitline.jobs << job
      blitline.post_jobs
    end
  end

  should "raise exception if job missing image identifier" do
    blitline = Blitline.new
    job =  Blitline::Job.new("http://ww.foo.com")
    job.add_function("blue", nil, "my_image")
    job.application_id = "foo"
    blitline.jobs << job
    results = blitline.post_jobs
    assert_not_nil results['results']
    assert_not_nil results['results'][0]
    assert_not_nil results['results'][0]['error']
  end

end
