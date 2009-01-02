require 'test/unit'
require 'test_helper'
require 'locale_selector'

class AcceptLanguageParserTest < Test::Unit::TestCase
  include LocaleSelector::ControllerInstanceMethods

  def test_parse
    assert_equal [['de-de', 1], ['en-us', 0.8], ['en', 0.5], ['ru', 0.3]],
      parse_accept_language('de-de,en-us;q=0.8,en;q=0.5,ru;q=0.3')
  end

  def test_sort
    assert_equal [['de-de', 1], ['en-us', 0.8], ['ru', 0.7], ['en', 0.5]],
      parse_accept_language('en;q=0.5,en-us;q=0.8,de-de,ru;q=0.7')
  end

  def test_match
    assert_equal 'de',
      match_accept_language(
      [['de-de', 1], ['en-us', 0.8]], %w(en de ru))
  end
end
