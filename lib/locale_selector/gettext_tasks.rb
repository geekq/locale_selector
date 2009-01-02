require File.join(File.dirname(__FILE__), '../locale_selector.rb')
require 'gettext'
require 'gettext/utils'
require 'activesupport'
require 'activerecord'

puts "Loading active_record parsing hacks in gettext_tasks.rb"
require 'gettext/rgettext'
require 'gettext/parser/active_record'
include GetText

def log(msg)
  puts msg if false # set verbosity here
end

ActiveRecord::Base.instance_eval do
  alias inherited_without_log inherited

  @@active_record_classes_list = []

  def inherited(subclass)
    unless "#{subclass}" =~ /^CGI::/
      log "registering an ActiveRecord model for later processing: #{subclass}"
      active_record_classes_list << "#{subclass}"
    end
    inherited_without_log(subclass)
  end

  def active_record_classes_list
    @@active_record_classes_list
  end

  def reset_active_record_classes_list
    @@active_record_classes_list = []
  end
end

module GetText
  module ActiveRecordParser
    log "overriding the original activerecord parser"
  
    def self.parse(file, targets = []) # :nodoc:
      log "locale_selector specific version of activerecordparser.parse is parsing #{file}"
      GetText.locale = "en"
      begin
        eval(open(file).read, TOPLEVEL_BINDING)
      rescue
        $stderr.puts _("Ignored '%{file}'. Solve dependencies first.") % {:file => file}
        $stderr.puts $!
      end
      loaded_constants = ActiveRecord::Base.active_record_classes_list
      ActiveRecord::Base.reset_active_record_classes_list
      loaded_constants.each do |classname|
        klass = eval(classname, TOPLEVEL_BINDING)
        if klass.is_a?(Class) && klass < ActiveRecord::Base
          log "processing class #{klass.name}"
          unless (klass.untranslate_all? || klass.abstract_class?)
            add_target(targets, file, ActiveSupport::Inflector.singularize(klass.table_name.gsub(/_/, " ")))
            unless klass.class_name == classname
              add_target(targets, file, ActiveSupport::Inflector.singularize(classname.gsub(/_/, " ").downcase))
            end
            begin
              klass.columns.each do |column|
                unless untranslate_column?(klass, column.name)
                  if @config[:use_classname]
                    msgid = classname + "|" +  klass.human_attribute_name(column.name)
                  else
                    msgid = klass.human_attribute_name(column.name)
                  end
                  add_target(targets, file, msgid)
                end
              end
            rescue
              $stderr.puts _("No database is available.")
              $stderr.puts $!
            end
          end
        end
      end
      if RubyParser.target?(file)
        targets = RubyParser.parse(file, targets)
      end
      targets.uniq!
      targets
    end

  end
end

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

# based on GetText.update_pofiles
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
  task :updatepo => :environment do
    require 'gettext/utils'
    puts "Updating translation files for gettext domain #{gettext_domain}"
    orig_msgmerge = ENV["MSGMERGE_PATH"] || "msgmerge"
    ENV["MSGMERGE_PATH"] = "#{orig_msgmerge} --no-fuzzy-matching"
    source_files = Dir.glob(["{app,lib,plugins}/**/*.{rb,erb,rjs,rhtml}", "plugins/**/**/*.{rb,erb,rjs,rhtml}"])
    lang = ENV['lang']
    if lang.nil?
      fail "Use lang={language to process} or lang=all to process po-files for all languages."
    else
      # will work in gettext-1.94
      # options = {:msgmerge => [:no_wrap, :no_fuzzy_matching, :sort_output]}
      # options[:lang] = lang if lang != 'all'
      # options[:verbose] = true
      # puts options.inspect
      # GetText.update_pofiles(gettext_domain, source_files, app_version, options)

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