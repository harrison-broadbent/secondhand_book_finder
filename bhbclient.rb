# frozen_string_literal: true

require 'goodreads'
require 'oauth'
require 'open-uri'
require 'nokogiri'
require 'json'

### Setup OAuth API keys for Goodreads login.
### Keys are stored in a keys/ folder so they are not shared publicly

api_key = File.open('keys/api_key.txt', &:gets)
api_secret_key = File.open('keys/api_secret_key.txt', &:gets)

consumer = OAuth::Consumer.new(api_key,
                               api_secret_key,
                               site: 'https://www.goodreads.com')

request_token = consumer.get_request_token

### Check if we have previously authenticated.
### If we have, we import previous credentials
### Otherwise we authenticate and then store the credentials in credentials.json

if File.file?('credentials.json')
  credentials = JSON.parse(File.read('credentials.json'))
  access_token = OAuth::AccessToken.new(consumer, credentials['token'], credentials['secret'])
else
  # authorize user on first run
  authorized = false
  while authorized == false
    begin
      sleep(3)
      access_token = request_token.get_access_token
      authorized = true
    rescue StandardError => e
      print "\ngo to authorize url.\n"
      print request_token.authorize_url
    end
  end

  credentials = {
    token: access_token.token,
    secret: access_token.secret
  }

  File.open('credentials.json', 'w') do |f|
    f.write(credentials.to_json)
  end
end

### We use the Goodreads API wrapper gem to make accessing data easier.
### We then proceed to collect all the books on a users shelf.
### Default is the 'to-read' shelf.

goodreads_client = Goodreads.new(oauth_token: access_token)

goodreads_section = 'to-read' # read, to-read
books_shelf = goodreads_client.shelf(goodreads_client.user_id, goodreads_section)

### We can only get 40 results at a time.
### Therefore we need to loop ceil(totalresults/40) times to collect all the books.
### We print the titles to the terminal to indicate we are sucessfully progressing through.

titles = []
pages_of_results = (books_shelf.total / 40.0).ceil
pages_of_results.times do |page_num|
  books_shelf_page = goodreads_client.shelf(goodreads_client.user_id, goodreads_section, page: page_num + 1)
  books_shelf_page.books.each do |b|
    title = b.book.title
    puts title
    titles.append(title)
  end
end

brotherhood_search_url = 'https://www.brotherhoodbooks.org.au/catalogsearch/result/?q='
avaliable_titles = {}

titles.each do |title|
  puts title
  if title.ascii_only?
    brotherhood_search_url = 'https://www.brotherhoodbooks.org.au/catalogsearch/result/?q=' + title
  else
    break
  end

  search_page = Nokogiri::HTML(::OpenURI.open_uri(brotherhood_search_url)).xpath('//*[@class="product-image-photo "]')

  (1..10).each do |counter|
    if search_page[counter]
      book_title_from_search = search_page[counter].values.last
      if book_title_from_search.include?(title) || title.include?(book_title_from_search)
        puts book_title_from_search, title
        puts book_title_from_search.include? title
        puts title.include? book_title_from_search
        avaliable_titles[title] = brotherhood_search_url
      end
    else
      break
    end
  end
end

puts '__________ Brotherhood Books __________'

avaliable_titles.each do |k, v|
  puts k, v
  puts
end

puts avaliable_titles.length.to_s + ' titles found!'
