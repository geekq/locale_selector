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

def update_po_single_language(textdomain, files, app_version, lang, po_root = "po", refpot = "tmp.pot")
  rgettext(files, refpot)

  FileUtils.mkdir_p(po_root) unless FileTest.exist? po_root
  msgmerge("#{po_root}/#{textdomain}.pot", refpot, app_version)

  msgmerge("#{po_root}/#{lang}/#{textdomain}.po", refpot, app_version)

  File.delete(refpot)
end

namespace :gettext do
  desc "Update pot/po files (text files with translations) " \
    "Note: please make sure, that all the database connections used " \
    "in your models work. Gettext connects to the database to extract " \
    "field names to be translated. " \
    "Use lang={language to process} or lang=all to process po-files for all languages."
  task :updatepo do
    require 'gettext/utils'
    puts "Updating translation files for gettext domain #{gettext_domain}"
    orig_msgmerge = ENV["MSGMERGE_PATH"] || "msgmerge"
    ENV["MSGMERGE_PATH"] = "#{orig_msgmerge} --no-fuzzy-matching"
    source_files = Dir.glob(["{app,lib,plugins}/**/*.{rb,erb,rjs,rhtml}", "plugins/**/**/*.{rb,erb,rjs,rhtml}"])
    lang = ENV['lang']
    if lang.nil?
      fail "Use lang={language to process} or lang=all to process po-files for all languages."
    else
      if lang == 'all'
        GetText.update_pofiles(gettext_domain, source_files, app_version)
      else
        update_po_single_language(gettext_domain, source_files, app_version, lang)
      end
    end
  end

  desc "Compile mo-(machine object) files."
  task :makemo do
    require 'gettext/utils'
    GetText.create_mofiles(true, "po", "locale")
  end

  desc "Translation for additional (new) language, use lang=xx"
  task :translate_to do
    lang = ENV['lang']
    if lang
      puts <<-"# # #"
Please run:

mkdir po/#{lang}
msginit -i po/#{gettext_domain} -l #{lang} -o po/#{lang}/#{gettext_domain}.po --no-translator
svn add po/#{lang}
      # # #
    else
      fail "Please provide the 'lang' parameter on the command line with the desired " +
        "language code like lang=de"
    end
  end

end