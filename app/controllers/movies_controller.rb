class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    # redirect is set when session is used instead of param, and the url is redirected to the session values
    redirectF = 0
    # if the user chooses a sorting parameter, use that, else use the previous order stored in session. If session is used, then also set the redirect flag
    if params[:sort]
      @selection = params[:sort]
    else
      @selection = session[:sort]
    end
    if (params[:sort]==nil && session[:sort]!=nil)
      redirectF=1
    end
    
    if params[:sort]!= session[:sort]
      session[:sort]=@selection
    end
    # now that the instance variables are set to either param or session, they can be used
    if @selection == "title"
      @highlight_title = "hilite"
      @movies = Movie.all.order(@selection)
    elsif @selection == "release_date"
      @highlight_release_date = "hilite"
      @movies = Movie.all.order(@selection)
    else
      @movies = Movie.all
    end
    if params[:ratings]
      @ratings=params[:ratings]
      @movies=@movies.where(rating: @ratings.keys)
    else
      if session[:ratings]
        @ratings=session[:ratings]
        @movies=@movies.where(rating: @ratings.keys)
        redirectF=1 # since session is being used, the url will be redirected
      else
        @ratings=Hash[@all_ratings.collect {|rating| [rating, rating]}] #setting rating to all ratings as initially all boxes should be checked
        @movies=@movies
      end
    end
    #updating session according to chosen ratings
    if @ratings != session[:ratings]
      session[:ratings]=@ratings
    end
    #redirecting the url according to the values in the session variable
    if redirectF==1
      flash.keep
      redirect_to movies_path(sort: session[:sort],ratings: session[:ratings])
    end
  end
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
