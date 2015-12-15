require "test_helper.rb"
require "hammer/parsers/sass"

class TestSCSS < Test::Unit::TestCase

  def assert_includes(a, b)
    assert a.include? b
  end

  context "A SCSS Parser" do
    setup do
      @parser = Hammer::SASSParser.new(:path => "style.scss")
    end

    context "when parsing an error" do
      should "raise a message" do
        error = assert_raises do
          @parser.parse("a { background: red;")
        end
        assert error.message.include? 'ground: red'
        assert_equal 2, @parser.error_line
      end
    end

    context "with a scss file" do
      setup do
        @file = create_file 'style.scss', 'a { background: red; }', @parser.directory
      end

      should "output to css" do
        @parser.parse("a { b { background: red; } }")
        assert_equal "a b {\n  background: red; }", @parser.to_format(:css)
      end

      should "not output to scss" do
        assert_equal false, @parser.to_format(:sass)
      end
      should "output the original text to scss" do
        assert_equal @parser.parse("a b {\n  background: red; }"), @parser.to_format(:scss)
      end
      should "parse SASS" do
        assert_equal "a b {\n  background: red; }", @parser.parse("a { b { background: red; } }")
      end
    end

    context "with other SCSS files" do
      setup do
        file = create_file('style.scss', 'a { background: red; }', @parser.directory)
        @parser.expects(:find_files).returns([file])
      end

      should "include SCSS files" do
        text = @parser.parse("/* @include style */")
        assert_includes "a {\n  background: red; }", text
      end
    end
  end

  context "A SCSS parser" do
    setup do
      @parser = Hammer::SASSParser.new(:path => "style.scss")
    end
    context "with an SCSS file" do

      setup do
        @file = create_file "normalize.css", "* {normalize: true}", @parser.directory
      end

      context "that has an include of a CSS file" do
        setup do
          @parser.expects(:find_files).with('normalize', 'scss').returns([@file])
        end

        should "Be able to include the CSS file" do
          # assert_equal "* {normalize: true}", @parser.parse("/* @include normalize */")
          # TODO: Check that this change is right. SCSS shouldn't be able to include CSS, right?
          assert_equal "/* @include normalize */", @parser.parse("/* @include normalize */")
        end
      end

      context "that has an include of a SASS file" do
        setup do
          create_file "normalize.sass", "* \n  normalize: true", @parser.directory
          @parser.expects(:find_files).with('normalize', 'scss').returns([@file])
        end

        should "Be able to include the normalize" do
          assert_equal "/* @include normalize */", @parser.parse("/* @include normalize */")
        end
      end
    end
  end

  context "an SCSS parser with dependencies" do

    setup do
      @directory = Dir.mktmpdir()

      File.open(File.join(@directory, 'error.scss'), 'w') { |file|  file.write("@import 'does-not-exist-included-in-an-include.scss'") }
      File.open(File.join(@directory, 'about.scss'), 'w') { |file|  file.write("* { backgroud: green; }") }
      File.open(File.join(@directory, 'style.scss'), 'w') { |file|  file.write("include(about.scss);") }

      @parser = Hammer::SASSParser.new(:path => "style.scss")
      @parser.input_directory = @directory
    end

    should "parse an include" do
      assert @parser.parse("@import 'about.scss';").include? 'green'
    end

    should "raise an error when including a file that doesn't exist" do
      error = assert_raises do
        @parser.parse("@import 'does-not-exist.scss';")
      end
      assert_equal 2, @parser.error_line
      assert error.message.include? 'does-not-exist'
    end

    should "raise an error when including a file that has an error in it" do
      file = create_file('error.scss', "@import 'does-not-exist-included-in-an-include.scss'", @parser.directory)
      @parser.stubs(:find_files).returns([file])
      error = assert_raises do
        @parser.parse("@import 'error';")
      end
      assert_equal 1, @parser.error_line
      assert error.message.include? 'does-not-exist'
    end

  end
end
