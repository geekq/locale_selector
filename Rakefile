require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the locale_selector plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the locale_selector plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'LocaleSelector'
  rdoc.options << '--line-numbers' << '--inline-source' << '--promiscuous' << '--main=README.rdoc'
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('TESTING.rdoc')
  rdoc.rdoc_files.include('generators/gettext_hacks/templates/gettext_hacks.rb')
end

spec = Gem::Specification.new do |s|
  s.name = 'locale_selector'
  s.version = '1.93.0'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'TESTING.rdoc', 'MIT-LICENSE']
  s.summary = 'Wraps and improves ruby-gettext, provides UI for locale selection, maintains user preferences.'
  s.description = s.summary
  s.author = 'Vladimir Dobriakov'
  s.email = 'vd_extern@vfnet.de'
  s.homepage = 'http://github.com/geekq/locale_selector'
  # s.executables = ['your_executable_here']
  s.files = %w(MIT-LICENSE README.rdoc Rakefile) + Dir.glob("{bin,lib}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
  s.add_dependency 'gettext', '1.93.0'
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

desc 'Publish the home page'
task :publish => :rerdoc do
  `scp -r rdoc/* vd@www.innoq.com:/home/vd/public_html/locale_selector`
end

