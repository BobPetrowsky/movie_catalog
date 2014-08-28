require "sinatra"
require "sinatra/reloader"
require "pg"
require "pry"

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

# def get_movies
#   offset = (@page_num - 1) * 20
#    query = 'SELECT movies.title, movies.year, movies.rating, movies.id, studios.name AS studio FROM movies JOIN studios ON movies.studio_id = studios.id ORDER BY movies.title LIMIT 20 OFFSET $1;'
#   db_connection do |conn|
#     conn.exec(query, [offset])
#   end
# end

def get_movie
  id = params[:id]
  query = 'SELECT movies.title, movies.year, movies.rating, movies.synopsis, genres.name AS genre, studios.name AS studio, actors.name AS actor, actors.id FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id JOIN cast_members ON movies.id = cast_members.movie_id JOIN actors ON cast_members.actor_id = actors.id WHERE movies.id = $1;'
  db_connection do |conn|
    conn.exec(query, [id])
  end
end

def get_genres
  query = 'SELECT genres.name, genres.id FROM genres;'
  db_connection do |conn|
    conn.exec(query)
  end
end

def get_movies_by_genre
  id = params[:id]
  query = 'SELECT movies.title, movies.year, movies.rating, movies.id, studios.name AS studio FROM movies JOIN studios ON movies.studio_id = studios.id JOIN genres ON movies.genre_id = genres.id WHERE genres.id = $1 ORDER BY movies.title LIMIT 20;'
  db_connection do |conn|
    conn.exec(query, [id])
  end
end

def get_actors
  query = 'SELECT actors.name AS name, actors.id FROM actors ORDER BY actors.name LIMIT 20;'
  db_connection do |conn|
    conn.exec(query)
  end
end

def get_actor
  id = params[:id]
  query = 'SELECT actors.name, actors.id, movies.title AS movie, cast_members.character AS character, movies.id FROM actors JOIN cast_members ON actors.id = cast_members.actor_id JOIN movies ON cast_members.movie_id = movies.id WHERE actors.id = $1 ORDER BY movies.title;'
  db_connection do |conn|
    conn.exec(query, [id])
  end
end

get "/" do
  @genres = get_genres
  erb :landing
end

get "/movies" do
  @genres = get_genres
  @page_num = params[:page] ? params[:page].to_i : 1
  offset = (@page_num - 1) * 20
  query = "%#{params[:query]}%" if params[:query]

  get = 'SELECT movies.title, movies.year, movies.rating, movies.id, studios.name AS studio FROM movies JOIN studios ON movies.studio_id = studios.id ORDER BY movies.title LIMIT 20 OFFSET $1;'
  search = 'SELECT movies.title, movies.year, movies.rating, movies.id, studios.name AS studio FROM movies JOIN studios ON movies.studio_id = studios.id WHERE movies.title ILIKE $1 ORDER BY movies.title LIMIT 20 OFFSET $2;'

  db_connection do |conn|
    @movies = conn.exec(get, [offset])
    @movies = conn.exec(search, [query, offset]) if params[:query]


  end
  erb :'movies/index'
end

get "/movies/:id" do
  @genres = get_genres
  @movie = get_movie
  erb :'movies/show'
end

get "/movies/genre/:id" do
  @genres = get_genres
  # @movies_genre = get_movies_by_genre
  @page_num = params[:page] ? params[:page].to_i : 1
  offset = (@page_num - 1) * 20

  id = params[:id]
  query = 'SELECT movies.title, movies.year, movies.rating, movies.id, studios.name AS studio FROM movies JOIN studios ON movies.studio_id = studios.id JOIN genres ON movies.genre_id = genres.id WHERE genres.id = $1 ORDER BY movies.title LIMIT 20 OFFSET $2;'
  db_connection do |conn|
  @movies_genre = conn.exec(query, [id, offset])
  end

  erb :'/movies/genre'
end

get "/actors" do
  @genres = get_genres
  # @actors = get_actors
  @page_num = params[:page] ? params[:page].to_i : 1
  offset = (@page_num - 1) * 20

  query = 'SELECT actors.name AS name, actors.id FROM actors ORDER BY actors.name LIMIT 20 OFFSET $1;'
  db_connection do |conn|
    @actors = conn.exec(query, [offset])
  end


  erb :'/actors/index'
end

get "/actors/:id" do
  @genres = get_genres
  @actor = get_actor

  erb :'/actors/show'
end


