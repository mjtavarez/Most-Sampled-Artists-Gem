require_relative '../lib/scraper.rb'
require_relative '../lib/artist.rb'
require_relative '../lib/song.rb'
require 'nokogiri'

class CommandLineInterface
  #ideally would like to scrape data for 100 most sampled artists,
  # would need to update URL from 1-10 when the scraper has found all of the artists
  # on the current page

  # does that mean that I should not store the url as a constant?
  BASE_URL = "http://www.whosampled.com/most-sampled-artists/1"

end