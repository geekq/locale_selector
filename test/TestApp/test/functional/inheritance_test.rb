require File.dirname(__FILE__) + '/../test_helper'

# BTW: MyController = Class.new(ActionController::Base) {}
# does not work. Because of some Rails changes on the Class class?
class MyController < ActionController::Base
  offer_locales :fi, :ru, :domain => 'default'
end

class MySpecialController < MyController
end

class InheritanceTest < Test::Unit::TestCase
  def test_offer_locales
    contr = MyController.new()
    assert_equal ['fi', 'ru'], contr.offered_locales
    assert_equal ['fi', 'ru'], MySpecialController.new.offered_locales
  end
end
