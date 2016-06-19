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
        # profile_url: "http://www.whosampled.com" + "#{artist.css('span.artistName a').attribute('href').value}"
        profile_url: "http://127.0.0.1:4000/whosampled/" + "#{artist.css('span.artistName a').text}"#.attribute('href').value}"
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
        # song_url: "http://127.0.0.1:4000/whosampled/" + "#{song.css('a[itemprop = sameAs]').attribute('href').value}"
      }
    end

    songs.each{|song| song[:artist] = profile.css('h1.artistName').text}
    songs
  end


  def self.scrape_song_page(song_url)
    song_page = Nokogiri::HTML(open(song_url))
    songs_using_sample = []

    song_page.css('div.listEntry').each do |sample_track|
      songs_using_sample << {
        title: sample_track.css('a.trackName').text,

        ## sampling artists has a value of an array of strings, the strings may have leading and trailing white space but it's probably
        ## best if I deal with this in one of the other classes where I create these Song and Artist objects
        artist: sample_track.css('span.trackArtist').text[/[^by](\D+)+[^W]?[^\(\d]/].strip.split(",").join(",").split("and").join(",").split(","),
        year_released: sample_track.css('span.trackArtist').text[/\d+/],
        song_url: "http://www.whosampled.com/" + "#{sample_track.css('a.trackName').attribute('href').value}"
        # song_url: "http://127.0.0.1:4000/whosampled/" + "#{sample_track.css('a.trackName').attribute('href').value}"
      }
    end
    songs_using_sample
  end


  def self.scrape_song_attributes(song_url)
    song_page = Nokogiri::HTML(open(song_url))

    attributes = {}

    song_page.css('div.trackReleaseDetails').each do |track_info|
      attributes[:album] = track_info.css('h3.release-name').text

      ###producer string needs to be split!!!
      attributes[:producer] = track_info.css('h3 span[itemprop = name] a').text 
    end

    attributes[:times_sampled] = song_page.css('header.sectionHeader span.section-header-title').text[/\d+/]

    attributes
  end


  def self.scrape_sample_page(sample_url)
    sample = Nokogiri::HTML(open(sample_url))

    attributes = {}

    sample.css('div.sampleEntryBox:first-child div.sampleAdditionalInfoContainer').each do |sample_track|
      attributes[:genre] = sample_track.css('div.track-metainfo:nth-child(3) a').text.delete("/").split(" ")

      #### producer string needs to be split!!!!
      attributes[:producer] =  sample_track.css('div.track-metainfo:first-child a').text
      
    end
    attributes[:album] = sample.css('div.sampleEntryBox:first-child p.release-name').text
    attributes
  end


  def self.scrape_song_genre(sample_url)
    song = Nokogiri::HTML(open(sample_url))
    genre = song.css('div.sampleEntryBox:nth-child(3) div.sampleAdditionalInfoContainer div.track-metainfo:nth-child(3) a').text.delete("/").split(" ")
    attributes = {}
    attributes[:genre] = genre
    attributes
  end

end

puts "Most sampled recording artists\n"
# puts Scraper.scrape_most_sampled_pages("http://www.whosampled.com/most-sampled-artists/1/")
puts Scraper.scrape_most_sampled_pages("http://127.0.0.1:4000/whosampled/Most%20Sampled%20Artists%20_%20WhoSampled.htm")
puts "\n"

# puts "Their most sampled songs\n"
# puts Scraper.scrape_profile_page("http://www.whosampled.com/James-Brown/")
# puts "\n"

# puts "The album the song originally appeared on, its producer, and the number of times it's been sampled\n"
# puts Scraper.scrape_song_attributes("http://www.whosampled.com/James-Brown/Funky-President-(People-It%27s-Bad)/sampled")
# puts "\n"

# puts "The songs using a sample of the original song, their artists, the year of release, and the songs' urls\n"
# puts Scraper.scrape_song_page("http://www.whosampled.com/James-Brown/Funky-President-(People-It%27s-Bad)/sampled/")
# puts "\n"

# puts "The sample track's genre, producer, and album\n"
# puts Scraper.scrape_sample_page("http://www.whosampled.com/sample/169588/Kanye-West-Big-Sean-Jay-Z-Clique-James-Brown-Funky-President-(People-It%27s-Bad)/")
# puts "\n"

# puts "The original song's genre\n"
# puts Scraper.scrape_song_genre("http://www.whosampled.com/sample/169588/Kanye-West-Big-Sean-Jay-Z-Clique-James-Brown-Funky-President-(People-It%27s-Bad)/")