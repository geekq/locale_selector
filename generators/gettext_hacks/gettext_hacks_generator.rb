class GettextHacksGenerator < Rails::Generator::Base

  def initialize(*runtime_args)
    super(*runtime_args)
  end

  def manifest
    record do |m|
      m.directory File.join('config/initializers')

      m.template 'gettext_hacks.rb',   File.join('config/initializers', "gettext_hacks.rb")
    end
  end

end