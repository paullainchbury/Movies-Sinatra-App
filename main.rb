require 'pry-byebug'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'
require 'httparty'
require 'json'


get '/' do
  erb :home
end

get '/get_movie_from_omdb' do
  
  @movie_name = params[:movie_name].to_s

  if !(get_from_db(@movie_name)) then
  @movie_name = @movie_name.to_s.gsub(' ', '+')
  @movie = HTTParty.get("http://www.omdbapi.com?t=#{@movie_name}")
  @movie = JSON(@movie)
  unhash(@movie)
  else
  @movie = get_from_db(@movie_name)
  binding.pry
end

  erb :home
end


# def db_query(movie_name)
#   if (run_sql("SELECT * FROM movies WHERE title='#{movie_name}'") == nil)
#     return false
#   else
#     return true
#   end
# end



def unhash(movie)

  @title = movie['Title']
  @poster = movie['Poster']
  @year = movie['Year']
  @rated = movie['Rated']
  @released = movie['Released']
  @runtime = movie['Runtime']
  @genre = movie['Genre']
  @director = movie['Director']
  @writers = movie['Writer']
  @actors = movie['Actors']
  @plot = movie['Plot']

  @statement = "INSERT INTO movies (title, poster, year, rated, released, runtime, genre, director, writers, actors, plot) VALUES ('#{@title}', '#{@poster}', '#{@year}', '#{@rated}', '#{@released}', '#{@runtime}', '#{@genre}', '#{@director}', '#{@writers}', '#{@actors}', '#{@plot}')"

  run_sql(@statement)
  # binding.pry

  end



  def get_from_db(movie)

     return run_sql("SELECT * FROM movies WHERE title='#{movie}'").first

  end








# post '/create' do
#   item = params[:item]
#   details = params[:details]

#   sql = "INSERT INTO movies (item, details) VALUES ('#{item}', '#{details}')"

#   run_sql(sql)

#   redirect to('/')
# end

# get '/show/:id' do
#   sql = "SELECT * FROM movies WHERE id=#{params[:id]}"
  
#   @item = run_sql(sql).first

#   erb :show
# end

def run_sql(sql)
  conn = PG.connect(dbname: 'movies', host: 'localhost')
  
  begin
    result = conn.exec(sql)
  ensure
    conn.close
  end

  result
end


# @movies = run_sql("SELECT * FROM movies")