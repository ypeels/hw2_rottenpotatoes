class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
  
    # initial value for hash shared by HW2-1 (title/date sort) and HW2-2 (rating filter)
    options = {}
    fresh_index = !params[:sort] && !params[:ratings]
    
    # this all doesn't look very good, since all my code is in the CONTROLLER (Movie itself is pretty barren)
    
    # HW 2-1B: sort by title or date
    # params[:sort] originally from index.html.haml
    # figured out what to do from rdb + Google!
    # http://apidock.com/rails/ActiveResource/Base
    if params[:sort] != nil
      if params[:sort] == "title"
        options[:order] = "title"
        @title_hilite = "hilite"
      elsif params[:sort] == "release_date"
        options[:order] = "release_date"
        @date_hilite = "hilite"
      else
        # no, this persists one screen too many; don't feel like figuring out refresh logic...
        # flash[:warning] = "Error: unsupported sort type: " + params[:sort]
        Rails.logger.warn "Error: unsupported sort type: " + params[:sort]
      end
    end


    # HW2-2 - instance variable to carry possible ratings from Model (app/models/movie.rb) to View
    @all_ratings = Movie.all_ratings  

    # HW2-2 - initialize horrible instance variable...
    @rating_checked = {}
    
    # HW2-2 special case: initialize with all ratings checked.
    if fresh_index
      @all_ratings.each { |rating| @rating_checked[rating] = true }
    end    
    
    # HW2-2 - "Refresh" clicked with at least one rating checked    
    if params[:ratings] != nil
      all_checked_ratings = params[:ratings].keys
      
      # persist checks after Refresh...(hmmm)
      all_checked_ratings.each { |rating| @rating_checked[rating] = true }

      # display only movies with checked ratings      
      options[:conditions] = {:rating => all_checked_ratings}
      
    end

    # one unified database query that combines HW2-1 (title or date sort) and HW2-2 (ratings filter)
    @movies = Movie.find(:all, options)
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
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
