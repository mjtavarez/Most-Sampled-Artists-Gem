require_relative '../config/environment.rb'
# require_relative './cli.rb'

### How will I handle passing 


class Song
  attr_accessor :title, :artist, :year_released, :song_url, :album, :producer, :times_sampled, :genre

  @@songs = []

  def initialize(song_hash)
    song_hash.each{|k,v| self.send("#{k}=", v)}
    @@songs << self
  end

  def self.create_from_collection(songs_array)
    songs_array.each{|song_hash| self.new(song_hash)}
  end

  def self.all
    @@songs
  end

  def add_attributes(attributes_hash)
    attributes_hash.each{|k,v| self.send("#{k}=", v)}
  end

end

# Song.create_from_collection(Scraper.scrape_profile_page("http://www.whosampled.com/James-Brown/"))
# Song.create_from_collection(Scraper.scrape_profile_page("http://127.0.0.1:4000/whosampled/James%20Brown%20_%20WhoSampled.htm"))

# Song.create_from_collection(Scraper.scrape_song_page("http://www.whosampled.com/James-Brown/Funky-President-(People-It%27s-Bad)/sampled/"))
# Song.create_from_collection(Scraper.scrape_song_page("http://127.0.0.1:4000/whosampled/Samples%20of%20Funky%20President%20(People%20It's%20Bad)%20by%20James%20Brown%20_%20WhoSampled.htm"))


# Song.all.each{|song| song.add_attributes(Scraper.scrape_song_attributes(song.song_url))}

# Song.all.each do |song|
#   ###how could I handle this dynamically, for ANY methods that did not get set the first time around?
#   if !song.album
#     song.add_attributes(Scraper.scrape_sample_page(song.song_url))
#   end
# end

# Song.all.each do |song|
#   if !song.genre
# #     puts song.song_url
# #   end
# #   # if !song.genre
#     genre = Scraper.scrape_song_genre(song.song_url)
#     song.add_attributes(genre)
#   end
# end



# Song.all.each{|song| p "#{song.artist}: #{song.title}, #{song.year_released}, #{song.album}, #{song.producer}, #{song.genre}"}
