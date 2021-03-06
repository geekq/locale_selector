require 'locale_selector'
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '13f7af392bf5fe8fa56744eeb59d1dbf'
  
  offer_locales :en_UK, :en_ZA, :de, :ru
end
