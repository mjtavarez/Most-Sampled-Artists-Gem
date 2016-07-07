require 'rubygems'
require 'nokogiri'
require 'open-uri'

BASE_URL = "http://www.whosampled.com/"
MOST_SAMPLED_ARTISTS = "#{BASE_URL}/most-sampled/artists/1" ## + 1-10
HEADERS_HASH = {'User-Agent' => 'Ruby'}

page = Nokogiri::HTML(open(MOST_SAMPLED_ARTISTS))
artists = page.css('ul.bordered-list li')

DATA_DIR = "../whosampled"
Dir.mkdir(DATA_DIR) unless File.exists(DATA_DIR)

artists.each do |artist|
  hrefs = artist.css('span.artistName a').map{|a| a['href']} #if a['href'] =~ /^\/\//}.compact.uniq

  hrefs.each do |href|
    remote_url = BASE_URL + href
    local_fname = "#{DATA_DIR}/#{File.basename(href).html}" unless File.exists?(local_fname)
    puts "Fetching #{remote_url}..."
    begin
      sampled_content = open(remote_url, HEADERS_HASH).read
    rescue Exception=>e
      puts "Error: #{e}"
      sleep 10
    else
      File.open(local_fname, 'w'){|file| file.write(wiki_content)}
      puts "\t...Success, saved to #{local_fname}"
    ensure
      sleep 10.0 + rand
    end
  end
end


