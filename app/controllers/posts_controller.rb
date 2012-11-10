class PostsController < ApplicationController
  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
    session[:oauth] = Koala::Facebook::OAuth.new('379518442129211','adef32a3dca86f207a151dc9226f3f80',callback_url)
    @auth_url = session[:oauth].url_for_oauth_code(:permissions=>["read_stream","publish_stream"]) 
  end
  def callback
    session[:access_token] = session[:oauth].get_access_token(params[:code])
    redirect_to session[:access_token] ? new_post_path : root_path
  end
  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])

    @graph = Koala::Facebook::API.new(session[:access_token])
    @face = @graph.put_connections("me", "notes",:subject => @post.title,:message =>@post.content)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
end
