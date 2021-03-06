class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    # HW2-3 error checking: initialize session. ALWAYS ok to do this, right?
    if params[:sort] then session[:sort] = params[:sort] end
    if params[:ratings] then session[:ratings] = params[:ratings] end
    
    # if user has no requested value, revert to the saved value if it exists
    # (annoying? can't disable sort, even via URI)
    if session[:sort] && !params[:sort]
      flash.keep # for user notifications
      redirect_to movies_path(:sort => session[:sort], :ratings => params[:ratings])
      return
    end
    if session[:ratings] && !params[:ratings]
      flash.keep # for user notifications
      redirect_to movies_path(:ratings => session[:ratings], :sort => params[:sort])
      return
    end
  
    # initial value for hash shared by HW2-1 (title/date sort) and HW2-2 (rating filter)
    options = {}
    #fresh_index = !params[:sort] && !params[:ratings]
    
    # this all doesn't look very good, since all my code is in the CONTROLLER (Movie itself is pretty barren)
    # idea (2012-10-15): move as much as possible into Movie model?!
    # - but what about all these instance variables that live in MoviesController??
    # - just WHAT is accessible in the model?
    
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

    # HW2-2 - initialize horrible instance variable...a "hidden state variable", if you will...
    @rating_checked = {}
    
    # HW2-2 special case: initialize with all ratings checked.
    #if fresh_index
    # HW2-3 modified to simply check all ratings if none were checked, more generally
    if params[:ratings] == nil
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
