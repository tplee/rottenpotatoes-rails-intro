class MoviesController < ApplicationController

  # See Section 4.5: Strong Parameters below for an explanation of this method:
  # http://guides.rubyonrails.org/action_controller_overview.html
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
#  before_filter :load_ratings
  
  def index
      @all_ratings=Movie.all_ratings
      sort = params[:sort] || session[:sort] #get params or session

      ratings = params[:ratings] #get raitings params
      # if nil, store all ratings, else grab the keys
      ratings = ratings.nil? ? Movie.all_ratings : ratings.keys 

      @selected_ratings = params[:ratings] || session[:ratings] || {}
      if @selected_ratings == {}
         @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
      end
      
      #compare the session to current params
      if params[:ratings] != session[:ratings] or params[:sort] != session[:sort]
        session[:sort] = sort #if not equal use non-nil val from above
        session[:ratings] = @selected_ratings #grab selsected ratings
        redirect_to :sort => sort, :ratings => @selected_ratings and return
      end

      if params[:sort].present?
        if sort == 'title'
          @movies = Movie.where('rating IN (?)', ratings).order('title')
        elsif sort == 'release_date'
          @movies = Movie.where('rating IN (?)', ratings).order('release_date')
        end
      else
        @movies = Movie.where('rating IN (?)', ratings)
      end
  end
  
#  def load_ratings
#    
#  end
  
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

  private :movie_params
  
end
