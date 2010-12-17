$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), 'lib')

require 'rubygems'
require 'bundler/setup'

# libs
require 'sinatra'
require 'erector'
require 'curl'
require 'json'

# views
require 'auth'
require 'timeline'

require 'instasite'
run Instasite.new
