require 'rubygems'
require 'bundler'
require 'fileutils'
require 'logger'
require 'pathname'
require 'json'

NODE_WEBKIT_VERSION = '0.8.4'
ROOT_DIR = File.expand_path(File.dirname(__FILE__))
LOGGER = Logger.new(STDOUT)
BUILD_DIR = "build"
SOURCE_DIR = "src/"
VENDOR_DIR = "vendor/"
SPEC_DIR = "spec/"
@target = ENV['TARGET'] ||= 'development'

@bundles = %w(
  application.css
  application.js
)

@resources = %w(
  favicon.ico
  index.html
  package.json
  resources
)

Bundler.require

desc "Setup development environment"
task :setup do |t|
  puts "=> Initializing Submodules..."
  execute 'git', 'submodule', 'update', '--init'
  puts "=> Downloading node-webkit #{NODE_WEBKIT_VERSION} for OS X..."
  node_webkit_dir = File.join(ROOT_DIR, 'node-webkit')
  FileUtils.mkpath node_webkit_dir

  Dir.chdir node_webkit_dir do
    filename = "node-webkit-v#{NODE_WEBKIT_VERSION}-osx-ia32.zip"
    execute 'curl', "https://s3.amazonaws.com/node-webkit/v#{NODE_WEBKIT_VERSION}/#{filename}", '-o', filename
    FileUtils.mkdir_p NODE_WEBKIT_VERSION
    execute 'unzip', filename, '-d', NODE_WEBKIT_VERSION
    execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Info.plist'), File.join(NODE_WEBKIT_VERSION, 'node-webkit.app', 'Contents')
    execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Icon.icns'),  File.join(NODE_WEBKIT_VERSION, 'node-webkit.app', 'Contents', 'Resources')
    execute 'rm', '-f', File.join(NODE_WEBKIT_VERSION, 'node-webkit.app', 'Contents', 'Resources', 'nw.icns')
  end

  puts "=> Compiling FSEvents native module..."
  Dir.chdir File.join(VENDOR_DIR, 'fsevents') do
    execute 'nw-gyp', 'configure', "--target=#{NODE_WEBKIT_VERSION}"
    execute 'nw-gyp', 'build'
  end
  puts "=> Done!"
end

desc 'Run app'
task :run do |t|
  if ENV['NO_BUILD'] != '1'
    Rake::Task["build"].invoke
  end
  puts "=> Running #{@target}..."
  execute "node-webkit/#{NODE_WEBKIT_VERSION}/node-webkit.app/Contents/MacOS/node-webkit", File.join(BUILD_DIR, @target)
end

desc 'Watch for changes'
task :watch => [:build] do |t|
  execute 'bundle exec guard start'
end

task :clean do
  puts "=> Cleaning #{@target}..."
  execute "rm -rf build/'#{@target}'"
end

desc 'Clean all'
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
  sprockets.context_class.class_eval do
    def config
      @config_json ||= load_config
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
  if @target == 'development'
    sprockets.append_path File.join(ROOT_DIR, SPEC_DIR)
  end

  bundles = @bundles
  if @target == 'development'
    bundles.concat %w(spec.html spec.js spec.css)
  end
  bundles.each do |bundle|
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
  FileUtils.mkpath compiled_dir

  if @target == 'production'
    node_webkit_app_dir = File.join(ROOT_DIR, 'node-webkit', NODE_WEBKIT_VERSION, 'node-webkit.app')
    execute 'cp', '-RP', node_webkit_app_dir, compiled_dir
    app_dir = File.join(compiled_dir, 'Nitrous Desktop.app')
    execute 'mv', File.join(compiled_dir, 'node-webkit.app'), app_dir

    target_dir = compiled_dir
    resources_dir = File.join(target_dir, 'Nitrous Desktop.app', 'Contents', 'Resources')
    compiled_dir = File.join(resources_dir, 'app.nw')
    FileUtils.mkpath compiled_dir
  end

  # copy fsevents module
  modules_dir = File.join(compiled_dir, 'node_modules')
  fsevents_dir = File.join(modules_dir, 'fsevents')
  fsevents_release_dir = File.join(fsevents_dir, 'build', 'Release')
  FileUtils.mkpath fsevents_release_dir
  %w(fsevents.js LICENSE package.json).each do |file|
    execute 'cp', File.join(VENDOR_DIR, 'fsevents', file), fsevents_dir
  end
  execute 'cp', File.join(VENDOR_DIR, 'fsevents', 'build', 'Release', 'fswatch.node'), fsevents_release_dir

  # copy other modules
  execute 'cp', '-RP', File.join(VENDOR_DIR, 'app-path'), modules_dir

  # copy programs
  execute 'cp', '-RP', File.join(VENDOR_DIR, 'programs'), compiled_dir

  # copy other resources
  @resources.each do |resource|
    execute 'cp', '-RP', File.join(SOURCE_DIR, resource), compiled_dir
  end

  # copy font-awesome fonts
  execute 'cp', '-RP', File.join(VENDOR_DIR, 'font-awesome', 'font'), compiled_dir

  if @target == 'production'
    #filename = "NitrousDesktop-#{@target}-#{load_config['app_version']}"
    #system "cd #{compiled_dir}; zip -r ../'#{filename}'.zip *"

    #puts "=> build/#{@target}/#{filename}.zip"

    execute 'mv', File.join(target_dir, 'javascripts'), compiled_dir
    execute 'mv', File.join(target_dir, 'stylesheets'), compiled_dir

    execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Info.plist'), File.join(app_dir, 'Contents')
    execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Icon.icns'), resources_dir
    execute 'rm', '-f', File.join(resources_dir, 'nw.icns')
  end
end

%w(development staging production).each do |target|
  desc "Build for #{target}"
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

def load_config
  if json = JSON.parse(File.read(File.join(ROOT_DIR, 'config.json')))
    json = json[ENV['TARGET']]
    json['environment'] = ENV['TARGET']
    json
  end
end
