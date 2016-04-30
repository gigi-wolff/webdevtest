require "pry"
require "redcarpet"
require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

def valid_credentials?
  message = ""
  message = " first name," if params[:first_name] == ""
  message += " last name," if params[:last_name] == "" 
  message += " card number must be 16 digits, " if params[:card_number].size != 16 
  message += " expiration date," if params[:exp_date] == "" 
  message += " cvv " if params[:cvv] == ""
  message.empty? ? nil : message.chop!
end

helpers do
  def show_card_number(card_number)
    card_number.slice(0..3) + "-****-****-****"
  end

  def show_date(exp_date)
    #mmyyyy
    exp_date.slice(0..1)+"/"+ exp_date.slice(2..5)
  end
end

get "/" do
  redirect "/payments/create"
end

get "/payments/create" do
  erb :home
end

#grab input from sign in page
post "/payments/create" do  
  error = valid_credentials?

  if error
    session[:message] = "Please fix: #{error}"
    status 422
    erb :home 
  else
    session[:first_name]= params[:first_name]
    session[:last_name] = params[:last_name]
    session[:card_number] = params[:card_number]
    session[:exp_date] = params[:exp_date]
    session[:cvv] = params[:cvv]
    session[:message] = "Thank you for your payment."
    redirect "/payments"
  end
end

get "/payments" do
  erb :payments
end

