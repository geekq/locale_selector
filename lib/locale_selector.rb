require 'uri'
=begin rdoc
Author::    Vladimir Dobriakov (http://blog.geekQ.net)
Copyright:: Copyright (c) 2008
License::   MIT license

= Usage

== Controller

In your controllers or in the application controller
use ControllerClassMethods#offer_locales:

  offer_locales :en_UK, :en_ZA, :de, :ru

You can use different text domains in different parts of your application,
if your application is large enough for multiple translation files.
Please provide the differing domain in the single controllers e.g.

  class JobsController < ApplicationController
    offer_locales :de, :ru, :domain => 'HR_terminology'
  end

=== Persisting preferences

locale_selector provides helpers which you can use in connection with Rails
hooks like this:

  class ApplicationController
    before_filter :persist_locale_choice_cookie
    after_filter  :persist_locale_choice_in_db

    def persist_locale_choice_cookie
      compute_effective_locale do |requested_locale|
        save_cookie requested_locale
      end
    end

    def persist_locale_choice_in_db
      compute_effective_locale do |requested_locale|
        if current_user
          current_user.update_attribute 'preferred_locale', requested_locale
          current_user.reload
        end
      end
    end
    ...


== Initializer

The default text domain can be set in a initializer
file config/initializers/gettext.rb

  LocaleSelector::default_domain = 'myapp'

== View

In app/views/layouts/application.html.erb or in single views you
can use

  <%= language_selector %>

Or write your own language selector helper. For the example
see the documentation for language_selector method for an implementation
example.
=end

module LocaleSelector

  # Please set the gettext domain in a initializer,
  # the file <tt>config/initializers/gettext.rb</tt> is recommended
  #   LocaleSelector::default_domain = 'myapp'
  def self.default_domain=(d)
    @@default_domain = d
  end

  def self.default_domain
    defined?(@@default_domain) ? @@default_domain : 'default'
  end

  module ControllerClassMethods
    # Usage:
    # offer_locales :en_UK, :de, :domain => 'my_application'
    # The default for the list of the locales is the list
    # of subdirectories of the 'locale' folder.
    # Possible options are:
    # <tt>:domain</tt>::
    #     the gettext domain
    # <tt>:lang_cookie_path</tt>::
    #     the path for cookie that remembers the user locale selection
    def offer_locales(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      class_variable_set :@@offered_locales,
        args.empty? ?
        GetText::Rails::available_locales :
        args.flatten.map{|l| l.to_s}.uniq
      helper_method :effective_locale, :offered_locales
      init_gettext options[:domain] || LocaleSelector::default_domain
      class_variable_set :@@lang_cookie_path, options[:lang_cookie_path] || '/'
    end

    private

    def global_offered_locales # :nodoc:
      class_variable_get :@@offered_locales
    end

    def lang_cookie_path # :nodoc:
      class_variable_get :@@lang_cookie_path
    end

  end

  module ControllerInstanceMethods
    # List of explicitely offered locales, as set during the
    # initialization by #offer_locales
    def offered_locales
      self.class.send :global_offered_locales
    end

    # This helper saves the user locale selection in a cookie.
    # You can adjust the cookie path during the initialization
    # with #offer_locales, use the :lang_cookie_path option.
    def save_cookie(requested_lang)
      cookies[:lang] = {
        :value => requested_lang,
        :expires => 1.month.from_now,
        :path => root_path
      }
    end

    private

    # Accepts a block. The locale, conciously chosen by user
    # is passed to the block. Can be used for persisting the
    # user choice in a database or/and in a cookie.
    def compute_effective_locale
      # Priority order:
      # 1.query parameter 'lang'
      # 2.cookie 'lang'
      # 3.browser setting
      requested_lang = params[:lang] || cookies[:lang]
      if self.offered_locales.include? requested_lang
        yield requested_lang if block_given?
        return requested_lang
      end

      parse_and_match_accept_language || 'en'
    end

    def parse_and_match_accept_language # :nodoc:
      parsed = parse_accept_language(request.headers['Accept-language'])
      match_accept_language parsed, offered_locales
    end

    def parse_accept_language(s) # :nodoc:
      return [] unless s
      res = []
      s.split(',').each do |entry|
        code, prio = entry.split(';q=')
        res << [code, prio ? prio.to_f : 1]
      end
      res.sort {|a,b| b[1] <=> a[1]}
    end

    def match_accept_language(parsed_accept_language, offered_langs) # :nodoc:
      parsed_accept_language.each do |lang, prio|
        return lang if offered_langs.include?(lang)
        return lang[0..1] if offered_langs.include?(lang[0..1])
      end
      offered_langs[0]
    end

    alias effective_locale compute_effective_locale
    public :effective_locale

  end

  module ViewInstanceMethods
    # Simple text based UI element for locale/language selection, that
    # you can put on every page by calling this method in your layout view.
    # Lists the languages offered by application as clickable links.
    # see also #offer_locales.
    #
    # You can provide a block (executed per language) if you would
    # like to override the default list of text based \<a href=""\> elements.
    #
    # For example, you can easily implement an image based language selector
    # language_selector do |lang, active|
    #   link_to image_tag("#{lang}#{active ? '' : '_inactive'}.png", :alt => lang),
    #     language_selector_href(lang, params)
    # end
    def language_selector(additional_params=params, &block)
      content_tag :ul, :id => 'language_selector' do
        offered_locales.map do |lang|
          selected = lang == effective_locale
          content_tag :li, :class => "#{lang} #{selected ? 'selected' : ''}" do
            if block_given?
              yield lang, selected
            else
              link_to(lang, language_selector_href(lang, additional_params))
            end
          end
        end.join
      end
    end

    # Can be used if you are going to implement your own language selection control.
    # Generates a link, that links to the current page but with an additional
    # 'lang' parameter.
    #
    # Note: if the user fills in e.g. form fields and clicks the language
    # selection link afterwards, then the filled in data is lost.
    def language_selector_href(lang, params)
      path = (uri = request.request_uri) ? uri.split('?').first.to_s : ''
      q = request.query_parameters.merge({'lang' => "#{lang}"}).map {
        |k,v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.sort.join("&amp;")
      "#{path}?#{q}"
    end
  end
end

if defined?(ActionController)
  ActionController::Base.send(:include, LocaleSelector::ControllerInstanceMethods)
  ActionController::Base.extend LocaleSelector::ControllerClassMethods
end
if defined?(ActionView)
  ActionView::Base.send(:include, LocaleSelector::ViewInstanceMethods)
end

module Locale # :nodoc:
  # Patch for the gettext gem 1.92 and earlier.
  # Now incorporated into gettext.
  class Object
    def self.parse(locale_name) # :nodoc:
      # PATCH: the following line is new
      locale_name = "en" if locale_name.nil? || locale_name.empty?

      lang_charset, modifier = locale_name.split(/@/)
      lang, charset = lang_charset.split(/\./)
      language, country, script, variant = lang.gsub(/_/, "-").split('-')
      language = language ? language.downcase : nil
      language = "en" if language == "c" || language == "posix"
      if country
        if country =~ /\A[A-Z][a-z]+\Z/  #Latn => script
          tmp = script
          script = country
          if tmp =~ /\A[A-Z]+\Z/ #US => country
            country = tmp
          else
            country = nil
            variant = tmp
          end
        else
          country = country.upcase
          if script !~ /\A[A-Z][a-z]+\Z/ #Latn => script
            variant = script
            script = nil
          end
        end
      end
      [language, country, charset, script, variant, modifier]
    end
  end
end
