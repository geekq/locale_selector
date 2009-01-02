module GetText
  # Modification of the original gettext.
  #
  # By default all the translated texts from the po files are also html escaped
  # so translators can not break the application by introducing less-than
  # and ampersand characters or by trying to incorporate the <blink> tag ;-)
  #
  # It is possible though to turn this feature off for particular messages:
  # if msgid starts with '#no_html_escaping#' then the translation returned as is,
  # without html escaping.
  def gettext(msgid)
    translated = sgettext(msgid, nil)
    if msgid =~ /^#no_html_escaping#/
      translated
    else
      esc_html translated
    end
  end

  def esc_html(txt)
    txt.gsub(/\"|\>|\&|\</) {|ptrn| {'"' => '&#34;', '>' => '&#62;', '<' => '&#60;', '&' => '&#38;'}[ptrn] }
  end

  alias :_ :gettext
  module_function :_, :esc_html
end

module ActiveRecord # :nodoc:
  class Errors
    # We adjust the gettext so the inclusion of the field name must be done explicitely
    # with #{fn}. If it is omitted, then the field name is not included.
    # Originally it was 'append_field = true' so if there was no #{fn} then
    # the field name was appended at the beginning of the message - very
    # questionable behaviour.
    def localize_error_messages_with_better_default(append_field = false)
      localize_error_messages_without_better_default(append_field)
    end
    alias_method_chain :localize_error_messages, :better_default
  end
end

puts "Loading active_record parsing hacks in gettext_hacks.rb"
#require 'gettext/parser/active_record'
#module GetText
#  module ActiveRecordParser
#    def parse(file, targets = []) # :nodoc:
#      puts "Vladimir's ActiveRecordParser.parse"
#    end
#  end
#end