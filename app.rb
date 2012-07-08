# encoding: utf-8

require 'sinatra'
require 'slim'
require 'pp'
require 'twitter_oauth'

# enable session
set :session, true

configure do
  use Rack::Session::Cookie, :secret => Digest::SHA1.hexdigest(rand.to_s)
  KEY = "AOOliBzn6jcBHl6QKv5vPg"
  SECRET = "d7TgIkD9yO3E3nNlKkm9HPIERkpD3aZqf5eAhwf6Ys"
end

configure :production do
  BASE_URL="http://renadev.com:11080"
end

configure :development do
  BASE_URL = "http://localhost:4567"
end

helpers do
  def page_title
    title = @page_title
    title
  end
end

# load models
( Dir::glob("models/*.rb") ).each do |model|
  require model
end

before do
  @twitter = TwitterOAuth::Client.new(
                                      :consumer_key => KEY,
                                      :consumer_secret => SECRET,
                                      :token => session[:access_token],
                                      :secret => session[:secret_token],
                                      )
end

def base_url
  return BASE_URL
end

get '/' do
  if session[:login]
    @screen_name = @twitter.info['screen_name']
    @image_url = @twitter.info['profile_image_url_https']
    @page_title = "nzim"
    slim :index
  else
    @page_title = "ログイン"
    slim :login
  end
end

get '/login' do
  callback_url = "#{base_url}/oauth"
  request_token = @twitter.request_token(
                                         :oauth_callback => callback_url
                                         )

  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url.gsub('authorize', 'authenticate')
end

get '/oauth' do
  begin
    @access_token = @twitter.authorize(
                                       session[:request_token],
                                       session[:request_token_secret],
                                       :oauth_verifier => params[:oauth_verifier]
                                       )
  rescue OAuth::Unauthorized
  end

  if @twitter.authorized?
    session[:access_token] = @access_token.token
    session[:secret_token] = @access_token.secret
    session[:login] = true
    redirect "#{base_url}/"
  else
    @page_title = "oauth エラー"
    slim :error
  end
end

get '/logout' do
  @twitter = nil
  session.clear
  redirect '/'
end
