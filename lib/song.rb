class Song
  attr_accessor :artist

  @@songs = []

  def initialize(song_hash)
    song_hash.each{|k,v| self.send("#{k}=", v)}
    @@songs << self
  end

  def create_from_collection(songs_array)
    songs_array.each{|song| self.new(song_hash)}
  end

  def self.all
    @@songs
  end


end