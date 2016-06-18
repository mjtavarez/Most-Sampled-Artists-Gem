require_relative './scraper.rb'

class Artist
  attr_accessor :name, :ranking, :artist_times_sampled, :profile_url, :sampled_songs
  #:sampled_by_artists, :songs_using_sample, :genre, :sample_genres

  @@all = []

  def initialize(artist_hash)
    artist_hash.each{|k,v| self.send("#{k}=", v)}
    @@all << self
    # @sampled_songs = []
    @songs = []
  end

  def self.create_from_collection(artists_array)
    artists_array.each{|artist_hash| self.new(artist_hash)}
  end

  # def sampled_songs

  # end

  def add_songs(songs_array)
    ### this might change when we try to extend this class for artists who sampled original artists
    ### we would have to check if the song.artist == artist, add it to sampled_songs if it is
    ### if it isn't then we would have to add it to a songs array
    songs_array.each do |song|
      if song.artist == self
        songs << song
      else
        sampling_artist = Artist.all.detect{|artist| song.artist == artist}
        sampling_artist.songs << song
      end
    end
  end

  def self.add_attributes(attributes_hash)

  end

  def self.all
    @@all
  end

end

Artist.create_from_collection(Scraper.scrape_most_sampled_pages("http://www.whosampled.com/most-sampled-artists/1"))
Artist.all.each{|artist| artist.add_songs(Scraper.scrape_profile_page("http://www.whosampled.com/James-Brown/"))}
# puts Artist.all
puts Artist.all.each{|artist| puts "#{artist.ranking}. #{artist.name}, #{artist.artist_times_sampled}, #{artist.profile_url}, #{artist.sampled_songs.size}"}

