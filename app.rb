require 'sinatra'
require 'sinatra/reloader'
require "sinatra/cookies"
require "pg"

enable :sessions

client = PG::connect(
  :host => "localhost",
  :user => 'e165726', :password => '',
	:dbname => "myapp")

get '/' do
  @visiter = params[:name]
  erb :hello, :layout => :layout
end

get '/hello' do
  'Hello world!!'
end

get '/hello/:id' do
  html = "<h1>Hello #{params[:name]}!</h1>"
  html += "<h2>Your Number is #{params[:id]}!</h2>"
  html
end

get '/user/:name' do
  "<h1> Hello!, #{params[:name]}</h1>"
end

# optional 変数は'?'をつける
get '/kanekou/:last_name/:first_name?' do
  html = "<h1> #{params[:last_name]}"
  html += "<h1> #{params[:first_name]}"
  html
end

get '/check_even/:number' do
  @number = params[:number].to_i
  erb :check_even
end

get '/form' do
  erb :form
end

post '/form_output' do
  @name = params[:name]
  @email = params[:email]
  @content = params[:content]

  erb :form_output
end

get '/upload' do
  @images = Dir.glob("./public/image/*").map{|path| path.split('/').last }
  erb :upload
end

post '/upload' do
  @filename = params[:file][:filename]
  tmp = params[:file][:tempfile]

  FileUtils.mv(tmp, "./public/image/#{@filename}")

  erb :upload_output
end

get '/cookie' do
  cookies[:name] = 'kanekou'
	cookies[:accessed_at] = '2019-05-16'

  erb :cookie
end

get '/cookie_check' do
  erb :cookie_check
end

get '/session' do
  session[:name] = 'kanekou'
	session[:accessed_at] = '2019-05-16'

  erb :session
end

get '/session_check' do
  erb :session_check
end

get '/login' do
	session[:name] = nil
	erb :login
end

post '/login' do
  name = params[:name]
  password = params[:password]

	users = client.exec_params('select * from users')

	users.each do |user|
		if user['name'] == name && user['password'] == password
			session[:name] = name
		end
	end

	redirect to ('/login') if session[:name].nil?
  redirect to ('/mypage')
end

get '/mypage' do
	erb :mypage
end

get '/signup' do
	erb :signup
end

post '/signup' do
  name = params[:name]
  email = params[:email]
  password = params[:password]
  client.exec_params('INSERT INTO users (name, email, password) VALUES ($1,$2,$3)', [name, email, password])

  session[:name] = name

  redirect to('/mypage')
end