class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
  
    # INITIALIZE to default: all movies (inefficient, because of re-query? meh)
    @movies = Movie.all
    
    # HW 2-1B params[:sort] from index.html.haml
    # figured out what to do from rdb + Google!
    # http://apidock.com/rails/ActiveResource/Base
    if params[:sort]      
      if params[:sort] == "title"
        @movies = Movie.order("title")
        @title_hilite = "hilite"
      elsif params[:sort] == "release_date"
        @movies = Movie.order("release_date")
        @date_hilite = "hilite"
      else
        # no, this persists one screen too many; don't feel like figuring out refresh logic...
        # flash[:warning] = "Error: unsupported sort type: " + params[:sort]
        Rails.logger.warn "Error: unsupported sort type: " + params[:sort]
      end
    end
    
    # HW2-2 - pump possible ratings from Model (app/models/movie.rb) to View
    @all_ratings = Movie.all_ratings
    
    # HW2-2 - "Refresh" clicked with at least one rating checked    
    @rating_checked = {}
    if params[:ratings] != nil
      all_checked_ratings = params[:ratings].keys
      
      # persist checks after Refresh...(hmmm)
      all_checked_ratings.each { |rating| @rating_checked[rating] = true }

      # display only movies with checked ratings      
      @movies = Movie.find( :all, :conditions => {:rating => all_checked_ratings} )
     # debugger
#      @movies = []
#      params[:ratings].keys.each do |rating| 
#        @movies << Movie.find(:all, :conditions => { :rating => "#{rating}" } )
#      end
     


    else
      # boundary case: toggle all checkboxes by default (or if all unchecked
      @all_ratings.each { |rating| @rating_checked[rating] = true }
    end
    
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
