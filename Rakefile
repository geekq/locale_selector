require 'rake'
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
  rdoc.rdoc_files.include('generators/gettext_hacks/templates/gettext_hacks.rb')
end

desc 'Publish the home page'
task :publish => :rerdoc do
  `scp -r rdoc/* vd@www.innoq.com:/home/vd/public_html/locale_selector`
end
