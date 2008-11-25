module GetText
  def gettext(msgid)
    esc_html sgettext(msgid, nil)
  end

  def esc_html(txt)
    txt.gsub(/\"|\>|\&|\</) {|ptrn| {'"' => '&#34;', '>' => '&#62;', '<' => '&#60;', '&' => '&#38;'}[ptrn] }
  end

  alias :_ :gettext
  module_function :_, :esc_html
end

module ActiveRecord
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

