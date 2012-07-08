#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
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

before do
    @twitter = TwitterOAuth::Client.new(
        :consumer_key => KEY,
        :consumer_secret => SECRET,
        :token => session[:access_token],
        :secret => session[:secret_token],
    )
end

def base_url
    default_port = (request.scheme == "http") ? 80 : 443
    port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
    return  "#{request.scheme}://#{request.host}#{port}"
end

get '/' do
  if session[:login]
    @screen_name = @twitter.info['screen_name']
    @image_url = @twitter.info['profile_image_url_https']
    slim :index
  else
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
        p session[:request_token],
          session[:request_token_secret],
          params[:oauth_verifier]
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
        redirect '/'
    else
        slim :error
    end
end

get '/logout' do
    @twitter = nil
    session.clear
    redirect '/'
end
