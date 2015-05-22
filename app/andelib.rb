require 'rubygems'
require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/andelib.db")

class Users
  include DataMapper::Resource
  property :id,           	Serial
  property :surname,        String, :required => true 
  property :firstname,      String, :required => true
  property :email,         	String, :required => true
  property :password,       String, :required => true
  has n, :rent

end

class Rent
  include DataMapper::Resource
  property :id,           Serial
  property :date,         DateTime, :required => true
  property :description,  String, :required => true
  belongs_to :users 
  belongs_to :book
end

class Book
  include DataMapper::Resource
  property :id,           Serial
  property :author,         String, :required => true
  property :title,        String, :required => true
  property :category,         String, :required => true
  property :synopsis,         String, :required => true
end



DataMapper.finalize
DataMapper.auto_upgrade!

configure do
  enable :sessions
end

get '/' do
  @user = Users.get(session[:id])
	erb :index
end

post '/login' do
  @user = Users.first(email: params[:email], password: params[:password])
  if @user
    session[:id] = @user.id
    session[:name] = "#{@user.firstname} #{@user.surname}"
    puts session[:id]
    puts session[:name]
    redirect to '/'
  else
    redirect to("/signup")
  end
end

get '/library' do
	erb :library
end

get '/new' do
  erb :new
end

get '/rent' do
  @books = Book.all
	erb :rent
end

post '/rent' do
  @user = Users.get(session[:id])
  @book = Book.get(params[:title])
  rent = Rent.create(description: params[:description], date: params[:date], book_id: @book.id, users_id: @user.id)
  rent.save
  redirect('/')
end

get '/signin' do
	erb :signin
end

get '/logout' do
  session.clear
  redirect to('/')
end

get '/signup' do
	erb :signup
end

post '/signup' do
	user = Users.create(:firstname => params[:firstname], :surname => params[:surname], :email => params[:email], :password => params[:password])
	redirect '/signin'
end
