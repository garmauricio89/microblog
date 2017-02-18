require "sinatra"
require "sinatra/activerecord"
require "active_record"
require "./models"
require "sinatra/flash"



enable :sessions
set :database, "sqlite3:app.db"

# ============================================================
#   LANDING/HOME
# ============================================================
get "/" do
  if session[:user_id]
    redirect "/home"
  else
    erb :landing1
  end
end

# add in extra landing pages based on timestamp (dawn, morning, afternoon, dusk, night)

# ============================================================
#   SIGN-UP/SIGN-IN/SIGN-OUT
# ============================================================
get "/sign-up" do
  if session[:user_id]
    redirect "/home"
  else
    erb :sign_up
  end
end

post "/sign-up" do
  @user = User.create(
    name: params[:name],
    email: params[:email],
    password: params[:password]
  )
  session[:user_id] = @user.id

  redirect "/home"
end

get "/sign-in" do
  if session[:user_id]
    redirect "/home"
  else
    erb :sign_in
  end
end

post "/sign-in" do
  @user = User.where(email: params[:email]).first
  if @user && @user.password == params[:password]
    session[:user_id] = @user.id

    redirect "/home"
  else
    
    redirect "/"
  end
end

get "/sign-out" do
  session[:user_id] = nil

  redirect "/"
end

helpers do  
  def current_user
    if session[:user_id]
      @current_user = User.find(session[:user_id])
    end
  end
end

# ============================================================
#   HOME
# ============================================================
get "/home" do
  @posts = Post.all

  if session[:user_id]
    erb :home
  else
    redirect "/"
  end
end

# ============================================================
#   PROFILE
# ============================================================
# Current user profile
get "/profile" do
  @user = current_user
  @posts = current_user.posts
  
  erb :profile
end

# User profile
get "/profile/:id" do
  @user = User.find(params[:id])
  @posts = User.find(params[:id]).posts

  erb :profile
end

# ============================================================
#   SETTINGS
# ============================================================
get "/settings" do
  if session[:user_id]
    erb :settings
  else
    redirect "/"
  end
end

# Update current user info
post "/settings" do
  current_user.update(
  name: params[:name],
  email: params[:email],
  )
  # Update password if current password is correct
  if(current_user.password == params[:password] && params[:new_password].length > 0)
    current_user.update(
    password: params[:new_password]
    )

  end

  redirect back
end

# Delete user and posts 
post "/delete-account" do
  current_user.posts.destroy_all
  current_user.destroy
  session[:user_id] = nil
 
  redirect "/"
end

# ============================================================
#   WRITE
# ============================================================
get "/write" do
  if session[:user_id]
    erb :write
  else
    redirect "/"
  end
end

post "/write" do 
  Post.create(
    line1: params[:line1],
    user_id: current_user.id,
  
  )

  redirect "/profile"
end

