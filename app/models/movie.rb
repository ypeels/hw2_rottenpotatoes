class Movie < ActiveRecord::Base
  # HW2-2
  def Movie.all_ratings
    ['G', 'PG', 'PG-13', 'R']
  end
end
