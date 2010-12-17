$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__), 'lib')

require 'rubygems'
require 'bundler/setup'

# libs
require 'sinatra'
require 'erector'
require 'em-http'
require 'json'
require 'instagram'
require 'rack/fiber_pool'

# views
require 'auth'
require 'timeline'

use Rack::FiberPool

require 'instasite'
run Instasite.new
