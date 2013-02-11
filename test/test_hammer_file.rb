require "./tests"

class TestHammerFile < Test::Unit::TestCase
  context "A file" do
    setup do
      @file = Hammer::HammerFile.new(:filename => "style.scss")
    end
    
    should "replace its filename" do
      assert_equal @file.finished_filename, "style.css"
    end
  end
end