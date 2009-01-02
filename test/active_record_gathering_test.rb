require 'test/unit'
require 'test_helper'
require 'locale_selector'

class ActiveRecordGatheringTest < Test::Unit::TestCase
  def po_name()
    File.expand_path(File.join(Dir.pwd, "po/default.pot"))
  end

  def setup
    Dir.chdir File.join(File.dirname(__FILE__), 'TestApp')
    `rake gettext:updatepo lang=de`
#    FileUtils.rm_f(po_name)
#    Dir.chdir 'rails'
#    GetText.update_pofiles("updatepo_test", Dir.glob("rails/app/**/*.{rb,erb,rjs,rhtml}"), '1.0')
  end

  def teardown
#      Dir.chdir '..'
  end

  def assert_contains_string(search_for)
    File.new(po_name).any? { |line| line =~ search_for }
  end

  def assert_po_matches(search_for)
    po = IO.readlines(po_name())
    assert po =~ search_for, "po content does not match #{search_for}"
  end

  def test_multiple_models_per_file
    assert_po_matches(/ArticleProperty|Key/)
  end

  def test_namespaced_model # deeper directory structure
    assert_po_matches(/Resume|content/)
  end

  def test_model_with_observer
  end

  def test_active_record_outside_rails
  end

end
