require 'test/unit'
require 'fileutils'
require 'locale_selector'

class ActiveRecordGatheringTest < Test::Unit::TestCase
  def self.po_name()
    File.expand_path(File.join(Dir.pwd, "po/default.pot"))
  end

  def po_name()
    ActiveRecordGatheringTest.po_name
  end

  def self.major_setup
    FileUtils.rm_f(po_name)
    Dir.chdir File.join(File.dirname(__FILE__), 'TestApp')
    puts `rake gettext:updatepo lang=de`
  end

  def self.major_teardown
    Dir.chdir '..'
  end

  def assert_contains_string(search_for)
    File.new(self.po_name).any? { |line| line =~ search_for }
  end

  def assert_po_matches(search_for)
    po = IO.read(po_name())
    assert po =~ search_for, "po content does not match #{search_for}"
  end

  def test_multiple_models_per_file
    assert_po_matches(/ArticleProperty\|Key/)
  end

  def test_namespaced_model
    assert_po_matches(/Resume\|Content/)
  end

  def test_model_with_observer
    assert_po_matches(/User\|Name/)
  end

  def test_active_record_outside_rails
    # TODO
  end

  # override the default suite generation to be able to use global setup
  # and teardown. S. also "The Ruby Way", p. 637
  def self.suite
    mysuite = super

    def mysuite.run(*args)
      ActiveRecordGatheringTest.major_setup
      super
      ActiveRecordGatheringTest.major_teardown
    end

    mysuite
  end
end
