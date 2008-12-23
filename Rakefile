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

load File.join(File.dirname(__FILE__), 'locale_selector.gemspec')

desc 'Generate documentation for the locale_selector plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'LocaleSelector'
  rdoc.options  = SPEC.rdoc_options

  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('generators/gettext_hacks/templates/gettext_hacks.rb')
  rdoc.rdoc_files.include(SPEC.extra_rdoc_files)
end

Rake::GemPackageTask.new(SPEC) do |p|
  p.gem_spec = SPEC
  p.need_tar = true
  p.need_zip = true
end

desc 'Publish the home page'
task :publish => :rerdoc do
  sh 'scp -r rdoc/* geekq@rubyforge.org:/var/www/gforge-projects/locale-selector'
end

