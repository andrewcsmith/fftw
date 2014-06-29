require 'rake'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'rake/extensiontask'
require 'rdoc/task'
require 'bundler/gem_tasks'
require 'colorize'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
end
task :default => :spec

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

BASEDIR = Pathname( __FILE__ ).dirname.relative_path_from( Pathname.pwd )
SPECDIR = BASEDIR + 'spec'

gemspec = eval(IO.read("fftw.gemspec"))

Gem::PackageTask.new(gemspec).define
  desc "install the gem locally"
  task :install => [:package] do
    sh %{gem install pkg/fftw-#{FFTW::VERSION::STRING}.gem}
  end
  def run *cmd
    sh(cmd.join(" "))
  end
  namespace :clean do
    task :clean do |task|
      Dir['*~'].each {|fn| rm fn rescue nil}
        tmp_path = "tmp/#{RUBY_PLATFORM}/fftw/#{RUBY_VERSION}"
        chdir tmp_path do
        if RUBY_PLATFORM =~ /mswin/
          `nmake soclean`
        else
          mkcmd = ENV['MAKE'] || %w[gmake make].find { |c| system("#{c} -v >> /dev/null 2>&1") }
          `#{mkcmd} soclean`
        end
      end
    end
  end

  desc "Check the manifest for correctness".yellow
  task :check_manifest do |task|
    manifest_files  = File.read("Manifest").split
    git_files       = `git ls-files |grep -v 'spec/'`.split
    ignore_files    = %w{.gitignore .rspec}
    possible_files  = git_files - ignore_files
    missing_files   = possible_files - manifest_files
    extra_files     = manifest_files - possible_files
  unless missing_files.empty?
    STDERR.puts "The following files are in the git repo but not the Manifest:"
    missing_files.each { |f| STDERR.puts " -- #{f}"}
  end

  unless extra_files.empty?
    STDERR.puts "The following files are in the Manifest but may not be necessary:"
    extra_files.each { |f| STDERR.puts " -- #{f}"}
  end

  if extra_files.empty? && missing_files.empty?
    STDERR.puts "Manifest looks good!"
  end

  Rake::ExtensionTask.new("fftw") do |ext|
    ext.ext_dir = 'ext/fftw'
    ext.lib_dir = 'lib/fftw'
    ext.source_pattern = "**/*.{c,cpp,h}"
  end
end
RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include(%w{README.rdoc ChangeLog LICENSE.txt lib/*.rb ext/fftw/**/*.cpp ext/fftw/**/*.c ext/fftw/*.h})
end
