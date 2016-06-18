require 'open-uri'
require 'nokogiri'

class Scraper

  def self.scrape_most_sampled_pages(page_url)
    most_sampled_artists = Nokogiri::HTML(open(page_url))

    artists = []

    most_sampled_artists.css('ul.bordered-list li').each do |artist|
      artists << {
        name: artist.css('span.artistName').text,
        ranking: artist.css('span.chartCount').text,
        artist_times_sampled: artist.css('span.counts').text[/\d+/], #+ " times",
        profile_url: "http://www.whosampled.com" + "#{artist.css('span.artistName a').attribute('href').value}"
      }
    end
    artists
  end

  def self.scrape_profile_page(artist_profile_url)
    profile = Nokogiri::HTML(open(artist_profile_url))

    songs = []

    profile.css('article.trackItem h3.trackName').each do |song|
      songs << {
        title: song.css('span[itemprop = name]').text,
        year_released: song.css('span.trackYear').text[/(\d+)/].delete("(",")"),
        song_url: "http://www.whosampled.com" + "#{song.css('a[itemprop = sameAs]').attribute('href').value}"
      }

    end
    songs
  end

  def self.scrape_song_page(song_url)
    song_page = Nokogiri::HTML(open(song_url))

    songs_using_sample = []
    song_attributes = {}
    # sampling_artist = song_page.css('div.listEntry span.trackArtist a')
    sampling_artist = song_page.css('div.listEntry span.trackArtist a')
    # puts sampling_artist

    # sampling_artist.each do |artist|
    #   songs_using_sample[:sampling_artist] = artist.text
    # end

    song_page.css('div.listEntry').each do |sample_track|
      # artist = []
      # artist << sample_track.css('span.trackArtist a').each do |artist|
      #   puts artist.text
      # end

      # puts artist

      # song_attributes[:sample_track_title] = sample_track.css('a.trackName').text
      # song_attributes[:sampling_artist] = sample_track.css('span.trackArtist a').text
      # song_attributes[:sample_date] = sample_track.css('span.trackArtist').text[/\d+/]
      # song_attributes[:sample_url] = "http://www.whosampled.com/" + "#{sample_track.css('a.trackName').attribute('href').value}"

      songs_using_sample << {
        sample_track_title: sample_track.css('a.trackName').text,


        ## sampling artists has a value of an array of strings, the strings may have leading and trailing white space but it's probably
        ## best if I deal with this in one of the other classes where I create these Song and Artist objects
        sampling_artist: sample_track.css('span.trackArtist').text[/[^by](\D+)+[^W]?[^\(\d]/].strip.split(",").join(",").split("and").join(",").split(","),
        sample_date: sample_track.css('span.trackArtist').text[/\d+/],
        sample_url: "http://www.whosampled.com/" + "#{sample_track.css('a.trackName').attribute('href').value}"
      }
    end
    songs_using_sample
    # ""
  end

  def self.scrape_song_attributes(song_url)
    song_page = Nokogiri::HTML(open(song_url))

    song_attributes = {}

    song_page.css('div.trackReleaseDetails').each do |track_info|
      song_attributes[:album] = track_info.css('h3.release-name').text
      song_attributes[:producer] = track_info.css('h3 span[itemprop = name] a').text 
    end

    song_attributes[:times_sampled] = song_page.css('header.sectionHeader span.section-header-title').text[/\d+/]

    song_attributes
  end

  def self.scrape_sample_page(sample_url)
    sample = Nokogiri::HTML(open(sample_url))

    attributes = {}

    sample.css('div.sampleEntryBox:first-child div.sampleAdditionalInfoContainer').each do |sample_track|
      attributes[:sample_genre] = sample_track.css('div.track-metainfo:nth-child(3) a').text.delete("/").split(" ")
      attributes[:sample_producer] =  sample_track.css('div.track-metainfo:first-child a').text
      
    end
    attributes[:sample_album] = sample.css('div.sampleEntryBox:first-child p.release-name').text
    attributes
  end

  def self.scrape_song_genre(sample_url)
    song = Nokogiri::HTML(open(sample_url))
    genre = song.css('div.sampleEntryBox:nth-child(3) div.sampleAdditionalInfoContainer div.track-metainfo:nth-child(3) a').text.delete("/").split(" ")
    attributes = {}
    attributes[:song_genre] = genre
    attributes
  end

end

# puts "Most sampled recording artists"
# puts Scraper.scrape_most_sampled_pages("http://www.whosampled.com/most-sampled-artists/1/")

# puts "Their most sampled songs\n"
# puts Scraper.scrape_profile_page("http://www.whosampled.com/James-Brown/")

# puts "The album the song originally appeared on, its producer, and the number of times it's been sampled\n"
# puts Scraper.scrape_song_attributes("http://www.whosampled.com/James-Brown/Funky-President-(People-It%27s-Bad)/sampled")

puts "The songs using a sample of the original song, their artists, the year of release, and the songs' urls\n"
puts Scraper.scrape_song_page("http://www.whosampled.com/James-Brown/Funky-President-(People-It%27s-Bad)/sampled/")

# puts "The sample track's genre, producer, and album"
# puts Scraper.scrape_sample_page("http://www.whosampled.com/sample/169588/Kanye-West-Big-Sean-Jay-Z-Clique-James-Brown-Funky-President-(People-It%27s-Bad)/")

# puts "The original song's genre"
# puts Scraper.scrape_song_genre("http://www.whosampled.com/sample/169588/Kanye-West-Big-Sean-Jay-Z-Clique-James-Brown-Funky-President-(People-It%27s-Bad)/")