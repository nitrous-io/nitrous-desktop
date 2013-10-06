require 'rubygems'
require 'bundler'
require 'fileutils'
require 'logger'
require 'pathname'

NODE_WEBKIT_VERSION = '0.7.5'
ROOT_DIR = File.expand_path(File.dirname(__FILE__))
LOGGER = Logger.new(STDOUT)
BUILD_DIR = "build"
SOURCE_DIR = "src/"
VENDOR_DIR = "vendor/"
@target = ENV['TARGET'] || 'development'

BUNDLES = %w(
  application.css
  application.js
)

RESOURCES = %w(
  favicon.ico
  index.html
  package.json
  resources
)

Bundler.require

desc "Download node-webkit v#{NODE_WEBKIT_VERSION}"
task :dl do |t|
  FileUtils.mkdir_p 'node-webkit'
  Dir.chdir 'node-webkit' do
    filename = "node-webkit-v#{NODE_WEBKIT_VERSION}-osx-ia32.zip"
    execute 'curl', "https://s3.amazonaws.com/node-webkit/v#{NODE_WEBKIT_VERSION}/#{filename}", '-o', filename
    execute 'unzip', filename
  end
end

desc 'Run app'
task :run => [:build] do |t|
  puts "=> Running #{@target}..."
  execute 'node-webkit/node-webkit.app/Contents/MacOS/node-webkit', File.join(BUILD_DIR, @target)
end

task :clean do
  puts "=> Cleaning #{@target}..."
  execute "rm -rf build/'#{@target}'"
end

desc 'clean all'
task :clean_all do
  puts '=> Cleaning all...'
  execute "rm -rf build/*"
  execute "rm -rf tmp/*"
end

task :compile do
  puts "=> Compiling #{@target}..."

  sprockets = Sprockets::Environment.new(ROOT_DIR) do |env|
    env.logger = LOGGER

    if @target == 'production'
      env.js_compressor = Closure::Compiler.new
      env.css_compressor = YUI::CssCompressor.new
    else
      env.cache = Sprockets::Cache::FileStore.new("tmp/sprockets/#{@target}")
    end
  end

  # integrate emblem
  Emblem::Sprockets.integrate sprockets

  sprockets.append_path File.join(ROOT_DIR, SOURCE_DIR)
  sprockets.append_path File.join(ROOT_DIR, SOURCE_DIR, 'javascripts')
  sprockets.append_path File.join(ROOT_DIR, SOURCE_DIR, 'templates')
  sprockets.append_path File.join(ROOT_DIR, SOURCE_DIR, 'stylesheets')

  # use ember and handlebars from gems
  sprockets.append_path Ember::Source.bundled_path_for('')
  sprockets.append_path File.dirname(Handlebars::Source.bundled_path)

  sprockets.append_path File.join(ROOT_DIR, VENDOR_DIR)

  BUNDLES.each do |bundle|
    asset = sprockets.find_asset(bundle)
    prefix = asset.pathname.to_s.split('/')[-2]

    if prefix == 'src'
      prefix = ''
    end

    FileUtils.mkpath File.join(BUILD_DIR, @target, prefix)
    asset.write_to File.join(BUILD_DIR, @target, prefix, bundle)
  end
end

task :build => [:clean, :compile] do
  puts "=> Building #{@target}..."
  compiled_dir = File.join BUILD_DIR, @target
  # copy other resources
  RESOURCES.each do |resource|
    execute 'cp', '-r', File.join(SOURCE_DIR, resource), compiled_dir
  end

  # copy font-awesome fonts
  #execute 'cp', '-r', 'vendor/font-awesome/font', compiled_dir

  #if @target == 'production'
    #filename = "NitrousIOPackagedApp-#{@target}-#{load_config['app_version']}"
    #system "cd #{compiled_dir}; zip -r ../'#{filename}'.zip *"

    #puts "=> build/#{@target}/#{filename}.zip"
  #end
end

%w(development staging production).each do |target|
  desc "build for #{target}"
  task target do
    @target = ENV['TARGET'] = target
    Rake::Task["build"].invoke
  end
end

task :default => [:run]

def execute(*args)
  puts args.join(' ')
  system(*args)
end
