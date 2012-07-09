# encoding: utf-8

require 'sinatra'
require 'warden'
require 'omniauth'
require 'omniauth-twitter'
require 'warden_omniauth'
require 'slim'
require 'pp'

# enable session
enable :sessions

# wardenの設定
Warden::Manager.serialize_into_session do |user|
  user
end
Warden::Manager.serialize_from_session do |user|
  user
end

use Warden::Manager do |config|
  config.failure_app = Sinatra::Application
  config.default_strategies :omni_twitter
end

use OmniAuth::Builder do
  provider :twitter, "AOOliBzn6jcBHl6QKv5vPg", "d7TgIkD9yO3E3nNlKkm9HPIERkpD3aZqf5eAhwf6Ys"
end

use WardenOmniAuth do |config|
  config.redirect_after_callback = "/warden/callback"
end

helpers do
  def warden
    request.env["warden"]
  end

  def current_user
    warden.user
  end

  def page_title
    title = @page_title
    title
  end
end

configure :production do
  BASE_URL="http://renadev.com:11080"
end

configure :development do
  BASE_URL = "http://localhost:4567"
end

# load models
# ( Dir::glob("models/*.rb") ).each do |model|
#   require model
# end

def base_url
  return BASE_URL
end

get '/' do
  @page_title = "ログイン"
  slim :login
end

get '/warden/callback' do
  slim :index
end

get '/auth/:provider/callback' do
  slim :index
end


get '/logout' do
  request.env['warden'].logout
  redirect '/'
end

get '/auth/failure' do
  params[:message]
end
