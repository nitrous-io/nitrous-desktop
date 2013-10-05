require 'pathname'
require 'fileutils'

NODE_WEBKIT_VERSION = '0.7.5'

desc "Download node-webkit v#{NODE_WEBKIT_VERSION}"
task :dl do |t|
  FileUtils.mkdir_p 'node-webkit'
  Dir.chdir 'node-webkit' do
    filename = "node-webkit-v#{NODE_WEBKIT_VERSION}-osx-ia32.zip"
    system 'curl', "https://s3.amazonaws.com/node-webkit/v#{NODE_WEBKIT_VERSION}/#{filename}", '-o', filename
    system 'unzip', filename
  end
end

desc 'Run app'
task :run do |t|
  system 'node-webkit/node-webkit.app/Contents/MacOS/node-webkit', './src'
end

task :default => [:run]
