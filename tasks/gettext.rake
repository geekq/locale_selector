require File.join(File.dirname(__FILE__), '../lib/locale_selector.rb')

def gettext_domain
  initializer_name = File.join(File.dirname(__FILE__),
    '../../../../config/initializers/gettext.rb')
  require initializer_name if File.exist?(initializer_name)

  LocaleSelector::default_domain ||
    ENV['GETTEXT_DOMAIN'] ||
    puts("Please either set the LocaleSelector::default_domain in your environment.rb or ENV['GETTEXT_DOMAIN'].") && exit
end

def app_version
  "#{gettext_domain} 1.0"
end

namespace :gettext do
  desc "Update pot/po files (text files with translations) " \
    "Note: please make sure, that all the database connections used " \
    "in your models work. Gettext connects to the database to extract " \
    "field names to be translated."
  task :updatepo do
    require 'gettext/utils'
    puts "Updating translation files for gettext domain #{gettext_domain}"
    orig_msgmerge = ENV["MSGMERGE_PATH"] || "msgmerge"
    ENV["MSGMERGE_PATH"] = "#{orig_msgmerge} --no-fuzzy-matching"
    GetText.update_pofiles(gettext_domain, Dir.glob(["{app,lib,plugins}/**/*.{rb,erb,rjs,rhtml}", "plugins/**/**/*.{rb,erb,rjs,rhtml}"]), app_version)
  end

  desc "Compile mo-(machine object) files."
  task :makemo do
    require 'gettext/utils'
    GetText.create_mofiles(true, "po", "locale")
  end

  desc "Translation for additional (new) language, use TR_LANG=xx"
  task :translate_to do
    lang = ENV['TR_LANG']
    if lang
      puts <<-"# # #"
Please run:

mkdir po/#{lang}
msginit -i po/#{gettext_domain} -l #{lang} -o po/#{lang}/#{gettext_domain}.po --no-translator
svn add po/#{lang}
             # # #
    else
      puts "Please set the environment variable TR_LANG to the desired " +
           "language code like TR_LANG=de"
    end
  end

end