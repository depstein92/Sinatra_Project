require "sinatra"
require "sinatra/activerecord"
require "./models"
#this is needed for sinatra flash
require "bundler/setup"
require "sinatra/flash"
require 'pp'


set :database, "sqlite3:HQ.sqlite3"
enable :sessions

before do
  current_user
end

get "/" do
"Hello World"
erb :home
end

get "/music" do
erb :music
end

get "/videos" do
erb :videos
end

get "/photos" do
erb :photos
end

# Includes instance method for all Users
get "/directory" do
  @users = User.all
erb :directory
end

# get "/user/:id" do
#   @user  = params[:id]
# erb :user
# end

# ========= Allows user to create username and profile ==========
get '/new_account' do
  erb :new_account
end

post '/new_account' do
  @user = User.create(
    fname: params[:fname],
    lname: params[:lname],
    user_name: params[:user_name],
    password: params[:password]
  )

  @profile = Profile.create(
    user_id: @user.id,
    city: params[:city]
  )

  @user.profile = @profile

  session[:user_id] = @user.id
  redirect '/'
end

#==========
get "/profile/:id" do

  erb :user_profile
end

get '/user-profile' do
  @user_profile = Profile.find_by(user_id:session[:user_id])
  @profile = Profile.all
  erb :user_profile
end
# ========= Allows users to post ============
get '/user-posts' do
  erb :user_posts
end

# Instance variable "post", shows 10 recent posts
get "/posts" do
  @posts = Post.all
  @latest_posts = Post.all.last(10)
  erb :posts
end

post '/posts' do
  @post =  Post.new(params[:post])
  @post.user = @current_user
  @post.save
  redirect '/posts'
end
# ========= Sign up and Sign in ===========
get "/sign-up" do
  erb :sign_up
end

get "/sign-in" do
  erb :sign_in_form
end

# Allows user to sign in
post '/sign-in' do
  @user = User.where(user_name: params[:user_name]).first
  if @user && @user.password == params[:password]
    session[:user_id] = @user.id
    flash[:notice] = "You've been signed in successfully"
    redirect '/'
  else
    flash[:notice] = "There was an issue signing you in"
   end
   redirect "/"
 end

get "/sign-out" do
  session[:user_id] = nil
  redirect "/"
end

# Tracks users activity while logged in
def current_user
  if session[:user_id]
    @current_user = User.find(session[:user_id])
  end
end

# Deletes a user
post '/delete_profile' do
  session[:user_id] = nil
	@current_user.destroy
  flash[:notice] = "Your account has been deleted"
	redirect '/'
end

get '/edit_user' do
  @current_user.update
  erb :edit_user
end

# update post
post '/user_profile' do
	@current_user.update(
  fname: params[:fname],
  lname: params[:lname],
  user_name: params[:user_name],
  password: params[:password]
  )
	@current_user.save
	redirect '/'
end

get '/user/:id' do
  @user = User.find(params[:id])
  pp(@user)
  # @post = User.post
  erb :user
end



# user = User.find_by(user_id:])
# user.destroy

# get "/user_create" do
#     User.create(user_name:"LeiMafia", password:"goaway92",  fname:"Leila", lname:"Mafoud")
# end

# get "/post_create" do
#   Post.create(title: "Bowery Electric", date: "1/21/2017", user_id: "12345")
# end

# post '/MyProfile' do
#   @profiles =  Profile.create(params[:profile])
#   session[:user_id] = @profiles.id
#   redirect '/'
# end
