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
        times_sampled: artist.css('span.counts').text[/\d+/], #+ " times",
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
    song_page = Nokogiri::HTML(open(sampled_song_url))

    songs_using_sample = []
    sampling_artist = song_page.css('div.listEntry span.trackArtist a') 
    # puts sampling_artist

    song_page.css('div.listEntry').each do |sample_track|
      songs_using_sample << {
        sample_track_title: sample_track.css('a.trackName').text,
        ## come back to sampling artist to figure out how to extract this string
        sampling_artist: sample_track.css('span.trackArtist').text,
        sample_date: sample_track.css('span.trackArtist').text[/\d+/],
        sample_url: "http://www.whosampled.com/" + "#{sample_track.css('a.trackName').attribute('href').value}"
      }
    end
    songs_using_sample
  end

  def self.scrape_song_attributes(song_url)
    song_page = Nokogiri::HTML(open(sampled_song_url))

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

    puts sample.css('div.sampleEntryBox:first-child div.sampleAdditionalInfoContainer div.track-metainfo:first-child a').text

    # attributes = {}
    # attributes[sample_producer:] = 
    # attributes[sample_genre:] = 
    # attributes[sample_album:] = 

# div.layout-container section.sample-layout-row div:first-child
    # sample.css('div.sampleAdditionalInfoContainer div:nth-child(2) div.track-metainfo').each do |sample_track|
    #   attributes[:sample_genre] = sample_track.css('a').text.strip
    #   # attributes[:sample_producer] =  sample_track.css('div:nth-child(2) div:nth-child(1)').text.delete("\n\t")[/(\w+\s\w+)/]
    # end
    # ## this is problematic -- returning both album titles figure out how to extract this string
    # attributes[:sample_album] = sample.css('div.sampleReleaseDetails p.release-name:nth-child(1)').text

    # attributes
  end

  # def self.scrape_track_genre(sample_url)
  #   sample_in_depth = Nokogiri::HTML(open(sample_url))

  #   genre = {}

  #   sample_in_depth.css('').each do |genre|

  #   end
  #   genre
  # end

end

# puts Scraper.scrape_most_sampled_pages("http://www.whosampled.com/most-sampled-artists/1/")
# puts "\n"
# puts Scraper.scrape_profile_page("http://www.whosampled.com/James-Brown/")
# puts "\n"
# puts Scraper.scrape_song_attributes("http://www.whosampled.com/James-Brown/Funky-President-(People-It%27s-Bad)/sampled")
# puts "\n"
# puts Scraper.scrape_song_page("http://www.whosampled.com/James-Brown/Funky-President-(People-It%27s-Bad)/sampled/")
puts Scraper.scrape_sample_page("http://www.whosampled.com/sample/169588/Kanye-West-Big-Sean-Jay-Z-Clique-James-Brown-Funky-President-(People-It%27s-Bad)/")