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
  licenses.html
  LICENSES
  package.json
  resources
)

Bundler.require

desc "Setup development environment"
task :setup do |t|
  puts "=> Initializing Submodules..."
  execute 'git', 'submodule', 'update', '--init'
  node_webkit_dir = File.join(ROOT_DIR, 'node-webkit')
  FileUtils.mkpath node_webkit_dir

  Dir.chdir node_webkit_dir do
    %w(osx win).each do |arch|
      puts "=> Downloading node-webkit #{NODE_WEBKIT_VERSION} for #{arch}..."
      filename = "node-webkit-v#{NODE_WEBKIT_VERSION}-#{arch}-ia32.zip"
      execute 'curl', "https://s3.amazonaws.com/node-webkit/v#{NODE_WEBKIT_VERSION}/#{filename}", '-o', filename
      dir = File.join(NODE_WEBKIT_VERSION, arch)
      FileUtils.mkdir_p dir
      execute 'unzip', filename, '-d', dir
      if arch == 'osx'
        execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Info.plist'), File.join(dir, 'node-webkit.app', 'Contents')
        execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Icon.icns'),  File.join(dir, 'node-webkit.app', 'Contents', 'Resources')
        execute 'rm', '-f', File.join(dir, 'node-webkit.app', 'Contents', 'Resources', 'nw.icns')
      end
    end
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
  execute "node-webkit/#{NODE_WEBKIT_VERSION}/osx/node-webkit.app/Contents/MacOS/node-webkit", File.join(BUILD_DIR, @target, 'osx')
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
      @config_json ||= config_json
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

    %w(osx win).each do |arch|
      FileUtils.mkpath File.join(BUILD_DIR, @target, arch, prefix)
      asset.write_to File.join(BUILD_DIR, @target, arch, prefix, bundle)
    end
  end
end

task :build => [:clean, :compile] do
  app_version = config_json['app_version']
  %w(osx win).each do |arch|
    puts "=> Building #{@target} for #{arch}..."
    compiled_dir = File.join ROOT_DIR, BUILD_DIR, @target, arch
    target_dir = compiled_dir
    FileUtils.mkpath target_dir

    node_webkit_dir = File.join(ROOT_DIR, 'node-webkit', NODE_WEBKIT_VERSION, arch)

    if @target == 'production'
      if arch == 'osx'
        node_webkit_app_dir = File.join(node_webkit_dir, 'node-webkit.app')
        execute 'cp', '-RP', node_webkit_app_dir, target_dir
        app_dir = File.join(target_dir, 'Nitrous Desktop.app')
        execute 'mv', File.join(target_dir, 'node-webkit.app'), app_dir

        resources_dir = File.join(target_dir, 'Nitrous Desktop.app', 'Contents', 'Resources')
        compiled_dir = File.join(resources_dir, 'app.nw')
      elsif arch == 'win'
        %w(nw.exe nw.pak icudt.dll libEGL.dll libGLESv2.dll).map { |f| File.join(node_webkit_dir, f) }.each { |f| execute 'cp', f, target_dir }
        compiled_dir = File.join(target_dir, 'app')
      end
    end

    FileUtils.mkpath compiled_dir

    modules_dir = File.join(compiled_dir, 'node_modules')
    FileUtils.mkpath modules_dir

    # copy some other required files
    execute 'cp', '-RP', File.join(VENDOR_DIR, 'app-path'), modules_dir

    # copy programs
    execute 'cp', '-RP', File.join(VENDOR_DIR, 'programs', arch), File.join(compiled_dir, 'programs')

    if arch == 'osx'
      # copy fsevents module
      fsevents_dir = File.join(modules_dir, 'fsevents')
      fsevents_release_dir = File.join(fsevents_dir, 'build', 'Release')
      FileUtils.mkpath fsevents_release_dir
      %w(fsevents.js LICENSE package.json).each do |file|
        execute 'cp', File.join(VENDOR_DIR, 'fsevents', file), fsevents_dir
      end
      execute 'cp', File.join(VENDOR_DIR, 'fsevents', 'build', 'Release', 'fswatch.node'), fsevents_release_dir
    end

    # copy other resources
    @resources.each do |resource|
      execute 'cp', '-RP', File.join(SOURCE_DIR, resource), compiled_dir
    end
    execute 'sed', '-i', '', '-e', "s|APP_VERSION|#{app_version}|g", File.join(compiled_dir, 'package.json')

    # copy font-awesome fonts
    execute 'cp', '-RP', File.join(VENDOR_DIR, 'font-awesome', 'font'), compiled_dir

    if @target == 'production'
      execute "find '#{compiled_dir}' -name .DS_Store | xargs -I $ rm -f $"
      execute 'mv', File.join(target_dir, 'javascripts'), compiled_dir
      execute 'mv', File.join(target_dir, 'stylesheets'), compiled_dir

      if arch == 'osx'
        # modify version string in Info.plist
        info_plist_path = File.join(app_dir, 'Contents', 'Info.plist')
        execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Info.plist'), info_plist_path
        execute 'sed', '-i', '', '-e', "s|APP_VERSION|#{app_version}|g", info_plist_path

        # copy osx app icon
        execute 'cp', '-f', File.join(ROOT_DIR, SOURCE_DIR, 'Icon.icns'), resources_dir
        execute 'rm', '-f', File.join(resources_dir, 'nw.icns')

        # codesign
        sig = 'C8A9B7D71AF2234D0542582FE4461EF1E9D403F1'
        execute 'codesign', '-f', '-v', '-s', sig, File.join(compiled_dir, 'programs', 'nitrous-update.sh')
        execute 'codesign', '-f', '-v', '-s', sig, File.join(compiled_dir, 'programs', 'nitrous-unison.sh')
        execute 'codesign', '-f', '-v', '-s', sig, File.join(compiled_dir, 'programs', 'nitrous-unison')
        execute 'codesign', '-f', '-v', '-s', sig, File.join(compiled_dir, 'programs', 'seticon')
        execute 'codesign', '-f', '-v', '-s', sig, File.join(compiled_dir, 'node_modules', 'fsevents', 'build', 'Release', 'fswatch.node')
        execute "find '#{app_dir}' -name *.dylib | xargs -I $ codesign -f -v -s '#{sig}' $"
        execute "find '#{app_dir}' -name *.so | xargs -I $ codesign -f -v -s '#{sig}' $"
        execute 'rm', '-f', File.join(app_dir, 'Contents', 'Frameworks', 'node-webkit Framework.framework', 'node-webkit Framework.tmp')
        execute 'rm', '-f', File.join(app_dir, 'Contents', 'Frameworks', 'node-webkit Framework.framework', 'node-webkit Framework.TOC')
        execute 'codesign', '-f', '--deep', '-v', '-s', sig, app_dir
      elsif arch == 'win'
        filename = "NitrousDesktop-#{@target}-#{config_json['app_version']}"

        # copy unison out of programs folder and keep in under tools directory for license compliance
        tools_dir = File.join(target_dir, 'tools')
        FileUtils.mkpath tools_dir
        execute 'mv', File.join(compiled_dir, 'programs', 'nitrous-unison.exe'), tools_dir

        Dir.chdir compiled_dir do
          execute 'zip', '-r', File.join(target_dir, 'app.nw'), '.'
        end
        execute 'rm', '-rf', compiled_dir

        puts "=> build/#{@target}/#{filename}.zip"
      end
    end
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

def config_json
  @config_json ||= if json = JSON.parse(File.read(File.join(ROOT_DIR, 'config.json')))
    json = json[ENV['TARGET']]
    json['environment'] = ENV['TARGET']
    json['app_version'] = File.read(File.join(ROOT_DIR, 'VERSION')).strip
    json
  end
end
