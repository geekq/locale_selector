SPEC = Gem::Specification.new do |s|
  s.name = 'locale_selector'
  s.version = '1.93.0'
  s.summary = 'Wraps and improves ruby-gettext, provides UI for locale selection, maintains user preferences.'
  s.description = s.summary
  s.author = 'Vladimir Dobriakov'
  s.email = 'vd_extern@vfnet.de'
  s.homepage = 'http://github.com/geekq/locale_selector'
  s.files = %w(MIT-LICENSE README.rdoc Rakefile TESTING.rdoc init.rb install.rb locale_selector.gemspec uninstall.rb) +
    ['generators/gettext_hacks/templates/gettext_hacks.rb',
    'generators/gettext_hacks/gettext_hacks_generator.rb',
    'lib/locale_selector.rb',
    'tasks/gettext.rake' ]

  Dir.glob("{generators,lib,tasks}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'TESTING.rdoc', 'MIT-LICENSE']
  s.rdoc_options = ['--line-numbers', '--inline-source', '--promiscuous', '--main', 'README.rdoc']
  s.add_dependency 'gettext', '1.93.0'
  s.rubyforge_project = 'locale_selector'
end
